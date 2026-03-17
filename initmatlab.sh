#!/bin/bash
mc cp s3/prantoine/matlab.yaml ~/work/matlab.yaml

#this env variable is necessary to use command 'mc' within the container. the user becomes authenticated with s3 service.
export MC_HOST_s3="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}:${AWS_SESSION_TOKEN}@${AWS_S3_ENDPOINT}"

kubectl apply -f ~/work/matlab.yaml
