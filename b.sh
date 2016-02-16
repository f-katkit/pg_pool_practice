#!/bin/sh

IPADDR=`LANG=C /sbin/ifconfig | grep 'inet addr'|sed -n 2p | awk '{print $2;}' | cut -d: -f2`
OTHERIPADDR=192.168.33.12
DELEGATEIPADDR=192.168.33.14

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update
apt-get upgrade
apt-get install -q -y postgresql-9.4 pgpool2=3.3.2-1ubuntu1 libpgpool0=3.3.2-1ubuntu1 postgresql-server-dev-9.4

sed -i -e "s/#listen_addresses = .*/listen_addresses = \'${IPADDR}\'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#archive_mode = .*/archive_mode  = 'on'/g" /etc/postgresql/9.4/main/postgresql.conf

#sed -i -e "s|#archive_command = .*|archive_command = \'if [ ! -d /backup/postgresql/wal_archives ]; then mkdir /backup/postgresql/wal_archives; fi; test ! -f /backup/postgresql/wal_archives/%f \&\& gzip < %p > /backup/postgresql/wal_archives/%f'|g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s|#archive_command = .*|archive_command = 'cp %p /backup/postgresql/wal_archives/%f\'|g" /etc/postgresql/9.4/main/postgresql.conf

sed -i -e "s/#wal_level .*/wal_level = \'hot_standby\'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#wal_sender_timeout .*/wal_sender_timeout = 60s/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#archive_timeout .*/archive_timeout = \'300s\'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#checkpoint_completion_target .*/checkpoint_completion_target = \'0.9\'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#checkpoint_segments .*/checkpoint_segments = 16/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i -e "s/#checkpoint_timeout =.*/checkpoint_timeout = \'10min\'/g" /etc/postgresql/9.4/main/postgresql.conf

sed -i -e "s/listen_addresses =.*/listen_addresses = \'*\'/g" /etc/pgpool2/pgpool.conf
# sed -i -e "s/num_init_children =.*/num_init_children = 64/g" /etc/pgpool2/pgpool.conf
# sed -i -e "s/max_pool =.*/max_pool = 4/g" /etc/pgpool2/pgpool.conf
# sed -i -e "s/memory_cache_enabled =.*/memory_cache_enabled = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_hostname0 .*/backend_hostname0 = \'192.168.33.12\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_hostname1 .*/backend_hostname1 = \'192.168.33.13\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_port0.*/backend_port0 = 5433/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_port1.*/backend_port1 = 5433/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_weight0 .*/backend_weight0 = 1/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_weight1 .*/backend_weight1 = 1/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_data_directory0 .*/backend_data_directory0 = \'\/var\/lib\/postgresql\/9.4\/main\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_data_directory1 .*/backend_data_directory1 = \'\/var\/lib\/postgresql\/9.4\/main\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_flag0 .*/backend_flag0 = \'ALLOW_TO_FAILOVER\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#backend_flag1 .*/backend_flag1 = \'ALLOW_TO_FAILOVER\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#enable_pool_hba =.*/enable_pool_hba = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#pool_passwd =.*/pool_passwd = \'pool_passwd\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/replication_mode =.*/replication_mode = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/replication_stop_on_mismatch =.*/replication_stop_on_mismatch = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/failover_if_affected_tuples_mismatch = .*/failover_if_affected_tuples_mismatch = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/load_balance_mode = .*/load_balance_mode = on/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/recovery_user =.*/recovery_user = \'postgres\' /g" /etc/pgpool2/pgpool.conf
sed -i -e "s/recovery_password  =.*/recovery_password = ''/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/recovery_1st_stage_command =.*/recovery_1st_stage_command = \'recovery_1st_stage.sh\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/recovery_2nd_stage_command =.*/recovery_2nd_stage_command = \'recovery_2nd_stage.sh\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/use_watchdog =.*/use_watchdog = on/g" /etc/pgpool2/pgpool.conf
# sed -i -e "s/trusted_servers =.*/trusted_servers = \'${IPADDR},${OTHERIPADDR}\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/wd_hostname =.*/wd_hostname = \'${IPADDR}\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/wd_authkey =.*/wd_authkey = \'pg_dog\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/delegate_IP =.*/delegate_IP = \'${DELEGATEIPADDR}\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/heartbeat_destination0 =.*/heartbeat_destination0 = \'${OTHERIPADDR}\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/heartbeat_device0 =.*/heartbeat_device0 = \'eth1\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#other_pgpool_hostname0 =.*/other_pgpool_hostname0 = \'${OTHERIPADDR}\'/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#other_pgpool_port0 =.*/other_pgpool_port0 = 5432/g" /etc/pgpool2/pgpool.conf
sed -i -e "s/#other_wd_port0 =.*/other_wd_port0 = 9000/g" /etc/pgpool2/pgpool.conf



