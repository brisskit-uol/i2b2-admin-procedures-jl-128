#!/bin/bash
#
# Basic environment variables for i2b2
# 
# Invocation within another sh script should be:
# source $I2B2_ADMIN_PROCS_HOME/bin/common/setenv.sh
#
#-------------------------------------------------------------------
source $I2B2_ADMIN_PROCS_HOME/config/defaults.sh

if [ -z $I2B2_ADMIN_DEFAULTS_DEFINED ]
then
	set +o nounset
	export I2B2_ADMIN_DEFAULTS_DEFINED=true	
	source $I2B2_ADMIN_PROCS_HOME/config/defaults.sh
	set -o nounset	
fi