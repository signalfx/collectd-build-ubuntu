#! /bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
DISTRIBUTIONS="wheezy jessie stretch precise vivid trusty xenial"
COMMANDS="collectd plugin container"
BUILD_PUBLISH=False
ARTIFACT="$1"
DISTRIBUTION="$2"

# Check if a supplied substring is in the supplied string
in_string(){
    local sub="$1"
    local str="$2"
    for i in $str ; do
        if [ $i = $sub ] ; then
            return 0
        fi
    done
    return 1
}

print_usage(){
        echo "Locally build collectd, (!) signalfx collectd plugin, or builder image
for ubuntu linux

USAGE: sh local_build.sh COMMAND [options]

Commands:

            collectd  - build the signalfx collectd ubuntu package
                        [options]
                            'wheezy'  - Wheezy debian build
                            'jessie'  - Jessie debian build
                            'stretch' - Stretch debian build
                            'precise' - Precise ubuntu build
                            'vivid'   - Vivid ubuntu build
                            'trusty'  - Trusty ubuntu build
                            'xenial'  - Xenial ubuntu build
                            No Option - Build for all platforms
            plugin    - (Not ready)   
                        build the signalfx collectd metadata plugin
                        ubuntu apk package
            container - build the builder image
                        quay.io/signalfuse/collectd-build-ubuntu
                        and store in local docker image reposit

Requirements:
            collectd  - the collectd repo should be checked out to 
                        /local_dev_resources
            plugin    - the signalfx-collectd-plugin repo should be checked 
                        out to /local_dev_resources
    "
}

# Set up the local_dev_resources directory
do_setup(){
    # Set up temporary directory
    tempfolder=$(mktemp -d ${SCRIPT_DIR}/local_dev_resources/0.XXXXXX)
    mkdir -p ${tempfolder}/workspace
    mkdir -p ${tempfolder}/pbuilder
    trap "rm -rf ${tempfolder};" EXIT
    # Make packages directory if it doesn't exist
    if [ ! -d $SCRIPT_DIR/local_dev_resources/packages ] ; then
        mkdir -p $SCRIPT_DIR/local_dev_resources/packages
    fi
}

# Build collectd in a container
build_collectd(){
    dist="$1"

    # Make directory in packages for the distribution
    mkdir -p $SCRIPT_DIR/local_dev_resources/packages/collectd/$dist

    # Start the container
    docker run --privileged \
    --name "collectd-build-ubuntu" \
    -e "BUILD_PUBLISH=False" \
    -e "DISTRIBUTION=$dist" \
    -v $SCRIPT_DIR/local_dev_resources/collectd:/opt/collectd \
    -v $SCRIPT_DIR/build-collectd:/opt/collectd-build \
    -v $tempfolder/workspace:/opt/workspace \
    -v $SCRIPT_DIR/local_dev_resources/packages/collectd/$dist:/opt/result \
    -v $tempfolder/pbuilder:/var/cache/pbuilder \
    quay.io/signalfuse/collectd-build-ubuntu /opt/collectd-build/sfx_scripts/cmdseq

    # List out the build artifacts
    echo "The build artifacts have been saved to: ${SCRIPT_DIR}/local_dev_resources/packages/collectd/${dist}/test/debs"
    ls -la ${SCRIPT_DIR}/local_dev_resources/packages/collectd/$dist/test/debs

    # Clean up the container
    docker stop collectd-build-ubuntu
    docker rm collectd-build-ubuntu
}

build_plugin(){
    dist="$1"
    
    # Make directory in packages for the distribution
    mkdir -p $SCRIPT_DIR/local_dev_resources/packages/signalfx-collectd-plugin

    docker run --privileged \
    --name "collectd-plugin-build-ubuntu" \
    -e "BUILD_PUBLISH=False" \
    -e "DISTRIBUTION=$dist" \
    -v $SCRIPT_DIR/local_dev_resources/signalfx-collectd-plugin:/opt/signalfx-collectd-plugin \
    -v $SCRIPT_DIR/build-plugin:/opt/collectd-plugin-build-debian \
    -v $tempfolder/workspace:/opt/workspace \
    -v $SCRIPT_DIR/local_dev_resources/packages/signalfx-collectd-plugin:/opt/result \
    quay.io/signalfuse/collectd-build-ubuntu /opt/collectd-plugin-build-debian/sfx_scripts/cmdseq

    # List out the build artifacts
    echo "The build artifacts have been saved to: ${SCRIPT_DIR}/local_dev_resources/packages/signalfx-collectd-plugin"
    ls -la ${SCRIPT_DIR}/local_dev_resources/packages/signalfx-collectd-plugin

    # Clean up the container
    docker stop collectd-plugin-build-ubuntu
    docker rm collectd-plugin-build-ubuntu
}

run(){
    # Validate input and execute commands
    if [ -z "$ARTIFACT" ] ; then
        print_usage

    elif in_string "$ARTIFACT" "$COMMANDS" ; then
        # Build collectd
        if [ "$ARTIFACT" = "collectd" ] ; then
            # If distribution is not specified
            if [ ! -n "$DISTRIBUTION" ] ; then
                # iterate over all distributions
                for x in $DISTRIBUTIONS ; do
                    build_collectd $x
                done
            else
                # Iterate over all valid distributions specified
                for x in $DISTRIBUTION ; do
                    if in_string "$x" "$DISTRIBUTIONS" ; then
                        build_collectd $x
                    else
                        echo "Invalid distribution (${x})"
                    fi
                done
            fi
        fi

        # Build plugin
        if [ "$ARTIFACT" = "plugin" ] ; then
            # If distribution is not specified
            if [ ! -n "$DISTRIBUTION" ] ; then
                # iterate over all distributions
                for x in $DISTRIBUTIONS ; do
                    build_plugin $x
                done
            else
                # Iterate over all valid distributions specified
                for x in $DISTRIBUTION ; do
                    if in_string "$x" "$DISTRIBUTIONS" ; then
                        build_plugin $x
                    else
                        echo "Invalid distribution (${x})"
                    fi
                done
            fi
        fi

        # Build container
        if [ "$ARTIFACT" = "container" ] ; then
            cd $SCRIPT_DIR/build-collectd-builder-image
            docker build -t quay.io/signalfuse/collectd-build-ubuntu .
            cd $SCRIPT_DIR
            echo "Local Build Complete"
        fi
    else
        echo "Invalid Command: $ARTIFACT"
        print_usage
    fi
}

# Set up
do_setup
# Run
run
