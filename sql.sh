#!/bin/sh

# psql db_test01 -U pg_pool -p 5432 -c 'insert into t1( a ,b ) values (generate_series(1,25), md5(clock_timestamp()::text))'
# psql db_test01 -U pg_pool -p 5432 -c 'select * from t1 order by a ASC LIMIT 30 OFFSET 4;'
# psql db_test01 -U pg_pool -p 5432 -h 192.168.33.12 -c 'select * from t1;'
# psql db_test01 -U pg_pool -p 5433 -h 192.168.33.12 -c 'select * from t1;'
# psql db_test01 -U pg_pool -p 5432 -h 192.168.33.13 -c 'select * from t1;'
# psql db_test01 -U pg_pool -p 5433 -h 192.168.33.13 -c 'select * from t1;'

psql db_test01 -U pg_pool -p 5432 -h 192.168.33.12 -c 'show pool_status;'> show_pgpool
psql db_test01 -U pg_pool -p 5432 -h 192.168.33.12 -c 'select * from t1' >pg_pool_a
psql db_test01 -U pg_pool -p 5432 -h 192.168.33.13 -c 'select * from t1' >pg_pool_b
psql db_test01 -U pg_pool -p 5433 -h 192.168.33.12 -c 'select * from t1' >postgres_a
psql db_test01 -U pg_pool -p 5433 -h 192.168.33.13 -c 'select * from t1' >postgres_b
psql db_test01 -U pg_pool -p 5432 -h 192.168.33.14 -c 'select * from t1' >delegate_pg_pool

wc -l pg_pool_a
wc -l pg_pool_b
wc -l postgres_a
wc -l postgres_b
wc -l delegaded_pg_pool


psql db_test01 -U pg_pool -p 5432 -h 192.168.33.12 -c 'show pool_nodes'
psql db_test01 -U pg_pool -p 5432 -h 192.168.33.13 -c 'show pool_nodes'
psql db_test01 -U pg_pool -p 5432 -h 192.168.33.14 -c 'show pool_nodes'

# service postgresql stop
# pcp_recovery_node 100 192.168.33.12 9898 pg_pool pg_passwd 1


