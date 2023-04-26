#!/bin/bash

MYSQL_PWD=root
MYSQL_USER=root
PROXY_PWD=radmin
PROXY_USER=radmin
PORT=32760
PROXY_PORT=32761
HOSTNAME=127.0.0.1


MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER -e"UPDATE global_variables SET variable_value='true' where variable_name='mysql-stats_time_query_processor'; LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL VARIABLES TO DISK;"

# Create 50000 schemas:

for i in `seq 10001 110000` ; do
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
for i in `seq 10001 110000` ; do
echo "INSERT INTO mysql_query_rules_fast_routing (username,schemaname,flagIN,destination_hostgroup,comment) VALUES (\"sbtest\",\"shard_$i\",0,1,\"\");"
done
echo "LOAD MYSQL QUERY RULES TO RUNTIME;"
) | MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER

#echo "Run selects"

for j in `seq 1 50000` ; do
    echo "USE shard_$(($RANDOM%200+10001))" ; echo "SELECT 1;"
done | MYSQL_PWD="$MYSQL_PWD" mysql -h$HOSTNAME -P$PORT -u$MYSQL_USER --ssl-mode=disabled -NB > /dev/null

MYSQL_PWD="$PROXY_PWD" mysql -h$HOSTNAME -P$PROXY_PORT -u$PROXY_USER -e"select * from stats_mysql_global where Variable_name='Query_Processor_time_nsec' ;"
