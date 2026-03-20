#!/bin/bash

mc cp s3/prantoine/matlab.yaml ~/work/matlab.yaml

#this file contains credentials generated via apache2 'htpasswd' tool.
mc cp s3/prantoine/auth ~/work/auth

#this bash variable holds the secret required for 'mc' to work within the container.
#it is passed to the container through the 'create secret' command from kubectl.
MC_HOST_s3="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}:${AWS_SESSION_TOKEN}@${AWS_S3_ENDPOINT}"
kubectl create secret generic mc-host-secret-name --from-literal=mc-host-secret-key="${MC_HOST_s3}"

#add the authentication file as a secret.
#kubectl create secret generic basic-auth --from-file=~/work/auth

#creating a secret will fail if it already exists. It is deleted and recreated if it already exists, allowing the user to change their password in vault when launching the service.
if ! $(kubectl create secret generic basic-auth --from-literal=auth="prantoine:$(openssl passwd -apr1 ${MATLAB_PASS})") ; then
	kubectl delete secret basic-auth
	kubectl create secret generic basic-auth --from-literal=auth="prantoine:$(openssl passwd -apr1 ${MATLAB_PASS})")
fi


kubectl apply -f ~/work/matlab.yaml
