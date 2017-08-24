#!/bin/sh

TASKLIB=$PWD/src
INPUT_FILE_DIRECTORIES=$PWD/data
S3_ROOT=s3://moduleiotest
WORKING_DIR=$PWD/job_2112

COMMAND_LINE="java -Dlibdir\=$TASKLIB -cp $TASKLIB/gp-modules.jar:$TASKLIB/commons-math-1.2.jar:$TASKLIB/trove.jar:$TASKLIB/Jama-1.0.2.jar:$TASKLIB/colt.jar:$TASKLIB/jsci-core.jar org.broadinstitute.marker.MarkerSelection $INPUT_FILE_DIRECTORIES/all_aml_train.gct $INPUT_FILE_DIRECTORIES/all_aml_train.cls 100 2 cms_outfile false false no 1 12345  false false -lfalse  "

JOB_DEFINITION_NAME="R25_Generic"
JOB_ID=gp_job_CMS_$1
JOB_QUEUE=TedTest

DOCKER_CONTAINER=genepattern/docker-r-2-5

