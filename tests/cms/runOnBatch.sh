#!/bin/sh

TASKLIB=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/R251_cli/tests/cms/src
INPUT_FILE_DIRECTORIES=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/R251_cli/tests/cms/data
S3_ROOT=s3://moduleiotest
WORKING_DIR=/Users/liefeld/GenePattern/gp_dev/genepattern-server/resources/wrapper_scripts/docker/aws_batch/containers/R251_cli/tests/cms/job_1112

COMMAND_LINE="java -Dlibdir\=$TASKLIB -cp $TASKLIB/gp-modules.jar:$TASKLIB/commons-math-1.2.jar:$TASKLIB/trove.jar:$TASKLIB/Jama-1.0.2.jar:$TASKLIB/colt.jar:$TASKLIB/jsci-core.jar org.broadinstitute.marker.MarkerSelection $INPUT_FILE_DIRECTORIES/all_aml_train.gct $INPUT_FILE_DIRECTORIES/all_aml_train.cls 100 2 cms_outfile false false no 1 12345  false false -lfalse  "



JOB_DEFINITION_NAME="R251_Generic"
JOB_ID=gp_job_CMS_$1
JOB_QUEUE=TedTest

# ##### NEW PART FOR SCRIPT INSTEAD OF COMMAND LINE ################################
# Make the input file directory since we need to put the script to execute in it
mkdir -p $WORKING_DIR/.gp_metadata

EXEC_SHELL=$WORKING_DIR/.gp_metadata/exec.sh

echo "#!/bin/bash\n" > $EXEC_SHELL
#echo "echo \"$COMMAND_LINE\"" >>$EXEC_SHELL
echo $COMMAND_LINE >>$EXEC_SHELL 
echo "\n " >>$EXEC_SHELL 

chmod a+rwx $EXEC_SHELL
chmod -R a+rwx $WORKING_DIR

REMOTE_COMMAND="runS3OnBatch.sh $TASKLIB $INPUT_FILE_DIRECTORIES $S3_ROOT $WORKING_DIR $EXEC_SHELL"
# note the batch submit now uses REMOTE_COMMAND instead of COMMAND_LINE 

#
# Copy the input files to S3 using the same path
#
aws s3 sync $INPUT_FILE_DIRECTORIES $S3_ROOT$INPUT_FILE_DIRECTORIES --profile genepattern
aws s3 sync $TASKLIB $S3_ROOT$TASKLIB --profile genepattern
aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR --profile genepattern 

######### end new part for script #################################################


#       --container-overrides memory=2000 \

aws batch submit-job \
      --job-name $JOB_ID \
      --job-queue $JOB_QUEUE \
      --container-overrides 'memory=3600' \
      --job-definition $JOB_DEFINITION_NAME \
      --parameters taskLib=$TASKLIB,inputFileDirectory=$INPUT_FILE_DIRECTORIES,s3_root=$S3_ROOT,working_dir=$WORKING_DIR,exe1="$REMOTE_COMMAND"  \
      --profile genepattern


