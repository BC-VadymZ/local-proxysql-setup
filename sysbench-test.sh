#!/bin/bash

PREP_THREADS=2
RUN_THREADS=2
NUM_TABLES=50000
SIZE_TABLES=100
REPORT_INTERVAL=5
TIME=600

MYSQL_PWD=root
MYSQL_USER=root
PROXY_PWD=radmin
PROXY_USER=radmin
PORT=32760
PROXY_PORT=32761
HOSTNAME=127.0.0.1


#MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER -e"UPDATE global_variables SET variable_value='true' where variable_name='mysql-stats_time_query_processor'; LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL VARIABLES TO DISK;"
MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER -e"UPDATE global_variables SET variable_value=1000 where variable_name='mysql-monitor_read_only_timeout'; LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL VARIABLES TO DISK;"
# Create 50000 schemas:

#echo "Create 50000 schemas"

for i in `seq 10001 60000` ; do
    echo "CREATE DATABASE IF NOT EXISTS shard_$i;"
    MYSQL_PWD="$MYSQL_PWD" mysql -h$HOSTNAME -P$PORT -u$MYSQL_USER -e"CREATE DATABASE IF NOT EXISTS shard_$i;" > /dev/null
done 

#echo "Create query rules"

#(
#echo "DELETE FROM mysql_query_rules; INSERT INTO mysql_query_rules (active,username,cache_ttl) VALUES (1,\"sbtest\",120000);"
#for i in `seq 10001 110000` ; do
#echo "INSERT INTO mysql_query_rules (active,username,schemaname,destination_hostgroup,apply) VALUES (1,\"sbtest\",\"shard_$i\",1,1);"
#done
#echo "LOAD MYSQL QUERY RULES TO RUNTIME;"
#) | MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER

echo "Create fast routing query rules"
(
echo "DELETE FROM mysql_query_rules; DELETE FROM mysql_query_rules_fast_routing;"
echo "INSERT INTO mysql_query_rules (active,username,cache_ttl) VALUES (1,\"sbtest\",120000);"
for i in `seq 110000 610000` ; do
echo "INSERT INTO mysql_query_rules_fast_routing (username,schemaname,flagIN,destination_hostgroup,comment) VALUES (\"sbtest\",\"shard_$i\",0,1,\"\");"
done
echo "LOAD MYSQL QUERY RULES TO RUNTIME;"
) | MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER

#echo "Run selects"


#for j in `seq 1 50000` ; do
#    echo "USE shard_$(($RANDOM%200+10001))" ; echo "SELECT 1;"
#done | MYSQL_PWD="$MYSQL_PWD" mysql -h$HOSTNAME -P$PORT -u$MYSQL_USER --ssl-mode=disabled -NB > /dev/null

#MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER -e"select * from stats_mysql_global where Variable_name='Query_Processor_time_nsec' ;"

#printf "$POWDER_BLUE[$(date)] Running Sysbench Benchmarks against ProxySQL:"
#sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$PREP_THREADS \
# --mysql-db=sysbench --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT --db-driver=mysql prepare

#sleep 5

#sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.lua --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
# --mysql-db=sysbench --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
# --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql --mysql-ignore-errors=all run

#sysbench /opt/homebrew//Cellar/sysbench/1.0.20_3/share/sysbench/oltp_read_write.luaa --table-size=$SIZE_TABLES --tables=$NUM_TABLES --threads=$RUN_THREADS \
# --mysql-db=sysbench --mysql-user=root --mysql-password=$MYSQL_PWD --mysql-host=$HOSTNAME --mysql-port=$PORT \
# --time=$TIME --report-interval=$REPORT_INTERVAL --db-driver=mysql run


printf "$POWDER_BLUE$BRIGHT[$(date)] Benchmarking COMPLETED!$NORMAL\n"
