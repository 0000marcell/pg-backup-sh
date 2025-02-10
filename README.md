# PG Backup SH

Simple db backup script, create a db backup and saves on s3

## Configuration

copy backup.sh to your project root directory commit the file so you can run a backup wherever you are.

then you need to fill your credentials here $HOME/your_project_env_vars.sh, you should change this path to use the name of your project so it's possible to have multiple projects with different credentials

```Bash
DB_NAME=<your_db_name>
DB_USER=<your_db_user>
DB_HOST=<your_db_host>
DB_PORT=<your_db_port>
PGPASSWORD=<your_db_password>
S3_BUCKET=<your_s3_bucket>
S3_PATH=<your_s3_path>
# the following are optional, only if they're not set already
AWS_ACCESS_KEY_ID=<your_key_id>
AWS_SECRET_ACCESS_KEY=<your_access_key>
AWS_DEFAULT_REGION=<your_region>
```

After setting the credentials you can run
```
bash backup.sh
```

check the logs at `$HOME/backup.log` to see what happened if something goes wrong 

* by default it saves all backups in $HOME/backups
* you can check the logs in $HOME/backup.log

after configuring you should try to run once to see if everything is working
it should produce a dump of your db that you can then load with pg_dump as well

after confirming it's working you can configure crontab to run it daily
move this shell script to your project folder in your server and configure contab 

```Bash
# to open crontab configuratio on linux
crontab -e
# add this to the crontab file
0 2 * * * $HOME/your-project/backup.sh >> $HOME/your-project-backup.log 2>&1
```

# Restore the backup

```
pg_restore -U <user> -d <your_db_name> <generated_file.sql>
```
