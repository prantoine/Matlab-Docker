# Adding MC to matlab when inside container

	wget https://dl.min.io/client/mc/release/linux-amd64/mc
	chmod +x mc
	sudo mv mc /usr/local/bin/mc

# Setting MC env var when not available in container
Find MC_HOST_s3 from https://datalab.sspcloud.fr/account/storage, 'Connect to storage', MC client at the bottom.
It should match the inherited MC_HOST_s3 env in the service. If it does not, do

	export MC_HOST_s3=<copied MC_HOST_s3 from above>

And then you should be able to do:

	kubectl exec [CONTAINER_NAME] -- /bin/bash -c "echo ${MC_HOST_s3} > /path/to/file/you/want/to/export/var/to"
	kubectl exec [CONTAINER_NAME] -- /bin/bash -c "export MC_HOST_s3=$(cat /path/to/file/you/want/to/export/var/to)"

This will put the env var in a file you specified, and then export it as an actual env var. 
Subsequent calls to 'mc' should succeed.

# Update: now using AWS cli

See for full details:
	https://datalab.sspcloud.fr/s3/prantoine/?profile=default
