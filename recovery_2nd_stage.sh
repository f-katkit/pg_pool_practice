#!/bin/bash

MASTER_BASEDIR=$1
RECOVERY_HOST=$2
RECOVERY_BASEDIR=$3
WAL_DIR='/backup/postgresql/wal_archives/'

psql -c 'SELECT pg_switch_xlog()' postgres

rsync -az --delete -e "ssh -o 'StrictHostKeyChecking no'"  $WAL_DIR $RECOVERY_HOST:$WAL_DIR
