export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/storage.admin

gcloud dataproc clusters create qlab \
    --enable-component-gateway \
    --region $REGION \
    --zone $ZONE \
    --master-machine-type e2-standard-4 \
    --master-boot-disk-type pd-balanced \
    --master-boot-disk-size 100 \
    --num-workers 2 \
    --worker-machine-type e2-standard-2 \
    --worker-boot-disk-size 100 \
    --image-version 2.2-debian12 \
    --project $DEVSHELL_PROJECT_ID

gcloud dataproc jobs submit spark \
    --cluster qlab \
    --region $REGION \
    --class org.apache.spark.examples.SparkPi \
    --jars file:///usr/lib/spark/examples/jars/spark-examples.jar \
    -- 1000
