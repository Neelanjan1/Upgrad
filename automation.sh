#!/bin/bash

#Update the repo list.
sudo apt update -y

#Check if package is installed and if not install it.
REQUIRED_PKG="apache2"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

# List the apache2 service considering it to be running and active
systemctl list-units --type=service --state=active | grep $REQUIRED_PKG

#Create link of /etc/init.d/apache2 in /etc/rc5.d in order to start the service when runlevel is loaded.
#Also check and enable service.
update-rc.d apache2 defaults
echo "Updated runlevel to start service on boot"

service_enable=$(systemctl is-enabled $REQUIRED_PKG)
if [ "$service_enable" = "disabled" ]; then
	systemctl enable $REQUIRED_PKG
fi
echo "service enable check stage done"

#If apache2 service is not running , start the service.

if (( $(ps -ef | grep -v grep | grep $REQUIRED_PKG | wc -l) > 0 ))
then
echo "$REQUIRED_PKG is running!!!"
else
/etc/init.d/$REQUIRED_PKG start
fi
echo "service running check stage done"
echo "next tar and copy to S3"

#create log file archive and upload to S3 bucket.
myname=Neelanjan
s3_bucket=upgrad-neelanjan
timestamp=$(date '+%d%m%Y-%H%M%S')
tar -cvzf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
