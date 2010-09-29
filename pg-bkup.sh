#!/bin/sh

DATE=`date +%Y%m%d`
DATE2=`date --date '2 weeks ago' '+%Y%m%d'`
DIR="/mnt/`/bin/hostname`/pgqsql"
PG=`/usr/bin/which psql`
PGD=`/usr/bin/which pg_dump`

if [ ! -d $DIR ] ;then
        mkdir -p $DIR
fi

for A in `$PG -l -U postgres | sed -e "1,3d" | sed -e "\$d" | sed -e "\$d"`
        do
                $PGD -U postgres $A > $DIR/$A-$DATE.sql
                gzip  $DIR/$A-$DATE.sql
        done

$PGD -U postgres > $DIR/dumpall-$DATE.sql

rm -f $DIR/*-$DATE2.sql.gz
