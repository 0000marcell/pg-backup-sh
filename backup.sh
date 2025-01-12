#!/bin/bash

source "$HOME/your_project_env_vars.sh"

DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_HOST=$DB_HOST
PGPASSWORD=$PGPASSWORD
S3_BUCKET=$S3_BUCKET
S3_PATH=$S3_PATH
BACKUP_DIR="$HOME/backups"
LOG_FILE="$HOME/backup.log"
TIMESTAMP=$(date +'%Y%m%d%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql"

# Ensure the log file exists
touch "$LOG_FILE"

# Log function
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log_message "ERROR: AWS CLI is not installed. Please install it and re-run the script."
    exit 1
fi

# Check if AWS credentials are set up
aws sts get-caller-identity &> /dev/null
if [ $? -ne 0 ]; then
    log_message "AWS credentials are not configured. Setting keys now"

    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
    aws configure set default.region "$AWS_DEFAULT_REGION"

    log_message "AWS credentials have been configured."
fi

# Create backups directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_message "Created backup directory: $BACKUP_DIR"
fi

# Export the PostgreSQL password
if [ -z "$PGPASSWORD" ]; then
    log_message "ERROR: PGPASSWORD environment variable not set. Exiting."
    exit 1
fi

# Backup the PostgreSQL database
log_message "Starting database backup for '$DB_NAME'..."
PGPASSWORD=$PGPASSWORD pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -F c -v -f "$BACKUP_FILE" "$DB_NAME" 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    log_message "Database backup completed successfully. File saved at: $BACKUP_FILE"
else
    log_message "ERROR: Database backup failed. Check the log for details."
    exit 1
fi

# Upload the backup to S3
log_message "Uploading backup to S3 bucket: s3://$S3_BUCKET/$S3_PATH"
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/$S3_PATH" --storage-class STANDARD_IA 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    log_message "Backup uploaded successfully to S3: s3://$S3_BUCKET/$S3_PATH"
else
    log_message "ERROR: Failed to upload backup to S3. Check the log for details."
    exit 1
fi

log_message "Backup script completed."
