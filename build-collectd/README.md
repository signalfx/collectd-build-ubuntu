collectd-build-ubuntu
=====================

Build files for debian packages of collectd for Ubuntu 12.04, 14.04 and 15.04 distributions.

Use Docker to build the packages in a clean manner. See Dockerfile inside sfx_scripts

Build the source package for upload to the launchpad using debuild command. Before uploading, test locally whether the binary packages are building correctly from the created source package using pdebuild command.

The command sequence to run the entire process inside a docker container can be found at sfx_scripts/cmdseq

#####NOTE
  1. After execution, all source and binary packages are copied to the amazon s3 bucket
  2. The build is written for the Ubuntu 14.04 distribution. To build the packages for other distributions, change the environment variable DISTRIBUTION in the above script.
  3. For Ubuntu 12.04 precise distribution, two patches will be applied which remove the unsupported libraries under build-depends of control file and disable the same plugins inside rules file.
  4. Before uploading the source package to the launchpad, sign the source package using debsign command.
