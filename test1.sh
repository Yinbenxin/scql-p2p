

./brokerctl create project --project-id "demo2" --host http://127.0.0.1:8180
./brokerctl invite bob --project-id "demo2" --host http://127.0.0.1:8180
./brokerctl invite charlie --project-id "demo2" --host http://127.0.0.1:8180
./brokerctl process invitation 2 --response "accept" --project-id "demo2" --host http://127.0.0.1:8280
./brokerctl process invitation 2 --response "accept" --project-id "demo2" --host http://127.0.0.1:8380



./brokerctl create table ta --project-id "demo2" --columns "企业名称 string, 统一社会信用代码 string" --ref-table alice.企业信用代码对照表 --db-type mysql --host http://127.0.0.1:8180
./brokerctl create table tb --project-id "demo2" --columns "统一社会信用代码 string, 付款单位 string, 收款单位统一社会信用代码 string, 收款单位 string, 金额 double, 类型 string" --ref-table bob.银行A测试数据 --db-type mysql --host http://127.0.0.1:8280
./brokerctl create table tc --project-id "demo2" --columns "统一社会信用代码 string, 付款单位 string, 收款单位统一社会信用代码 string, 收款单位 string, 金额 double, 类型 string" --ref-table charlie.银行B测试数据 --db-type mysql --host http://127.0.0.1:8380


./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name ta --column-name 企业名称 --host http://127.0.0.1:8180
./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name ta --column-name 统一社会信用代码 --host http://127.0.0.1:8180

./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 统一社会信用代码 --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 付款单位 --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 收款单位统一社会信用代码 --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 收款单位 --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 金额 --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo2" --table-name tb --column-name 类型 --host http://127.0.0.1:8280

./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 付款单位 --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 统一社会信用代码 --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 收款单位统一社会信用代码 --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 收款单位 --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 金额 --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo2" --table-name tc --column-name 类型 --host http://127.0.0.1:8380


./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo2" --table-name tb --column-name 金额 --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo2" --table-name tb --column-name 类型 --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name tb --column-name 付款单位 --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name tb --column-name 收款单位 --host http://127.0.0.1:8280

./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo2" --table-name tc --column-name 金额 --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo2" --table-name tc --column-name 类型 --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name tc --column-name 付款单位 --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT --project-id "demo2" --table-name tc --column-name 收款单位 --host http://127.0.0.1:8380

./brokerctl get ccl  --project-id "demo2" --parties alice --host http://127.0.0.1:8180

./brokerctl run "SELECT SUM(金额) AS 收入总和 FROM tb WHERE 类型 ='收款';" --project-id "demo2" --host http://127.0.0.1:8180 --timeout 5

./brokerctl run "SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tc WHERE 类型='打款' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tc WHERE 类型='收款' GROUP BY 收款单位) r ON p.company = r.company;" --project-id "demo2" --host http://127.0.0.1:8180 --timeout 5

./brokerctl run "SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tb WHERE 类型='打款' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tb WHERE 类型='收款' GROUP BY 收款单位) r ON p.company = r.company;" --project-id "demo2" --host http://127.0.0.1:8180 --timeout 5

 ./brokerctl run "SELECT s.company, s.总打款, s.总收入 FROM (SELECT tc.company, tc.总打款 + tb.总打款 AS 总打款, tc.总收入 + tb.总收入 AS 总收入 FROM (SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tc WHERE 类型='打款' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tc WHERE 类型='收款' GROUP BY 收款单位) r ON p.company = r.company) tc JOIN (SELECT p.company, p.总打款, r.总收入 FROM (SELECT 付款单位 AS company, SUM(金额) AS 总打款 FROM tb WHERE 类型='打款' GROUP BY 付款单位) p JOIN (SELECT 收款单位 AS company, SUM(金额) AS 总收入 FROM tb WHERE 类型='收款' GROUP BY 收款单位) r ON p.company = r.company) tb ON tc.company = tb.company) s JOIN ta ON ta.企业名称 = s.company;" --project-id "demo2" --host http://127.0.0.1:8180 --timeout 5