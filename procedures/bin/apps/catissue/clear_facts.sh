#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Clears the i2b2 observation fact table and the ontology tables of catissue data.
#
# Mandatory: the following environment variables must be set
#            I2B2_ADMIN_PROCS_HOME            
# Optional : the I2B2_ADMIN_PROCS_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: {script-file-name}.sh job-name 
# Where: 
#   job-name is a suitable tag that groups all jobs associated within the overall workflow
# Notes:
#   The job-name must be associated with the prerequisite run of the refine-metadata script.
#
#-----------------------------------------------------------------------------------------------
source $I2B2_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $I2B2_ADMIN_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 1 ]
then
	echo "Error! Incorrect number of arguments"
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve the argument into its variable...
JOB_NAME=$1

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $I2B2_ADMIN_PROCS_WORKSPACE ]
then
	I2B2_ADMIN_PROCS_WORKSPACE=$I2B2_ADMIN_PROCS_HOME/work
fi

#
# We use the log file for the job...
LOG_FILE=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#===========================================================================
# The real work is about to start.
#=========================================================================== 
print_message "Clearing file repository cell" $LOG_FILE
rm -Rf /local/FRC/*
exit_if_bad $? "Failed to clear file repository cell."
print_message "File repository cell cleared." $LOG_FILE

#
# Clear the fact table...
print_message "Clearing facts" $LOG_FILE
$ANT_HOME/bin/ant -propertyfile $I2B2_ADMIN_PROCS_HOME/config/config.properties \
                  -Dproc.home=$I2B2_ADMIN_PROCS_HOME \
                  -f $I2B2_ADMIN_PROCS_HOME/ant/${DB_TYPE}/catissue_db.xml clear_facts
exit_if_bad $? "Failed to clear observation facts" $LOG_FILE
print_message "Observation facts cleared" $LOG_FILE
#
# Clear metadata...
print_message "Clearing ontology" $LOG_FILE
$ANT_HOME/bin/ant -propertyfile $I2B2_ADMIN_PROCS_HOME/config/config.properties \
                  -Dproc.home=$I2B2_ADMIN_PROCS_HOME \
                  -f $I2B2_ADMIN_PROCS_HOME/ant/${DB_TYPE}/catissue_db.xml clear_metadata
exit_if_bad $? "Failed to clear ontology" $LOG_FILE
print_message "Ontology cleared" $LOG_FILE
