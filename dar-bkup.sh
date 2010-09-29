#!/bin/bash
###DO NOT EDIT!###########
LANG=C
DATE=`/bin/date '+%Y%m%d'`
COUNT=`/bin/date '+%a'`
GEN=0
##########################

BKUPDIR='/mnt/'
HOSTNAME=`/bin/hostname`

###FULL BKUP DAY###
COUNT2='Sat'

###BKUP GENERATION###
BKUPGEN='2'     #weeks(Don't select 0)

###BKUP DIR###
HOME='/home'
VAR='/var'
ETC='/etc'
USR='/usr'
ROOT='/root'

###BKUP DIR NAME###
LIST='etc home usr var root'

###EXCLUDE DIR###
NOHOME='-P nnet/'
NOVAR='-P log/'
NOETC=''
NOUSR='-P local/src/ -P lib/ -P local/lib/'
NOROOT=''

###NO COMPRESS###
OPTIONS='-y -Z "*.png" -Z "*.gz" -Z "*.jpg"'

###MAIL SEND###
backup_finish_mail_send () {
        /bin/ls -lh $BKUPDIR/$HOSTNAME/* | mail -s "**backup@`/bin/hostname`**" backup@nnetworks.jp
}

###DIR CHECK & MKDIR###
for DIR in $LIST
        do
                if [ ! -d $BKUPDIR/$HOSTNAME/$DIR ] ;then
                        /bin/mkdir -p $BKUPDIR/$HOSTNAME/$DIR
                fi
        done
while [ $GEN != $BKUPGEN ];
        do
                if [ $GEN = "0" ]; then
                        for DIR2 in $LIST
                                do
                                        if [ ! -d $BKUPDIR/$HOSTNAME/bkup_lastweek/$DIR2 ] ;then
                                                /bin/mkdir -p $BKUPDIR/$HOSTNAME/bkup_lastweek/$DIR2
                                        fi
                                done
                        GEN=`expr $GEN + 1`
                fi
                if [ $BKUPGEN = 1 ]; then
                        break
                fi
                WEK=`expr $GEN + 1`     
                for DIR3 in $LIST
                        do
                                if [ ! -d $BKUPDIR/$HOSTNAME//bkup_${WEK}weeks_ago/$DIR3 ] ;then
                                        /bin/mkdir -p $BKUPDIR/$HOSTNAME/bkup_${WEK}weeks_ago/$DIR3
                                fi
                        done
                        GEN=`expr $GEN + 1`
        done

###OLD BKUP MV & DELETE###
mv_old_bkup () {
        for LIST3 in $LIST
                do
                        BKUPWEK=$BKUPGEN
                        while [ $BKUPWEK != 1 ];
                                do      
                                        if [ $BKUPWEK = 2 ]; then
                                                /bin/mv -if $BKUPDIR/$HOSTNAME/bkup_lastweek/$LIST3/* $BKUPDIR/$HOSTNAME/bkup_${BKUPWEK}weeks_ago/$LIST3/
                                                break
                                        fi
                                        BKUPWEK2=`expr $BKUPWEK - 1`
                                        /bin/mv -if $BKUPDIR/$HOSTNAME/bkup_${BKUPWEK2}weeks_ago/$LIST3/* $BKUPDIR/$HOSTNAME/bkup_${BKUPWEK}weeks_ago/$LIST3/
                                        BKUPWEK=`expr $BKUPWEK - 1`
                                done
                        /bin/mv -if $BKUPDIR/$HOSTNAME/$LIST3/* $BKUPDIR/$HOSTNAME/bkup_lastweek/$LIST3/
                done
}

rm_old_bkup () {
                if [ $BKUPGEN = "1" ]; then
                        /bin/rm -rf $BKUPDIR/$HOSTNAME/bkup_lastweek/*
                else
                        /bin/rm -rf $BKUPDIR/$HOSTNAME/bkup_${BKUPGEN}weeks_ago
                fi
}

################
COUNT_H=`/bin/ls -tr $BKUPDIR/$HOSTNAME/home/ |  /bin/grep '.dar' | tail -n 1 | sed -e s/.1.dar// | awk -F '-' '{print $2;}' | sed -e s/L//`
COUNT_V=`/bin/ls -tr $BKUPDIR/$HOSTNAME/var/ |  /bin/grep '.dar' | tail -n 1 | sed -e s/.1.dar// | awk -F '-' '{print $2;}' | sed -e s/L//`
COUNT_E=`/bin/ls -tr $BKUPDIR/$HOSTNAME/etc/ |  /bin/grep '.dar' | tail -n 1 | sed -e s/.1.dar// | awk -F '-' '{print $2;}' | sed -e s/L//`
COUNT_U=`/bin/ls -tr $BKUPDIR/$HOSTNAME/usr/ |  /bin/grep '.dar' | tail -n 1 | sed -e s/.1.dar// | awk -F '-' '{print $2;}' | sed -e s/L//`
COUNT_R=`/bin/ls -tr $BKUPDIR/$HOSTNAME/root/ |  /bin/grep '.dar' | tail -n 1 | sed -e s/.1.dar// | awk -F '-' '{print $2;}' | sed -e s/L//`

Y_HOME=`/bin/ls $BKUPDIR/$HOSTNAME/home/ | /bin/grep 'L0' | awk -F '.' '{print $1;}'`
Y_VAR=`/bin/ls $BKUPDIR/$HOSTNAME/var/ | /bin/grep 'L0' | awk -F '.' '{print $1;}'`
Y_ETC=`/bin/ls $BKUPDIR/$HOSTNAME/etc/ | /bin/grep 'L0' | awk -F '.' '{print $1;}'`
Y_USR=`/bin/ls $BKUPDIR/$HOSTNAME/usr/ | /bin/grep 'L0' | awk -F '.' '{print $1;}'`
Y_ROOT=`/bin/ls $BKUPDIR/$HOSTNAME/root/ | /bin/grep 'L0' | awk -F '.' '{print $1;}'`

T_HOME=`/usr/bin/expr "$COUNT_H" + "1"`
T_VAR=`/usr/bin/expr "$COUNT_V" + "1"`
T_ETC=`/usr/bin/expr "$COUNT_E" + "1"`
T_USR=`/usr/bin/expr "$COUNT_U" + "1"`
T_ROOT=`/usr/bin/expr "$COUNT_R" + "1"`
################

###BKUP START###
if [ "$COUNT" = "$COUNT2" ] ;then
        mv_old_bkup
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/var/var-L0-$DATE -R $VAR $NOVAR > /dev/null
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/etc/etc-L0-$DATE -R $ETC $NOETC > /dev/null
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/usr/usr-L0-$DATE -R $USR $NOUSR > /dev/null
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/home/home-L0-$DATE -R $HOME $NOHOME > /dev/null
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/root/root-L0-$DATE -R $ROOT $NOROOT > /dev/null
        rm_old_bkup
else 
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/var/var-L$T_VAR-$DATE -R $VAR $NOVAR -A $BKUPDIR/$HOSTNAME/var/$Y_VAR > /dev/null 
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/etc/etc-L$T_ETC-$DATE -R $ETC $NOETC -A $BKUPDIR/$HOSTNAME/etc/$Y_ETC > /dev/null 
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/usr/usr-L$T_USR-$DATE -R $USR $NOUSR -A $BKUPDIR/$HOSTNAME/usr/$Y_USR > /dev/null 
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/home/home-L$T_HOME-$DATE -R $HOME $NOHOME -A $BKUPDIR/$HOSTNAME/home/$Y_HOME > /dev/null
        /usr/local/bin/dar $OPTIONS -c $BKUPDIR/$HOSTNAME/root/root-L$T_ROOT-$DATE -R $ROOT $NOROOT -A $BKUPDIR/$HOSTNAME/root/$Y_ROOT > /dev/null
fi

###MAIL SEND###
#backup_finish_mail_send

###END###----------------------------------------------------------
