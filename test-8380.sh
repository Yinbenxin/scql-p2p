#!/usr/bin/env bash
set -euo pipefail

./brokerctl process invitation 1 --response "accept" --project-id "demo" --host http://127.0.0.1:8380

./brokerctl create table tc --project-id "demo" --columns "ID string, order_amounts double, is_actives int" --ref-table charlie.user_stats --db-type mysql --host http://127.0.0.1:8380
./brokerctl get table tc --host http://127.0.0.1:8380 --project-id "demo"

./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name ID --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name order_amounts --host http://127.0.0.1:8380
./brokerctl grant charlie PLAINTEXT --project-id "demo" --table-name tc --column-name is_actives --host http://127.0.0.1:8380

./brokerctl grant alice PLAINTEXT_AFTER_JOIN --project-id "demo" --table-name tc --column-name ID --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_COMPARE --project-id "demo" --table-name tc --column-name is_actives --host http://127.0.0.1:8380
./brokerctl grant alice PLAINTEXT_AFTER_AGGREGATE --project-id "demo" --table-name tc --column-name order_amounts --host http://127.0.0.1:8380