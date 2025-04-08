
gcloud services enable cloudscheduler.googleapis.com

gcloud storage cp -r gs://spls/gsp649/* . && cd gcf-automated-resource-cleanup/

gcloud storage cp -r gs://spls/gsp649/* . && cd gcf-automated-resource-cleanup/

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
WORKDIR=$(pwd)

sudo apt-get update
sudo apt-get install apache2-utils -y

cd $WORKDIR/migrate-storage

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
gcloud storage buckets create  gs://${PROJECT_ID}-serving-bucket -l $REGION

gsutil acl ch -u allUsers:R gs://${PROJECT_ID}-serving-bucket

gcloud storage cp $WORKDIR/migrate-storage/testfile.txt  gs://${PROJECT_ID}-serving-bucket

gsutil acl ch -u allUsers:R gs://${PROJECT_ID}-serving-bucket/testfile.txt

curl http://storage.googleapis.com/${PROJECT_ID}-serving-bucket/testfile.txt

gcloud storage buckets create gs://${PROJECT_ID}-idle-bucket -l $REGION
export IDLE_BUCKET_NAME=$PROJECT_ID-idle-bucket
