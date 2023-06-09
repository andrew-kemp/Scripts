#Backup Webiste, Database and config
#Created by Andrew Kemp
#11th May 2023
#Version 1.0

#Variables
Azure_Blob="https://andykempstorage.blob.core.windows.net/pibackup?sp=rwl&st=2023-05-11T08:09:39Z&se=2024-05-08T16:09:39Z&spr=https&sv=2022-11-02&sr=c&sig=h8uf4LYgm3t2WH9%2FFRB0PB7qN7jnbosHik6o5nrpl2s%3D"
Today=$(date +%A)
Web_Config="/etc/apache2/sites-available/www.andrewkemp.co.uk.conf"
DB_Name="db_andrewkemp"
Postfix_Config="/etc/postfix/main.cf"
SASL_Passwd="/etc/postfix/sasl_passwd"
Temp_Backup="/temp_backup"
Website_Path="/var/www/www.andrewkemp.co.uk"


#Creat the temp backup folder
mkdir $Temp_Backup

# Create Archive with Website data and config files
tar -cpvzf $Temp_Backup"/"$Today".tar.gz" $Website_Path $Web_Config $Postfix_Config $SASL_Passwd

#Backup the Open VPN Access Server config
tar -cpvzf $Temp_Backup"/"$Today"-OpenVPN-AS.tar.gz" /usr/local/openvpn_as/etc/db/config.db /usr/local/openvpn_as/etc/db/certs.db /usr/local/openvpn_as/etc/db/userprop.db /usr/local/openvpn_as/etc/db/log.db /usr/local/openvpn_as/etc/as.conf /usr/local/openvpn_as/etc/db/userprop.db

#Backup the Database
mysqldump $DB_Name > $Temp_Backup"/"$DB_Name"-"$Today".sql"

#Uploaid the files to Azure Blob Storage
echo uploading to Azure
az storage blob upload-batch --destination $Azure_Blob --source $Temp_Backup --overwrite
clear
#Clearing Temp Backup
echo "Removing the local temp files"
rm -r -f $Temp_Backup
echo "Files removed"
echo "Backup has been run" | mail -s "Server Backup" -r wordpress@andrewkemp.co.uk andrew@kemponline.co.uk
