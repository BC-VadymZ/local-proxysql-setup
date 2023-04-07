#!/bin/bash
#set -x
. constants

PREP_THREADS=2
RUN_THREADS=2
NUM_TABLES=10
SIZE_TABLES=100
REPORT_INTERVAL=5
TIME=600

MYSQL_PWD=root
MYSQL_USER=root
PORT=30080
HOSTNAME=127.0.0.1

printf "$RED[$(date)] Dropping 'sysbench' schema if present and preparing test dataset:$NORMAL\n"
mysql -h$HOSTNAME -P$PORT -u$MYSQL_USER -p$MYSQL_PWD -e"DROP DATABASE IF EXISTS sysbench; CREATE DATABASE IF NOT EXISTS sysbench"

printf "$POWDER_BLUE[$(date)] Running Sysbench Benchmarks against ProxySQL:"
sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$PREP_THREADS \
 --mysql-db=sysbench --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT --db-driver=mysql prepare

sleep 5

sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
 --mysql-db=sysbench --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
 --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql --mysql-ignore-errors=all run

#sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.luaa --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
# --mysql-db=sysbench --mysql-user=root --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
# --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql run


printf "$POWDER_BLUE$BRIGHT[$(date)] Benchmarking COMPLETED!$NORMAL\n"
