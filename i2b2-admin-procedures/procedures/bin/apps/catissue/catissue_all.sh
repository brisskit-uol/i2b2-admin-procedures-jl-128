#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Orchestrates the flow of PDO's and ontology enums from caTissue to i2b2
#
#
#-----------------------------------------------------------------------------------------------
source /var/local/brisskit/i2b2/set.sh
source $I2B2_ADMIN_PROCS_HOME/bin/common/functions.sh
source $I2B2_ADMIN_PROCS_HOME/bin/common/setenv.sh

#
# Retrieve job-name into its variable...
JOB_NAME=$CATISSUE_IMPORT

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
# If required, create a working directory for this job step.
WORK_DIR=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME
if [ ! -d $WORK_DIR ]
then
	mkdir -p $WORK_DIR
	exit_if_bad $? "Failed to create working directory. $WORK_DIR"
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
print_message "About to undertake caTissue import" $LOG_FILE
echo "This can take some time."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#================================================================
# Clear the i2b2 observation fact table of catissue facts. 
#================================================================
cd $I2B2_ADMIN_PROCS_HOME/bin/apps/catissue
./clear_facts.sh $JOB_NAME

#================================================================
# Invoke a remote routine on the catissue VM
# which extracts data and formats a set of PDO's and an
# associated set of ontology enumerations.
# These files are sent back to this VM for processing. 
#================================================================
print_message "About to produce ontology enums and PDO's from remote catissue VM" $LOG_FILE
#
# First some preparation: we clear the holding areas...
rm $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/ontology-enums/*
exit_if_bad $? "Failed to remove any previous ontology enums from holding area."
rm $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/pdo/*
exit_if_bad $? "Failed to remove any previous pdo's from holding area."
#
# Now invoke the remote routine...
echo "This could take some time."
ssh $SSH_INTEGRATION_USER@$SSH_CATISSUE_VM $CATISSUE_IMPORT_SCRIPT
exit_if_bad $? "Failed to invoke remote routine."
print_message "Successfully returned from remote routine. Checking results..." $LOG_FILE
#
# Check for returned enums...
if [ ! "$(ls -A $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/ontology-enums)" ]; then
	print_message "No enumerations were returned. Exiting..." $LOG_FILE
    exit 1
fi
#
# Check for returned pdo's...
if [ ! "$(ls -A $I2B2_ADMIN_PROCS_HOME/remote-holding-area/catissue/pdo)" ]; then
	print_message "No pdo's were returned. Exiting..." $LOG_FILE
    exit 1
fi

#================================================================
# Import the enumerations and the PDO's into i2b2...
#================================================================
./import.sh $JOB_NAME

#================================================================
# If we got this far, we must be successful?...
#================================================================
print_message "Overall extraction and import process complete." $LOG_FILE
print_message "It's a good idea to check the log files for any failure." $LOG_FILE
print_footer $0 $JOB_NAME $LOG_FILE
