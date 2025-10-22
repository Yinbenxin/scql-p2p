#!/usr/bin/env python3
import subprocess
import re
import base64
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, parse_qs

REPO_ROOT = Path(__file__).resolve().parents[1]
BROKERCTL = REPO_ROOT / "brokerctl"

# 提取表格块的辅助函数
def extract_table(text: str, marker: str | None = None) -> str:
    lines = text.splitlines()
    start_idx = 0
    if marker:
        for i, line in enumerate(lines):
            if line.strip() == marker:
                start_idx = i + 1
                break
    table_lines = []
    started = False
    for line in lines[start_idx:]:
        if line.startswith('+') or line.startswith('|'):
            table_lines.append(line)
            started = True
        elif started:
            break
    if not table_lines:
        for line in lines:
            if line.startswith('+') or line.startswith('|'):
                table_lines.append(line)
    return '\n'.join(table_lines).strip()

class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Silence default logging to keep output clean
        return

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith('/get/ccl'):
            self.handle_get_ccl()
        elif parsed.path.startswith('/run'):
            self.send_response(405)
            self.send_header('Allow', 'POST')
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'Method Not Allowed: use POST /run')
        elif parsed.path.startswith('/logs'):
            self.handle_logs()
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'Not Found')

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith('/run'):
            self.handle_run_post()
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'Not Found')

    def handle_get_ccl(self):
        cmd = [
            str(BROKERCTL), 'get', 'ccl',
            '--project-id', 'demo',
            '--parties', 'alice',
            '--host', 'http://127.0.0.1:8180'
        ]
        try:
            res = subprocess.run(
                cmd,
                cwd=str(REPO_ROOT),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=20
            )
            output = res.stdout.strip()
            if res.returncode != 0:
                self.send_response(500)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.end_headers()
                err = (
                    f"Command failed (exit {res.returncode}).\n"
                    f"STDOUT:\n{output}\n"
                    f"STDERR:\n{res.stderr.strip()}"
                )
                self.wfile.write(err.encode('utf-8'))
                return
            # 仅返回 [fetch] 后的表格
            table_text = extract_table(output, marker='[fetch]')
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(table_text.encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(f'Exception: {e}'.encode('utf-8'))

    def handle_run_get(self, parsed):
        qs = parse_qs(parsed.query)
        txt_list = qs.get('txt')
        if not txt_list or not txt_list[0].strip():
            self.send_response(400)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'Missing query param: txt')
            return
        sql = txt_list[0]
        self._run_sql(sql)

    def handle_run_post(self):
        # 支持两种POST：
        # 1) text/plain 原始 SQL 在请求体
        # 2) application/x-www-form-urlencoded，键为 txt 或 txt64
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length > 0 else b''
        ctype = self.headers.get('Content-Type', '')
        sql = None
        if 'application/x-www-form-urlencoded' in ctype:
            try:
                form = parse_qs(body.decode('utf-8'))
                if 'txt' in form and form['txt'][0].strip():
                    sql = form['txt'][0]
                elif 'txt64' in form and form['txt64'][0].strip():
                    sql = base64.b64decode(form['txt64'][0]).decode('utf-8')
            except Exception:
                pass
        else:
            # 当为 text/plain 或其他类型时，直接将 body 作为 SQL
            try:
                sql = body.decode('utf-8')
            except Exception:
                sql = None
        if not sql or not sql.strip():
            self.send_response(400)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'Missing SQL in POST body (txt/txt64 or raw body)')
            return
        self._run_sql(sql)

    def _run_sql(self, sql: str):
        cmd = [
            str(BROKERCTL), 'run', sql,
            '--project-id', 'demo',
            '--host', 'http://127.0.0.1:8180',
            '--timeout', '5'
        ]
        try:
            res = subprocess.run(
                cmd,
                cwd=str(REPO_ROOT),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=30
            )
            output = res.stdout.strip()
            if res.returncode != 0:
                self.send_response(500)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.end_headers()
                err = (
                    f"Command failed (exit {res.returncode}).\n"
                    f"STDOUT:\n{output}\n"
                    f"STDERR:\n{res.stderr.strip()}"
                )
                self.wfile.write(err.encode('utf-8'))
                return
            # 仅返回结果表格（没有 marker 时提取首个表格块）
            table_text = extract_table(output)
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(table_text.encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(f'Exception: {e}'.encode('utf-8'))

    def handle_logs(self):
        # 从 alice-broker-1 日志中提取最新的 string_data 片段
        cmd = ['bash', '-lc', 'docker logs alice-broker-1 | grep "string_data" | tail -n 1']
        try:
            res = subprocess.run(
                cmd,
                cwd=str(REPO_ROOT),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=20
            )
            output = res.stdout.strip()
            if res.returncode != 0:
                self.send_response(500)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.end_headers()
                err = (
                    f"Command failed (exit {res.returncode}).\n"
                    f"STDOUT:\n{output}\n"
                    f"STDERR:\n{res.stderr.strip()}"
                )
                self.wfile.write(err.encode('utf-8'))
                return
            # 仅返回 string_data 的数组内容，例如 ["..."]
            m = re.search(r'"string_data"\s*:\s*(\[[^\]]*\])', output)
            if not m:
                self.send_response(404)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.end_headers()
                self.wfile.write(b'string_data not found')
                return
            array_text = m.group(1)
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(array_text.encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(f'Exception: {e}'.encode('utf-8'))


def main():
    host = '0.0.0.0'
    port = 8111
    server = ThreadingHTTPServer((host, port), Handler)
    print(f'Server listening on {host}:{port}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == '__main__':
    main()