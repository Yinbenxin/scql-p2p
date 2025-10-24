#!/usr/bin/env bash
set -euo pipefail

./brokerctl get invitation --host http://127.0.0.1:8280
./brokerctl process invitation 1 --response "accept" --project-id "demo" --host http://127.0.0.1:8280

./brokerctl create table tb --project-id "demo" --columns "ID string, order_amount double, is_active int" --ref-table bob.user_stats --db-type mysql --host http://127.0.0.1:8280
./brokerctl get table tb --host http://127.0.0.1:8280 --project-id "demo"

./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name ID --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name order_amount --host http://127.0.0.1:8280
./brokerctl grant bob PLAINTEXT --project-id "demo" --table-name tb --column-name is_active --host http://127.0.0.1:8280

./brokerctl grant alice PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name tb --column-name ID --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name tb --column-name is_active --host http://127.0.0.1:8280
./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name tb --column-name order_amount --host http://127.0.0.1:8280