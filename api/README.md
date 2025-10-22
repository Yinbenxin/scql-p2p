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

## GET /run
- 请求命令:
  - `curl -sS 'http://localhost:8111/run?txt=SELECT ta.credit_rank, COUNT(*) as cnt, AVG(ta.income) as avg_income, AVG(tc.order_amounts) as avg_amount FROM ta INNER JOIN tc ON ta.ID = tc.ID WHERE ta.age >= 20 AND ta.age <= 30 AND tc.is_actives=1 GROUP BY ta.credit_rank;'`
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