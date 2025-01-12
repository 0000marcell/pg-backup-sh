# PG Backup SH

Simple db backup script, create a db backup and saves on s3

## Configuration

you need to fill your credentials here $HOME/your_project_env_vars.sh, you should change this path to use the name of your project so can have multiple projects with different credentials

these are the credentials that you need to add

```
DB_NAME=<your_db_name>
DB_USER=<your_db_user>
DB_HOST=<your_db_host>
DB_PORT=<your_db_port>
PGPASSWORD=<your_db_password>
S3_BUCKET=<your_s3_bucket>
S3_PATH=<your_s3_path>
```

* by default it saves all backups in $HOME/backups
* you can check the logs in $HOME/backup.log

after configuring you should try to run once to see if everything is working
it should produce a dump of your db that you can then load with pg_dump as well

after confirming it's working you can configure crontab to run it daily
move this shell script to your project folder in your server and configure contab 

```
# to open crontab configuratio on linux
crontab -e
# add this to the crontab file
0 2 * * * $HOME/your-project/backup.sh >> $HOME/your-project-backup.log 2>&1
```
