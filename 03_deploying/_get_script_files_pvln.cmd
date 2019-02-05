:: retrieve required files from github
curl https://raw.githubusercontent.com/pierre-pvln/htaccess_creator/master/03_deploying/01_deploy_to_pvln.cmd --output 01_deploy_to_pvln.cmd --remote-time
curl https://raw.githubusercontent.com/pierre-pvln/htaccess_creator/master/03_deploying/05_deploy_files.cmd --output 05_deploy_files.cmd --remote-time
curl https://raw.githubusercontent.com/pierre-pvln/htaccess_creator/master/03_deploying/ftp_get_file.cmd --output ftp_get_file.cmd --remote-time
curl https://raw.githubusercontent.com/pierre-pvln/htaccess_creator/master/03_deploying/ftp_put_file.cmd --output ftp_put_file.cmd --remote-time
