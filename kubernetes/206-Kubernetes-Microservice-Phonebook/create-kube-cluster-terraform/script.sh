#!/bin/bash

files=("persistent_volume.yaml" "persistent_volume_claim.yaml" "db_secret.yaml" "server_secret.yaml" "server_config.yaml" "mysql_deployment.yaml" "mysql_service.yaml" "web_server_deployment.yaml" "web_server_service.yaml" "result_server_deployment.yaml" "result_server_service.yaml")

for file in ${files[@]}
do
  kubectl apply -f $file && sleep 5
done



# for file in persistent_volume.yaml persistent_volume_claim.yaml db_secret.yaml server_secret.yaml server_config.yaml mysql_deployment.yaml mysql_service.yaml web_server_deployment.yaml web_server_service.yaml result_server_deployment.yaml result_server_service.yaml; do kubectl apply -f $file; sleep 5; done