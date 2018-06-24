This image contains everything needed to run Helmfile against Google Cloud Platform:

- [google](https://github.com/GoogleCloudPlatform/cloud-sdk-docker) binaries (to authenticate to your Kubernetes cluster);
- [helm](https://github.com/kubernetes/helm);
- [helm-diff](https://github.com/databus23/helm-diff);
- [helm-secrets](https://github.com/futuresimple/helm-secrets);
- [helmfile](https://github.com/roboll/helmfile);

How to use?
===========
Script expects to find 4 environment variables:

* `GOOGLE_APPLICATION_CREDENTIALS`, which points to a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys);
* `GCLOUD_CLUSTER_NAME` with a name of a cluster to authenticate to;
* `GCLOUD_CLUSTER_ZONE` with a zone where cluster is located;
* `GCLOUD_PROJECT_ID` with a project ID where cluster was created;

Examples
========

This is the basic invocation:
```
docker run -e GCLOUD_CLUSTER_NAME="my-test-cluster" -e GCLOUD_CLUSTER_ZONE="us-west1-a" -e GCLOUD_PROJECT_ID="awesome-project-123712" -e GOOGLE_APPLICATION_CREDENTIALS="/credentials.json" -v /temp/credentials.json:/credentials.json -v /temp:/src amnk/gcloudhelm:latest --file /src/helmfile.yaml sync
```

This image can also be used in [Concourse CI](https://concourse-ci.org/) task:
```
- task: run-helmfile
  params:
    GCLOUD_CLUSTER_NAME: my-test-cluster
    GCLOUD_CLUSTER_ZONE: us-west1-a
    GCLOUD_PROJECT_ID: awesome-project-123712
    GOOGLE_APPLICATION_CREDENTIALS: ((concourse-sa-json))
  config:
    inputs:
      - name: src
      - name: version
    platform: linux
    image_resource:
      type: docker-image
      source:
        repository: amnk/gcloudhelm
        tag: latest
    run:
      path: sh
      args:
        - -exc
        - |
          export CURRENT_VERSION=`cat version/version`
          set +x
          echo ${GOOGLE_APPLICATION_CREDENTIALS} > credentials.json
          set -x
          gcloud auth activate-service-account --key-file credentials.json
          gcloud --project ${GCLOUD_PROJECT_ID} container clusters get-credentials ${GCLOUD_CLUSTER_NAME} --zone ${GCLOUD_CLUSTER_ZONE}
          helm init --client-only
          /usr/local/bin/helmfile --file src/helmfile.yaml --selector sync --args --set image.version=${CURRENT_VERSION}
```
where `((concourse-sa-json))` is taken from [params](https://concoursetutorial.com/basics/parameters/) 
