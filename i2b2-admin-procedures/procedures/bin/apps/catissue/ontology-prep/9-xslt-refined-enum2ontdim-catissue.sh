#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Takes the enumerated refined metadata files and produces SQL inserts for 
# the ontology dimension table of the main CRC cell. 
#
# Mandatory: the following environment variables must be set
#            I2B2_ADMIN_PROCS_HOME, JAVA_HOME           
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
# The input directory is...
INPUT_DIR=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY
#
# And it must exist!
if [ ! -d $INPUT_DIR ]
then
	echo "Error! Input directory does not exist: $INPUT_DIR"
	echo "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#
# We use the log file for the job...
LOG_FILE=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#
# And the output directory is...
OUTPUT_DIR=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$METADATA_SQL_CATISSUE_DIRECTORY/$DB_TYPE/ontdim
#
# And it must exist!
if [ ! -d $OUTPUT_DIR ]
then
	print_message "Output directory does not exit: $OUTPUT_DIR" $LOG_FILE
	print_message "Please check your job name: $JOB_NAME"
	exit 1
fi

#
# Here is the stylesheet...
STYLESHEET=$I2B2_ADMIN_PROCS_HOME/xslt/$DB_TYPE/ont_dim-catissue_enumerations_${DB_TYPE}.xsl

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to produce enumerated concepts SQL for the ontology dimension" $LOG_FILE
echo ""
echo "Detailed log messages (if any) are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""
#
# Do the business...
print_message "" $LOG_FILE
print_message "Applying style sheet transformation to enumerations..." $LOG_FIL
$JAVA_HOME/bin/java \
           -cp $(for i in $I2B2_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
           net.sf.saxon.Transform \
           -xsl:$STYLESHEET \
           -s:$INPUT_DIR \
           -o:$OUTPUT_DIR \
           adminDate=`date +%Y-%m-%dT%H:%M:%S.000%:z` \
           sourceSystem=BRICCS >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce enumerated concepts SQL for the ontology dimension." $LOG_FILE
print_message "Success! XSLT transformation complete." $LOG_FILE

#
# Rename the files from extension *.xml to *.sql ... 
print_message "" $LOG_FILE
print_message "Giving files the sql extension..." $LOG_FILE
for filename in $OUTPUT_DIR/*.xml
do
	w_o_ext=`basename $filename .xml`;
	mv $filename $OUTPUT_DIR/$w_o_ext.sql ;
	exit_if_bad $? "Failed to give a file the sql extension." $LOG_FILE
done
print_message "Success! All files now have a suitable sql extension name." $LOG_FILE
     
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
