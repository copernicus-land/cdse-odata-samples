#!/bin/bash
set -e
dir=$(dirname $0)

DOCKER_IMAGE="vito-docker.artifactory.vgt.vito.be/clms_metadata:latest"
docker image pull $DOCKER_IMAGE

while IFS="," read -r enabled name path
do 
    echo $name
    if [[ $enabled == true || $enabled == 1 ]]; then
        # use VSICACHED option to circumvent libhdf5 writing to stdout
        # using virtual filesystem with netCDF driver in Docker requires userfaultd system call, so set security-opt to allow it
        docker run --rm -e VSICACHED=true --security-opt seccomp=unconfined -a stdout -a stderr -v /data/:/data/ -v /vitodata/:/vitodata/ $DOCKER_IMAGE odata create $path | python3 -m json.tool --indent 2 > $name.json
    fi
done < <(tail -n +2 $dir/local.csv)