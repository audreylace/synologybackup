#!/bin/bash

# Need this to support crontab
cd "$(dirname "$0")"

NOW=$(date '+%s')
SRCPATH=
USERNAME=
BACKUPSERVER=
DSTPATH=

# Support for systems that hibernate
#
#LASTRUN=$(date -r './last-backup' '+%s')
#DIFF=$(expr $NOW - $LASTRUN)
#
#
#if ((DIFF > 3600)); then
#echo 1 > "./last-backup"

TODAY=$( date '+%Y.%m.%d.%H.%M.%S')
rsync -aq --log-file="./logs/backup-$TODAY.log" --delete --exclude-from="./backup-exclude-list" -e "sshpass -f './password' ssh" $SRCPATH $USERNAME@$BACKUPSERVER:$DSTPATH


# Log rotation support
#
LASTROTATE=$(date -r './last-rotate' '+%s')

# Do rotation every 7 days
#
if (($(expr $NOW - $LASTROTATE) > 604800)); then 

 echo 1 > "./last-rotate"
 echo "Checking for logs to archive"

 if find ./logs -maxdepth 1 -mtime +7 -type f -exec false {} +
 then
  echo "No logs to archive"
 else
  echo "Found logs to archive"
  find ./logs -maxdepth 1 -mtime +7 -type f -print0 | tar -czvf ./logs/archive/oldlogs_$TODAY.tar.gz --remove-files --null -T /dev/stdin
 fi
else
 echo "Too early for log rotation"
fi

#fi
