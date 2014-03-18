#!/bin/bash
#
# Default settings used by scripts within the bin directory
# 
#-------------------------------------------------------------------

# Log file name:
export JOB_LOG_NAME=job.log

# Name of directory where onyx export file will be unzipped:
export ONYX_EXPORT_DIRECTORY=a-onyx-export

# Name of directory to hold first evolution of metadata files:
export METADATA_DIRECTORY=b-metadata

# Name of directory to hold second evolution of main metadata file:
export REFINED_METADATA_DIRECTORY=c-refined-metadata
export REFINED_METADATA_CATISSUE_DIRECTORY=c-refined-metadata-catissue

# Name of directory to hold second evolution of main metadata enumeration files:
export REFINED_METADATA_ENUMS_DIRECTORY=d-refined-metadata-enums
export REFINED_METADATA_ENUMS_CATISSUE_DIRECTORY=d-refined-metadata-enums-catissue

# Name of directory to hold sql inserts for metadata tables:
export METADATA_SQL_DIRECTORY=e-ontology-sql
export METADATA_SQL_CATISSUE_DIRECTORY=e-ontology-sql-catissue

# Appropriate job names for onyx only, onyx plus catissue, and catissue only installs:
export ONYX_ONLY_INSTALL=onyx-only-install
export ONYX_PLUS_CATISSUE_INSTALL=onyx-with-catissue-install
export CATISSUE_ONLY_INSTALL=catissue-only-install

# Appropriate job name for the regular import of data from catissue...
export CATISSUE_IMPORT=catissue-import

# Appropriate system user plus location for ssh into catissue VM for regular import
export SSH_INTEGRATION_USER=integration
export SSH_CATISSUE_VM=catissue 
# Full location of catissue import script within the caTissue VM:
export CATISSUE_IMPORT_SCRIPT=/var/local/brisskit/catissue/catissue-admin-procedures/bin/compositions/caTissue_to_i2b2.sh

# Name of directory to hold generated PDO xml files:
export PDO_DIRECTORY=f-pdo

# Name of directory to hold SQL inserts derived from PDO xml files:
export PDO_SQL_DIRECTORY=g-pdo-sql

# Max number of participants to be folded into one PDO xml file:
export BATCH_SIZE=50

# Name of file that holds the central metadata details:
export MAIN_REFINED_METADATA_FILE_NAME=refined-metadata.xml

# Name of the DB; can be either 'oracle' or 'sqlserver' or 'postgresql'
export DB_TYPE=postgresql

# Name of directory to hold any zipped SQL test data (PDO based)
export ZIPPED_SQL_DIRECTORY=z-zipped-sql

# Catissue
export REFINED_METADATA_CATISSUE_DIRECTORY=c-refined-metadata-catissue
export REFINED_METADATA_CATISSUE_ENUMS_DIRECTORY=d-refined-metadata-enums-catissue
export METADATA_CATISSUE_SQL_DIRECTORY=e-ontology-catissue-sql
export MAIN_REFINED_METADATA_CATISSUE_FILE_NAME=caTissue-Refined-Metadata8.xml

# Custom space for the install workspace (if required)
# If not defined, defaults to I2B2_INSTALL_HOME/work
#export I2B2_ADMIN_PROCS_WORKSPACE=?

# Custom names for the projects JBoss dataset config files.
# These names MUST be unique within a JBoss deployment.
# They MUST end with the string '-ds.xml'
# Suggestions:
# If your project is named 'brisskit1' then the following would work:
# brisskit1-crc-ds.xml
# brisskit1-ont-ds.xml
# brisskit1-work-ds.xml
# brisskit1-im-ds.xml
#
# The recommendation (not strict) is that these should be the same 
# as the project.name setting within the config.properties file
#
export CRC_DS=REPLACEME-crc-ds.xml
export ONT_DS=REPLACEME-ont-ds.xml
export WORK_DS=REPLACEME-work-ds.xml
export IM_DS=REPLACEME-im-ds.xml

#---------------------------------------------------------------------------------
# Java, Ant and JBoss home directories...
#---------------------------------------------------------------------------------
export JBOSS_HOME=$I2B2_INSTALL_DIRECTORY/jboss
export ANT_HOME=$I2B2_INSTALL_DIRECTORY/ant
export JAVA_HOME=$I2B2_INSTALL_DIRECTORY/jdk
