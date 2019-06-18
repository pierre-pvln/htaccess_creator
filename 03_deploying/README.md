# README file for the .htaccess building blocks deployment scripts

Goto to the _06_scripts/_htaccess folder of the site and get the required file from github. 

```batchfile
set domainname=<domain>
:: get deploy script
curl https://raw.githubusercontent.com/pierre-pvln/htaccess_creator/master/03_deploying/01_deploy_to_%domainname%.cmd --output 01_deploy_to_%domain%.cmd --remote-time
01_deploy_to_%domainname%.cmd
```
