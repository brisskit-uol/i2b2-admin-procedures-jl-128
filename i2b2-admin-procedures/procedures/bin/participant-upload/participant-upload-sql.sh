#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Uploads participant data for an i2b2 project.
#
# Prerequisites: 
#   (1) Execution of metadata-upload-sql.sh and its prerequisites (or equivalent)
#   (2) Settings within the directory I2B2_ADMIN_PROCS_HOME/config/DB_TYPE 
#       You are advised to review these settings carefully.
#
# Mandatory: the I2B2_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the I2B2_ADMIN_PROCS_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag that groups all jobs associated with the overall workflow
# Notes:
#   The job-name is used to find the working directory for the overall workflow; eg:
#   I2B2_ADMIN_PROCS_WORKSPACE/{job-name}
#   This working directory must already exist. 
#   It should be the working directory associated with creating the pdo sql.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
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
	echo "Error! Incorrect number of arguments."
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve job-name into its variable...
JOB_NAME=$1

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $I2B2_ADMIN_PROCS_WORKSPACE ]
then
	I2B2_ADMIN_PROCS_WORKSPACE=$I2B2_ADMIN_PROCS_HOME/work
fi

#
# Establish a log file for the job...
LOG_FILE=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#
# The working directory must already exist...
WORK_DIR=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME
if [ ! -d $WORK_DIR ]
then
	print_message "Error! Working directory does not exist: $WORK_DIR"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
print_message "About to upload participant data" $LOG_FILE
echo "This should take some minutes."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#===========================================================================
# UPLOAD PARTICIPANT DATA TO CRC CELL...
#===========================================================================
$ANT_HOME/bin/ant -propertyfile $I2B2_ADMIN_PROCS_HOME/config/config.properties \
                  -Dproc.home=$I2B2_ADMIN_PROCS_HOME \
                  -Dpdo.dir=$WORK_DIR/$PDO_SQL_DIRECTORY \
                  -f $I2B2_ADMIN_PROCS_HOME/ant/${DB_TYPE}/participant-upload-build.xml \
                  load_participant_data \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to upload participant data to crc cell." $LOG_FILE
print_message "Success! Participant data uploaded to crc cell." $LOG_FILE

#=========================================================================
# If we got this far, we must be successful...
#=========================================================================
echo "Please check log messages for any SQL errors."
print_footer $0 $JOB_NAME $LOG_FILE