wget http://www.pgpool.net/download.php?f=pgpool-II-3.4.3.tar.gz
PATH=$PATH:/usr/lib/postgresql/9.4/bin/
tar xvfz download*.tar.gz
cd /home/vagrant/pgpool*3.4.3/src/sql/pgpool-recovery
make
make install
cd /home/vagrant/pgpool*3.4.3/src/sql/pgpool-regclass
make
make install

echo  "pg_pool:" >>/etc/pgpool2/pool_passwd
echo  "# pg_pool:pg_passwd" >>/etc/pgpool2/pcp.conf
echo  "pg_pool:9ab24932d09f502bc925b55db336a707" >>/etc/pgpool2/pcp.conf
echo  "# vagrant:vagrant" >>/etc/pgpool2/pcp.conf
echo  "vagrant:63623900c8bbf21c706c45dcb7a2c083" >>/etc/pgpool2/pcp.conf

cp /vagrant/recovery_1st_stage.sh /var/lib/postgresql/9.4/main/recovery_1st_stage.sh
cp /vagrant/recovery_2nd_stage.sh /var/lib/postgresql/9.4/main/recovery_2nd_stage.sh
cp /vagrant/pgpool_remote_start /var/lib/postgresql/9.4/main/pgpool_remote_start
cp /etc/postgresql/9.4/main/postgresql.conf /var/lib/postgresql/9.4/main/postgresql.conf

chown postgres.postgres -R /var/lib/postgresql/9.4/main/
mkdir /var/run/pgpool
mkdir /var/log/pgpool
chown postgres:postgres /var/log/pgpool/
chown postgres:postgres /var/run/pgpool/

echo "host    all          pg_pool             192.168.33.0/24         trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    all          postgres             192.168.33.0/24         trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    all         all         127.0.0.1/32          trust" >> /etc/pgpool2/pool_hba.conf
echo "host    all         pg_pool         192.168.33.0/24       trust " >>/etc/pgpool2/pool_hba.conf
echo "host    all         postgres    192.168.33.0/24       trust " >>/etc/pgpool2/pool_hba.conf
echo "host    all         all         0.0.0.0/0             trust " >>/etc/pgpool2/pool_hba.conf

echo "pg_pool:9ab24932d09f502bc925b55db336a707" >> /etc/pgpool2/pool_passwd
echo "postgres:" >> /etc/pgpool2/pool_passwd
echo "vagrant:63623900c8bbf21c706c45dcb7a2c083" >> /etc/pgpool2/pool_passwd

mkdir -p /backup/postgresql/basebackup
mkdir -p /backup/postgresql/wal_archives
chmod -R 700 /backup/postgresql/
chown -R postgres.postgres /backup/postgresql/

service postgresql stop
service pgpool2 stop

# su postgres -l -c 'createdb db_test01'
# su postgres -l -c "psql db_test01 -c 'create table t1 (a int, b text)'"
# su postgres -l -c "psql db_test01 -c 'insert into t1( a ,b ) values (generate_series(1,100), md5(clock_timestamp()::text))'"
# su postgres -l -c "psql -c'CREATE ROLE pg_pool WITH LOGIN CREATEDB CREATEROLE REPLICATION;'"
# su postgres -l -c "psql db_test01 -c'GRANT SELECT, UPDATE, INSERT ON t1 TO pg_pool;'"
# su postgres -l -c "psql db_test01 -c'CREATE EXTENSION pgpool_regclass;'"
# su postgres -l -c "psql db_test01 -c'CREATE EXTENSION pgpool_recovery;'"
# su postgres -l -c "psql template1 -c'CREATE EXTENSION pgpool_regclass;'"
# su postgres -l -c "psql template1 -c'CREATE EXTENSION pgpool_recovery;'"

mkdir /var/lib/postgresql/.ssh
cp -P /vagrant/id_dsa /var/lib/postgresql/.ssh/id_dsa
cp -P /vagrant/id_dsa.pub /var/lib/postgresql/.ssh/authorized_keys2
chown postgres.postgres /var/lib/postgresql/.ssh/id_dsa /var/lib/postgresql/.ssh/authorized_keys2
chmod 600 /var/lib/postgresql/.ssh/id_dsa /var/lib/postgresql/.ssh/authorized_keys2
chmod 700 /var/lib/postgresql/.ssh/
chown -R postgres.postgres /var/lib/postgresql/.ssh
cp /vagrant/sql.sh /root/sql.sh


psql db_test01 -U pg_pool -p 5432 -h 192.168.33.12 -c 'show pool_nodes'
sleep 3
pcp_recovery_node 100 192.168.33.12 9898 pg_pool pg_passwd 1
# su -c '/usr/sbin/pgpool -n > /var/log/pgpool/pgpool.log 2>&1 &' postgres
pgpool -n > /var/log/pgpool/pgpool.log 2>&1 &
