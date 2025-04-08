cat $WORKDIR/migrate-storage/main.py | grep "migrate_storage(" -A 15

sed -i "s/<project-id>/$PROJECT_ID/" $WORKDIR/migrate-storage/main.py

gcloud services disable cloudfunctions.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/artifactregistry.reader"

gcloud functions deploy migrate_storage --gen2 --trigger-http --runtime=python39 --region $Region

export FUNCTION_URL=$(gcloud functions describe migrate_storage --format=json --region $Region | jq -r '.url')

export IDLE_BUCKET_NAME=$PROJECT_ID-idle-bucket
sed -i "s/\\\$IDLE_BUCKET_NAME/$IDLE_BUCKET_NAME/" $WORKDIR/migrate-storage/incident.json

envsubst < $WORKDIR/migrate-storage/incident.json | curl -X POST -H "Content-Type: application/json" $FUNCTION_URL -d @-

gsutil defstorageclass get gs://$PROJECT_ID-idle-bucket
