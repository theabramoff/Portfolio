sudo find /opt/backup -name "sausage-store.jar" -type f -mtime +1 -delete # delete all .jar files older then 1 day - 24 copies in total will be deleted which does meet the task condition
sudo find /opt/backup/* -name "backup_*" -type d -mtime +1 -delete # clean up backup catalogs, just in case

