#!/usr/bin/env bash



DEST_DIR=$1
if [ x"$DEST_DIR" == x ]
then
        echo "Usage $0 dest_dir"
        exit
fi
check_soft()
{
if hash $1 >/dev/null; then
        echo "$1 exist" 
else
        echo "$1 does not exist"
        exit 11
fi
}
e_r()
{
if [ $? != 0 ]
then
        echo -e "\e[00;31m$1\e[00m"
        if [ x"$2" != x ] 
        then
                echo -e "\e[00;31mBackup file - $2 \e[00m"
        fi
        exit 1
fi
}

check_soft optipng
check_soft jpegoptim

if [ x"$DEST_DIR" != x ]
then
        PNG_LIST=`find "$DEST_DIR" -iname "*.png"`
        COUNT_PNG=`echo "$PNG_LIST"|wc -l`
        CP=1
        if [ x"$PNG_LIST" == x ]
        then
               echo "You not have PNG files"
        else
        echo "$PNG_LIST"|while read i
                do
                        BACKUP_FILE=`mktemp`
                        e_r "Cannot create backup file for $i"
                        echo -e "\e[00;33m Optimization for file $i - start. $CP from $COUNT_PNG \e[00m"
                        cp "$i" "$BACKUP_FILE"
                        e_r "Cannot copy backup file for $i"
                        MTIME=`stat -c %y "$i"|awk -F"+" '{print $1}'`
                        e_r "Cannot get timestamp for $i"
                        UOWN=`stat -c %u "$i"`
                        e_r "Cannot get user for $i"
                        GOWN=`stat -c %g "$i"`
                        e_r "Cannot get group for $i"
                        FR=`stat -c %a "$i"`
                        e_r "Cannot get access right for $i"
                        optipng -silent -fix -full -o7 -strip all "$BACKUP_FILE" >/dev/null 
                        #optipng -fix -full -o7 "$BACKUP_FILE" >/dev/null 
                        e_r "Cannot optimize $i"
                        mv "$BACKUP_FILE" "$i"
                        e_r "Cannot copy backup file to src $BACKUP_FILE $i"
                        chmod "$FR" "$i"
                        e_r "Cannot change access right for $i"
                        chown "$UOWN":"$GOWN" "$i"
                        e_r "Cannot change user and group for $i"
                        touch -d "$MTIME" "$i"
                        MTIMEN=`stat -c %y "$i"|awk -F"+" '{print $1}'`
                        UOWNN=`stat -c %u "$i"`
                        GOWNN=`stat -c %g "$i"`
                        FRN=`stat -c %a "$i"`
                        echo -e "\e[00;32m Optimization for file $i - complete. $CP from $COUNT_PNG \e[00m"
                        CP=$((CP+1))
                done
        fi
        JPG_LIST=`find "$DEST_DIR" -iname "*.jpg" -or -iname "*.jpeg"`
        COUNT_JPG=`echo "$JPG_LIST"|wc -l`
        JP=1
        if [ x"$JPG_LIST" == x ]
        then
               echo "You not have JPG files"
        else
                echo "$JPG_LIST"|while read i
                        do
                        BACKUP_FILE=`mktemp`
                        e_r "Cannot create backup file for $i"
                        echo -e "\e[00;33m Optimization for file $i - start. $JP from $COUNT_JPG \e[00m"
                        cp "$i" "$BACKUP_FILE"
                        e_r "Cannot copy for backup file $i"
                        MTIME=`stat -c %y "$i"|awk -F"+" '{print $1}'`
                        e_r "Cannot get timestamp for $i"
                        UOWN=`stat -c %u "$i"`
                        e_r "Cannot get user for $i"
                        GOWN=`stat -c %g "$i"`
                        e_r "Cannot get group for $i"
                        FR=`stat -c %a "$i"`
                        e_r "Cannot get access right for $i"
                        jpegoptim --strip-all "$BACKUP_FILE" >/dev/null
                        e_r "Cannot optimize $i"
                        mv "$BACKUP_FILE" "$i"
                        e_r "cannot move backup file to src $BACKUP_FILE -> $i"
                        chmod "$FR" "$i"
                        e_r "Cannot change access right for $i"
                        chown "$UOWN":"$GOWN" "$i"
                        e_r "Cannot change user and group for $i"
                        touch -d "$MTIME" "$i"
                        MTIMEN=`stat -c %y "$i"|awk -F"+" '{print $1}'`
                        UOWNN=`stat -c %u "$i"`
                        GOWNN=`stat -c %g "$i"`
                        FRN=`stat -c %a "$i"`
                        echo -e "\e[00;32m Optimization for file $i - complete. $JP from $COUNT_JPG \e[00m"
                        JP=$((JP+1))
                done
        fi
else
        echo "USAGE: $0 dest_dir"
fi
