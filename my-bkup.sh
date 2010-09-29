#!/bin/sh

DATE=`date +%Y%m%d`
DATE2=`date --date='2 weeks ago' '+%Y%m%d'`
DIR="/mnt/`/bin/hostname`/mysql"
MY=`/usr/bin/which mysql`
MYD=`/usr/bin/which mysqldump`

if [ ! -d $DIR ] ;then
        mkdir -p $DIR
fi

for A in `$MY -u root -e 'show databases \G'  | grep Database | awk '{print $2}' | grep -v information_schema`
        do
                $MYD -u root $A  | gzip > $DIR/${A}_$DATE.sql.gz
        done

$MYD -u root --all-databases > $DIR/my-dumpall_$DATE.sql.gz

rm -rf $DIR/*_$DATE2.sql.gz
