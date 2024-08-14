#!/bin/bash
#
# This script starts a docker container and run (a wrapper-script around) ximera's 'xake' command
#
# Usage: 
#   xmlatex bake
#   xmlatex compile test/myximerafile.tex
#   xmlatex serve     # this will also run 'xake frost'
#   xmlatex -i bash   # gets a bash-shell INSIDE the container
#
# Advanced usage
#   XAKE_IMAGE=ghcr.io/ximeraproject/xake2023:latest xmlatex compile demo.tex    # use a different docker image
#   COMMAND=pdflatex xmlatex demo.tex                                            # do not run the xake-wrapper, but $COMMAND
#
# This script
#  - starts a xake docker container (unless we're already IN a container)
#  - starts (presumably) a container-specific version of this very script
#  - that (presumably) starts xake with the arguments passed to this script
#  - optionally gets you a shell inside the container
#  - optionally automates lots of other things
#
# Note: set environment variable 'export DEBUG=1' and/or use -d option for debugging/tracing
#
#
# Set some defaults
#
# default docker image to run; overwrite with 'export XAKE_IMAGE=myxake:0.1'
: "${XAKE_IMAGE:=ghcr.io/ximeraproject/xake2023:v2.1.1}" 
#  : "${XAKE_IMAGE:=ghcr.io/ximeraproject/xake2019:latest}"
#
# Which folder to mount INSIDE the container, under /code  (use with care: it should contain a build.sh !)
: "${MOUNTDIR:=$(pwd)}"
#
# Which script to start inside the container; 
: "${COMMAND:=xmlatex}"
# : "${COMMAND:=pdflatex}"     # skip xmlatex inside the container, and directly run a specific command ...    
# : "${COMMAND:=./build.sh}"   # only usefull for OLD xake-images, which used a now obsolete build.sh script


if [[ -f /.dockerenv ]]  
then
    echo "Running in docker container (with local hostname $HOSTNAME)"
elif [[ -n "$KUBERNETES_SERVICE_HOST" ]] 
then
    echo "Running in kubernetes container ($KUBERNETES_SERVICE_HOST)"
else 
    [[ -n "$DEBUG" ]] && echo "Running $0 on host ($HOSTNAME)"

    if [[ "$1" == "-i" ]]
    then
        INTERACTIVE="-it"  # start an interactive docker session (i.e. with a terminal attached)
        shift 
    fi 

    # LOCAL_IP is only needed if you want to serve to a ximeraServer on your localhost; do NOT use URL_XIMERA when using LOCAL_IP
    if [[ "$LOCAL_IP" == "" ]]
    then
        LOCAL_IP=$(set -- $(hostname -I); echo "$1")
        [[ -n "$DEBUG" ]] && echo "Setting LOCAL_IP=$LOCAL_IP"
    fi

    echo "Restarting myself in docker (from image $XAKE_IMAGE)"	
    [[ -n "$DEBUG" ]] && echo  \
    docker run --env LOCAL_IP --env URL_XIMERA --env REPO_XIMERA --env GPG_KEY --env GPG_KEY_ID --network host --rm $INTERACTIVE --mount type=bind,source=$MOUNTDIR,target=/code $XAKE_IMAGE $COMMAND $*
    docker run --env LOCAL_IP --env URL_XIMERA --env REPO_XIMERA --env GPG_KEY --env GPG_KEY_ID --network host --rm $INTERACTIVE --mount type=bind,source=$MOUNTDIR,target=/code $XAKE_IMAGE $COMMAND $*
    exit 
fi
