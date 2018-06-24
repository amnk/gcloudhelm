#!/bin/bash

gcloud auth activate-service-account --key-file ${GOOGLE_APPLICATION_CREDENTIALS}
gcloud --project ${GCLOUD_PROJECT_ID} container clusters get-credentials ${GCLOUD_CLUSTER_NAME} --zone ${GCLOUD_CLUSTER_ZONE}

helm init --client-only

/usr/local/bin/helmfile $@
