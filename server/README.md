# 后台启动
nohup python3 server.py &

# docker 启动
 cd alice/
docker compose -f docker-compose.yaml down &&  docker compose -f docker-compose.yaml up -d
 cd bob/
docker compose -f docker-compose.yaml down &&  docker compose -f docker-compose.yaml up -d
 cd charlie/
docker compose -f docker-compose.yaml down &&  docker compose -f docker-compose.yaml up -d


# 去每个文件夹中产生密钥，并将公钥配置到party_info.json中
openssl genpkey -algorithm ed25519 -out ed25519key.pem
openssl pkey -in ed25519key.pem  -pubout -outform DER | base64

# 构建scql工具
git clone -b 0.9.4b1 https://github.com/secretflow/scql.git
cd scql
go build -o brokerctl cmd/brokerctl/main.go


# API 使用示例

以下仅展示各接口的请求命令与示例返回。

## GET /get/ccl
- 请求命令:
  - `curl -sS http://localhost:8111/get/ccl`
- 示例返回:
```
+-----------+-----------+---------------+---------------------------+
| PartyCode | TableName |  ColumnName   |        Constraint         |
+-----------+-----------+---------------+---------------------------+
| alice     | ta        | ID            | PLAINTEXT                 |
| alice     | ta        | age           | PLAINTEXT                 |
| alice     | ta        | credit_rank   | PLAINTEXT                 |
| alice     | ta        | income        | PLAINTEXT                 |
| alice     | tb        | ID            | PLAINTEXT_AFTER_JOIN      |
| alice     | tb        | is_active     | PLAINTEXT_AFTER_COMPARE   |
| alice     | tb        | order_amount  | PLAINTEXT_AFTER_AGGREGATE |
| alice     | tc        | ID            | PLAINTEXT_AFTER_JOIN      |
| alice     | tc        | is_actives    | PLAINTEXT_AFTER_COMPARE   |
| alice     | tc        | order_amounts | PLAINTEXT_AFTER_AGGREGATE |
+-----------+-----------+---------------+---------------------------+
```

## POST /run
- 请求命令:
    - `curl -sS -X POST 'http://localhost:8111/run' -H 'Content-Type: text/plain' --data $'SELECT ta.credit_rank, COUNT(*) as cnt, AVG(ta.income) as avg_income, AVG(tc.order_amounts) as avg_amount FROM ta INNER JOIN tc ON ta.ID = tc.ID WHERE ta.age >= 20 AND ta.age <= 30 AND tc.is_actives=1 GROUP BY ta.credit_rank;'`
    - `curl -sS -X POST 'http://10.130.66.71:8111/run' -H 'Content-Type: text/plain' --data $'SELECT s.company, s.总打款, s.总收入 FROM (SELECT tc.company, tc.总打款 + tb.总打款 AS 总打款, tc.总收入 + tb.总收入 AS 总收入 FROM (SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tc WHERE 类型=\'打款\' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tc WHERE 类型=\'收款\' GROUP BY 收款单位) r ON p.company = r.company) tc JOIN (SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tb WHERE 类型=\'打款\' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tb WHERE 类型=\'收款\' GROUP BY 收款单位) r ON p.company = r.company) tb ON tc.company = tb.company) s JOIN ta ON ta.企业名称 = s.company;'`
- 示例返回:
```
+-------------+-----+------------+------------+
| credit_rank | cnt | avg_income | avg_amount |
+-------------+-----+------------+------------+
| A           |  12 |   56321.33 |     230.41 |
| B           |   7 |   42110.08 |     180.55 |
+-------------+-----+------------+------------+
```

## GET /logs
- 请求命令:
  - `curl -sS http://localhost:8111/logs`
- 示例返回:
```
["select user_credit.ID,user_credit.credit_rank,user_credit.income from alice.user_credit where (user_credit.age>=20) and (user_credit.age<=30);"]
```