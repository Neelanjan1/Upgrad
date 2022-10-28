myname=Neelanjan
s3_bucket=upgrad-neelanjan
timestamp=$(date '+%d%m%Y-%H%M%S')
tar -cvzf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
