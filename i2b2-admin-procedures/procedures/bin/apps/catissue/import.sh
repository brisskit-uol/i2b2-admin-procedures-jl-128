#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Import catissue ontology and catissue pdo's into i2b2.
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
source $I2B2_ADMIN_PROCS_HOME/bin/common/functions.sh
source $I2B2_ADMIN_PROCS_HOME/bin/common/setenv.sh

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

#================================================================
# Remove, then create working directories...
#================================================================
print_message "Creating working directories..." $LOG_FILE
rm -Rf $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/  >/dev/null 2>/dev/null
mkdir $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY
exit_if_bad $? "Failed to create $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY"
mkdir $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$METADATA_SQL_DIRECTORY
exit_if_bad $? "Failed to create $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$METADATA_SQL_DIRECTORY"
mkdir $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$REFINED_METADATA_CATISSUE_DIRECTORY
exit_if_bad $? "Failed to create $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$REFINED_METADATA_CATISSUE_DIRECTORY"
mkdir $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$REFINED_METADATA_ENUMS_CATISSUE_DIRECTORY
exit_if_bad $? "Failed to create $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY/$REFINED_METADATA_ENUMS_CATISSUE_DIRECTORY"
print_message "Working directories created." $LOG_FILE

#==========================================================================
# Copy main refined metadata file into appropriate working directory
#==========================================================================
cp $I2B2_ADMIN_PROCS_HOME/ontologies/catissue/ontology/$MAIN_REFINED_METADATA_CATISSUE_FILE_NAME \
   $I2B2_ADMIN_PROCS_WORKSPACE/$REFINED_METADATA_CATISSUE_DIRECTORY
exit_if_bad $? "Failed to copy $I2B2_ADMIN_PROCS_HOME/ontologies/catissue/ontology/$MAIN_REFINED_METADATA_CATISSUE_FILE_NAME"
print_message "Copied $MAIN_REFINED_METADATA_CATISSUE_FILE_NAME." $LOG_FILE

#==========================================================================
# Copy remotely produced enums into appropriate working directory
#==========================================================================
cp $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/ontology-enums/* \
   $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$REFINED_METADATA_CATISSUE_ENUMS_DIRECTORY
exit_if_bad $? "Failed to copy remotely produced enums into $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$REFINED_METADATA_CATISSUE_ENUMS_DIRECTORY"
print_message "Copied remotely produced enums into $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$REFINED_METADATA_CATISSUE_ENUMS_DIRECTORY" $LOG_FILE

#==========================================================================
# Copy remotely produced pdo's into appropriate working directory
#==========================================================================
cp $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/pdo/* \
   $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY
exit_if_bad $? "Failed to copy remotely produced PDO's into $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY"
print_message "Copied remotely produced PDO's into $I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY" $LOG_FILE

#==========================================================================
# Produce catissue main ontology sql commands...
#==========================================================================
$I2B2_ADMIN_PROCS_HOME/bin/apps/catissue/ontology-prep/6-xslt-refined-2ontcell-catissue.sh $JOB_NAME
$I2B2_ADMIN_PROCS_HOME/bin/apps/catissue/ontology-prep/7-xslt-refined-2ontdim-catissue.sh  $JOB_NAME

#==========================================================================
# Produce catissue enumerations ontology sql commands...
#==========================================================================
$I2B2_ADMIN_PROCS_HOME/bin/apps/catissue/ontology-prep/8-xslt-refined-enum2ontcell-catissue.sh $JOB_NAME
$I2B2_ADMIN_PROCS_HOME/bin/apps/catissue/ontology-prep/9-xslt-refined-enum2ontdim-catissue.sh $JOB_NAME

#==========================================================================
# Upload the ontology data by executing the sql commands...
#==========================================================================
$I2B2_ADMIN_PROCS_HOME/bin/apps/catissue/meta-upload/metadata-upload-sql.sh $JOB_NAME

#==========================================================================
# Upload the PDO's...
#==========================================================================
#$I2B2_ADMIN_PROCS_HOME/bin/participant-upload/participant-upload-ws.sh $JOB_NAME


