

./brokerctl create project --project-id "demo" --host http://127.0.0.1:8180
./brokerctl invite bob --project-id "demo" --host http://127.0.0.1:8180
./brokerctl invite charlie --project-id "demo" --host http://127.0.0.1:8180

./brokerctl process invitation 1 --response "accept" --project-id "demo" --host http://127.0.0.1:8280
./brokerctl process invitation 1 --response "accept" --project-id "demo" --host http://127.0.0.1:8380
./brokerctl get project --host http://127.0.0.1:8180


./brokerctl create table ta --project-id "demo" --columns "ID string, credit_rank int, income int, age int" --ref-table alice.user_credit --db-type mysql --host http://127.0.0.1:8180
./brokerctl grant alice PLAINTEXT --project-id "demo" --table-name ta --column-name ID --host http://127.0.0.1:8180
./brokerctl grant alice PLAINTEXT --project-id "demo" --table-name ta --column-name credit_rank --host http://127.0.0.1:8180
./brokerctl grant alice PLAINTEXT --project-id "demo" --table-name ta --column-name income --host http://127.0.0.1:8180
./brokerctl grant alice PLAINTEXT --project-id "demo" --table-name ta --column-name age --host http://127.0.0.1:8180
./brokerctl grant bob PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name ta --column-name ID --host http://127.0.0.1:8180
./brokerctl grant bob PLAINTEXT_AFTER_GROUP_BY --project-id "demo" --table-name ta --column-name credit_rank --host http://127.0.0.1:8180
./brokerctl grant bob PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name ta --column-name income --host http://127.0.0.1:8180
./brokerctl grant bob PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name ta --column-name age --host http://127.0.0.1:8180
./brokerctl grant charlie PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name ta --column-name ID --host http://127.0.0.1:8180
./brokerctl grant charlie PLAINTEXT_AFTER_GROUP_BY --project-id "demo" --table-name ta --column-name credit_rank --host http://127.0.0.1:8180
./brokerctl grant charlie PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name ta --column-name income --host http://127.0.0.1:8180
./brokerctl grant charlie PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name ta --column-name age --host http://127.0.0.1:8180

./brokerctl create table tb --project-id "demo" --columns "ID string, order_amount double, is_active int" --ref-table bob.user_stats --db-type mysql --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name ID --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name order_amount --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name is_active --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name tb --column-name ID --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name tb --column-name is_active --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name tb --column-name order_amount --host http://127.0.0.1:8280

./brokerctl create table tc --project-id "demo" --columns "ID string, order_amounts double, is_actives int" --ref-table charlie.user_stats --db-type mysql --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name ID --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name order_amounts --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name is_actives --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name tc --column-name ID --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name tc --column-name is_actives --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name tc --column-name order_amounts --host http://127.0.0.1:8380

./brokerctl get ccl  --project-id "demo" --parties alice --host http://127.0.0.1:8180
./brokerctl get ccl  --project-id "demo" --parties bob --host http://127.0.0.1:8180
./brokerctl get ccl  --project-id "demo" --parties charlie --host http://127.0.0.1:8180 


./brokerctl run "SELECT ta.credit_rank, COUNT(*) as cnt FROM ta INNER JOIN tb ON ta.ID = tb.ID GROUP BY ta.credit_rank;"  --project-id "demo" --host http://127.0.0.1:8180 --timeout 3

./brokerctl run "SELECT ta.credit_rank, COUNT(*) as cnt, AVG(ta.income) as avg_income, AVG(tc.order_amounts) as avg_amount FROM ta INNER JOIN tc ON ta.ID = tc.ID WHERE ta.age >= 20 AND ta.age <= 30 AND tc.is_actives=1 GROUP BY ta.credit_rank;"  --project-id "demo" --host http://127.0.0.1:8180 --timeout 5

