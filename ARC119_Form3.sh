export REGION="${ZONE%-*}"
bq mk --location=US Raw_data

bq load --source_format=AVRO Raw_data.public-data gs://spls/gsp1145/users.avro

gcloud dataplex zones create temperature-raw-data \
    --lake=public-lake \
    --location=$REGION \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --display-name="temperature-raw-data"

gcloud dataplex assets create customer-details-dataset \
    --location=$REGION \
    --lake=public-lake \
    --zone=temperature-raw-data \
    --resource-type=BIGQUERY_DATASET \
    --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
    --display-name="Customer Details Dataset" \
    --discovery-enabled

gcloud data-catalog tag-templates create protected_data_template \
    --location=$REGION \
    --display-name="Protected Data Template" \
    --field=id=protected_data_flag,display-name="Protected Data Flag",type='enum(Yes|No)',required=TRUE

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/dataplex/search?project=$DEVSHELL_PROJECT_ID&q=us-states&qSystems=BIGQUERY""${RESET}"
