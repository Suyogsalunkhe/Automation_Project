pkg=apache2
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install $pkg
fi
echo "Package check with apache2 completed"

# To check  whether Apache Server is enabled
apache2_check="$(systemctl status apache2.service | grep Active | awk {'print $3'})"
if [ "${apache2_check}" = "(dead)" ]; then
        systemctl enable apache2.service
        echo "service has been enabled"
fi

#To check whether Apache2 service is running and if not running then to start the service
ServiceStatus="$(systemctl is-active apache2.service)"
if [ "${ServiceStatus}" = "active" ]; then
        echo "Apache2 running fine"
else
    sudo systemctl start apache2
    echo "service has been started"
fi

#To check Status of the Service
sudo systemctl status apache2
echo  "Status of the Service has been checked"

#To check whether AWS CLI is installed and if its not installed then to install itpkg=apache2
pkgcheck=awscli
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkgcheck" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install $pkgcheck
fi
echo "Package check with awscli completed"

# To create the Tar file and copy to S3 Bucket
#!/bin/bash
s3_bucket="upgrad-suyog"
myname="Suyog"
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2/
find -name "*.log" | tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar  /var/log/apache2
Size=$(du -sh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}' )
echo "Tar file  has been created at specific location"
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://$s3_bucket/${myname}-httpd-logs-${timestamp}.tar
echo "Tar file with logs has been copied to AWSS3 bucket"

#Task 3
#!/bin/bash

#To check whether cron Job file is present in /var/www/html/ and if not present then to create the file
if [[ ! -e /var/www/html/inventory.html ]]; then
    > /var/www/html/inventory.html
fi
echo "Inventory.html File Check completed successfully"


# To get the details from S3 bucket and push to Inventory.html
aws s3 ls s3://upgrad-suyog | tee -a inventory.html
echo "S3 Bucket details pushed in Inventory.html successfully"

# To check whether cron Job file is present in /etc/cron.d/ and if not present then to create the file with asked details
if [ ! -f "/etc/cron.d/automation" ]
then
        echo "* * * * * root    /root/Automation_Project/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi
