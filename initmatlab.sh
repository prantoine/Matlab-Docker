#!/bin/bash
mc cp s3/prantoine/matlab.yaml ~/work/matlab.yaml

if [ -z "${MATLAB_PASS}" ] ; then
  echo "Error: MATLAB_PASS environment variable is not set."
  exit 1
fi

#this bash variable holds the secret required for 'mc' to work within the container.
#it is passed to the container through the 'create secret' command from kubectl.
MC_HOST_s3="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}:${AWS_SESSION_TOKEN}@${AWS_S3_ENDPOINT}"
if ! $(kubectl create secret generic mc-host-secret-name --from-literal=mc-host-secret-key="${MC_HOST_s3}") ; then
	kubectl delete secret mc-host-secret-name
	kubectl create secret generic mc-host-secret-name --from-literal=mc-host-secret-key="${MC_HOST_s3}"
fi

#creating a secret will fail if it already exists. It is deleted and recreated if it already exists, allowing the user to change their password in vault before launching the service.
if ! $(kubectl create secret generic basic-auth --from-literal=auth="prantoine:$(openssl passwd -apr1 ${MATLAB_PASS})") ; then
	kubectl delete secret basic-auth
	kubectl create secret generic basic-auth --from-literal=auth="prantoine:$(openssl passwd -apr1 ${MATLAB_PASS})"
fi

kubectl apply -f ~/work/matlab.yaml

#this gets the full name of the pod with the matlab container, and waits for it to be in status 'Running'
MATLAB_POD_NAME=$(kubectl get pods -o name | grep matlab)
kubectl wait --for=jsonpath='{.status.phase}'=Running ${MATLAB_POD_NAME}

#once the pod is running we can export whatever we want into it
#this example command shows basic usage to copy stuff from S3 bucket into matlab container
#on launch. Advantage is that users won't have to use manual 'mc' commands from within the matlab
#container, which is achieved by starting an interactive command invite:
#			kubectl exec ${MATLAB_POD_NAME} -it -- /bin/bash
#kubectl exec ${MATLAB_POD_NAME} -- /bin/bash -c "mc cp --recursive s3/${VAULT_TOP_DIR}/remote_dir /path/to/matlab/filesystem/dir"
