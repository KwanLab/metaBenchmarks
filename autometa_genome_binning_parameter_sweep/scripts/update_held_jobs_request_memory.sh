#!/usr/bin/env bash


if [ $# -eq 0 ]
  then
    echo "bash update_held_jobs_request_memory.sh <batch_id> <request_memory>"
    exit
fi

# Get batch ID from condor_q
batch_id=$1
# Determine request memory to update held jobs with
request_memory=$2
# Now the held jobs will be updated with the new request memory without updating the other idle jobs in the queue with lower request memory
held_jobids=($(condor_q -hold -nobatch -af:jt $batch_id | grep "^${batch_id}" | cut -f1)); condor_qedit ${held_jobids[@]} RequestMemory $request_memory
