INSTANCE_NAME=bitbucket-dc-primary
INSTANCE_TYPE=bitbucket-dc
BITBUCKET_URL=http://internal-danny-bbdc-524433867.ap-southeast-2.elb.amazonaws.com/

BITBUCKET_UID=atlbitbucket
BITBUCKET_GID=atlbitbucket

BACKUP_DISK_TYPE=amazon-ebs
BACKUP_DATABASE_TYPE=postgresql-fslevel
BACKUP_ARCHIVE_TYPE=aws-snapshots
case ${BACKUP_DATABASE_TYPE} in
 postgresql-fslevel)
        # The postgres service name for stopping / starting it at restore time.
        POSTGRESQL_SERVICE_NAME="postgresql"
        ;;
esac
BACKUP_ZERO_DOWNTIME=true

EBS_VOLUME_MOUNT_POINT_AND_DEVICE_NAMES=(/var/atlassian/application-data/bitbucket/datastore:/dev/sdz /var/atlassian/application-data/bitbucket:/dev/sdb)
HOME_DIRECTORY_MOUNT_POINT=/var/atlassian/application-data/bitbucket

RESTORE_DISK_VOLUME_TYPE=gp3
CURL_OPTIONS="-L -s -f"
# Fetch an AWS EC2 metadata token
TOKEN=$(curl -L -s -f -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch instance identity document using the token
AWS_INFO=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/dynamic/instance-identity/document")

# Extract information using jq
AWS_ACCOUNT_ID=$(echo "${AWS_INFO}" | jq -r .accountId)
AWS_AVAILABILITY_ZONE=$(echo "${AWS_INFO}" | jq -r .availabilityZone)
AWS_REGION=$(echo "${AWS_INFO}" | jq -r .region)
AWS_EC2_INSTANCE_ID=$(echo "${AWS_INFO}" | jq -r .instanceId)

# Additional tags variable (ensure this is set if needed)
AWS_ADDITIONAL_TAGS= # Set this variable if you need additional tags

# Output the extracted information (for debugging or usage purposes)
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Availability Zone: $AWS_AVAILABILITY_ZONE"
echo "AWS Region: $AWS_REGION"
echo "AWS EC2 Instance ID: $AWS_EC2_INSTANCE_ID"

BITBUCKET_VERBOSE_BACKUP=true

AWS_XEN_INSTANCE_TYPES=("M1" "M2" "M3" "M4" "T1" "T2" "C1" "C3" "C4" "R3" "R4" "X1" "X1e" "D2" "H1" "I2" "I3" "F1" "G3" "P2" "P3")
AWS_EC2_INSTANCE_TYPE=$(echo "${AWS_INFO}" | jq -r .instanceType)
KEEP_BACKUPS=5
FILESYSTEM_TYPE=xfs
FSFREEZE=true
