#!/bin/bash
#global Variables
backupdir="/mysql_backup";
retention_daily="6";
retention_weekly="4"
weekday="monday";
retention_monthly="2"


if [ $# -gt 0 ]; then
#fetching current date for creating compressed file name
date=$(date +%d-%m-%Y);
retention_weekly=$(( 7 * $retention_weekly ));
#fetching databse 
candidates=$(echo "show databases" | mysql | grep -Ev "^(Database|mysql|sys|performance_schema|information_schema)$");

    mkdir -p "$backupdir/daily" "$backupdir/weekly" "$backupdir/monthly"; #making necessary directories to backup

  

    if [ $1 = 'daily' ]; then
        mkdir -p "$backupdir/daily/$date";
        cd "$backupdir/daily/";
        for i in $candidates; do echo -e "\nDumping : $i"; mysqldump --single-transaction $i > $backupdir/daily/$date/"$i".sql; done;
        echo -e "Creating Compressed Archive";
        tar -czvf $date.tar.gz $date;
        echo -e "Removing Temporary dump files";
        rm -rvf $date;
        DEL=$(date -d "$retention_daily days ago" '+%d-%m-%Y');
        echo -e "\n Running retention and deleting old backup";
        rm -vf $DEL.tar.gz;
        echo -e "\n Daily Backup generated\n\n\n";

    elif [ $1 = 'weekly' ]; then
        mkdir -p "$backupdir/weekly/$date";
        cd $backupdir/weekly/;
        for i in $candidates; do echo -e "\nDumping : $i"; mysqldump --single-transaction $i > $backupdir/weekly/$date/"$i".sql; done;
        echo -e "Creating Compressed Archive";
        tar -czvf $date.tar.gz $date
        echo -e "Removing Temporary dump files";
        rm -rvf $date;
        DEL=$(date -d "$weekday-$(($retention_weekly)) days" '+%d-%m-%Y');
        echo -e "\n Running retention and deleting old backup";
        rm -vf $DEL.tar.gz;
        echo -e "\n Weekly Backup generated\n\n\n";

    elif [ $1 = 'monthly' ]; then
        mkdir -p "$backupdir/monthly/$date";
        cd $backupdir/monthly/;
        for i in $candidates; do echo -e "\nDumping : $i"; mysqldump --single-transaction $i > $backupdir/monthly/$date/"$i".sql; done;
        echo -e "Creating Compressed Archive";
        tar -czvf $date.tar.gz $date
        echo -e "Removing Temporary dump files";
        rm -rvf $date;
        DEL=$(date -d "`date +%Y%m01` -$(($retention_monthly)) month" '+%d-%m-%Y');
        echo -e "\n Running retention and deleting old backup";
        rm -fv $DEL.tar.gz;
        echo -e "\n Monthly Backup generated\n\n\n";
    else
        echo -e "\n Invalid arguments : expected [daily|weekly|monthly]\n\n";
        exit 2;
    fi
else
    echo -e "\n Incorrect usage, arguments expected : $0 [daily|weekly|monthly]\n\n";
fi
