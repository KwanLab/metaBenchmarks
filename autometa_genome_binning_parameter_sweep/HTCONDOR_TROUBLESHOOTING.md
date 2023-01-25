# HTCondor Notes & Troubleshooting

- [HTCondor Resoures](#htcondor-resources)
- [Creating a conda env for htcondor](#creating-a-conda-compute-environment-for-use-with-htcondor-chtc)
- [Restarting held jobs with higher RAM](#restarting-jobs-that-have-been-put-on-hold-due-to-time-limits-or-memory-usage)

## HTCondor Resources

- [Hello world example](https://chtc.cs.wisc.edu/uw-research-computing/helloworld.html#1-lets-first-do-and-then-ask-why)
- [More information on special variables like "$1", "$2", and "$@"](https://swcarpentry.github.io/shell-novice/06-script/index.html)
- [HTCondors DAGman](https://htcondor.readthedocs.io/en/latest/users-manual/dagman-workflows.html#dag-submission)
- [multiple jobs with initialdir](https://chtc.cs.wisc.edu/uw-research-computing/multiple-jobs.html#initialdir)
- [multiples jobs with queue <var> from <list>](https://chtc.cs.wisc.edu/uw-research-computing/multiple-jobs.html#foreach)
- [CHTC Squid Proxy for file transfer](https://chtc.cs.wisc.edu/uw-research-computing/file-avail-squid.html)
- [Create a portable python installation with miniconda](https://chtc.cs.wisc.edu/uw-research-computing/conda-installation.html#option-1-pre-install-miniconda-and-transfer-to-jobs)
- [Open Science Grid](https://github.com/opensciencegrid/cvmfs-singularity-sync/pull/368#event-6628051950)
- [OSG locations tutorial](https://github.com/OSGConnect/tutorial-osg-locations)
- [Map Customizer](https://www.mapcustomizer.com/) (coordinates imported from OSG locations tutorial)
- [Finding OSG Locations](https://support.opensciencegrid.org/support/solutions/articles/12000061978-finding-osg-locations)
- [Scaling beyond local HTC capacity](https://chtc.cs.wisc.edu/uw-research-computing/scaling-htc.html#uw)

## Creating a conda compute environment for use with HTCondor (CHTC)

```bash
# Install mamba (faster and same commands available)
conda install -n base -c conda-forge mamba -y
# Create autometa env
mamba create -n autometa -c conda-forge -c bioconda autometa -y
# Create conda-pack env
mamba create -n conda-pack conda-pack -y
# package autometa env to tarball for transfer to SQUID web proxy
mamba activate conda-pack
conda-pack -n autometa
```

NOTE: This is _NOT_ needed if the submit file uses the `docker` universe with a specified docker image.

i.e. in the submit file:

```bash
# universe = vanilla # vanilla universe should be used with conda env tarball
universe = docker
docker_image = jasonkwan/autometa:latest
```

## Restarting jobs that have been put on hold due to time limits or memory usage

[HTCondor User Tutorial - CERN Indico](https://indico.cern.ch/event/611296/contributions/2604376/attachments/1471164/2276521/TannenbaumT_UserTutorial.pdf)

```bash
# See list of held jobs and reason why they were held
condor_q -hold
```

### Example Output

```text
(autometa) [erees@submit-1 binning_param_sweep]$ condor_q -hold | head


-- Schedd: submit-1.chtc.wisc.edu : <128.105.244.191:9618?... @ 05/31/22 10:07:54
 ID           OWNER          HELD_SINCE  HOLD_REASON
15872426.5184 erees           5/25 14:51 Error from slot1_3@e327.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
15872426.5185 erees           5/25 14:47 Error from slot1_4@e2353.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
15872426.5186 erees           5/25 14:51 Error from slot1_3@e2350.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
15872426.5187 erees           5/25 14:48 Error from slot1_6@e346.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
15872426.5188 erees           5/25 14:50 Error from slot1_1@e309.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
15872426.5189 erees           5/25 14:50 Error from slot1_3@e301.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb
```

### edit job(s) with batch name or job id using `condor_qedit`

### Raise held jobs memory limit to 32GB

```bash
# condor_qedit <jobid|batch> <attribute> <attribute-value>
# NOTE: 15872426 is the BATCH_NAME
condor_qedit 15872426 RequestMemory 32768
condor_release 15872426
```

### Raise job time limit

```bash
# condor_qedit <jobid|batch> <attribute> <attribute-value>
# NOTE: 15872426 is the BATCH_NAME
condor_qedit 15872426 LongJob true
condor_release 15872426
```

### Example of a specific job's attributes

```text
(autometa) [erees@submit-1 binning_param_sweep]$ condor_q -l 15872426.5189
ActivationDuration = 1289
ActivationSetupDuration = 1
ActivationTeardownDuration = -8382063121022416774
AllowedExecuteDuration = 1209600
Args = "dbscan 10 10 5 5 10000Mbp"
AutoClusterAttrs = "ConcurrencyLimits,DiskUsage,DockerImage,FirstUpdateUptimeGPUsSeconds,GPUJobLength,GPUs_Capability,GPUs_DeviceName,GPUs_GlobalMemoryMb,InteractiveJob,JobUniverse,LastUpdateUptimeGPUsSeconds,MachineLastMatchTime,MemoryUsage,Offline,PartitionableSlot,RemoteOwner,RequestCpus,RequestDisk,RequestGpus,RequestIoHeavy,RequestMemory,StartOfJobUptimeGPUsSeconds,TotalJobRunTime,UptimeGPUsSeconds,WantGPULab,FlockTo,Rank,Requirements,AccountingGroup,AcctGroup,AcctGroupUser,DynamicSlot,GlideinFactory,GPUs_DriverVersion,GPUs_MaxSupportedVersion,is_icecube_job,is_resumable,IsBuildJob,IsResumable,IsScavengerBeta,JobDurationCategory,JobRuntimeGuaranteeDefault,LastCheckpointPlatform,LongJob,nmi_run_type,NumCkpts,OConnorCOVID,Owner,Scheduler,WantFlocking,WantGlidein,WHEN_TO_TRANSFER_OUTPUT,Group,WID,WIDsTheme,_condor_RequestCpus,_condor_RequestDisk,_condor_RequestMemory,BIG_MEMORY_JOB,GPUs,HEP_VO,ImageSize,IsCMSProdSlot,IsDesktop,IsExpressQueueJob,IsLocalCMSJob,IsLocalCMSSlot,IsSAMJob,JobStart,MaxDiskTempC,MemoryRequirements,OSG_VO,PassedTest,USER,x509UserProxyVOName,DESIRED_Sites,estimated_run_hours,HasJava,is_itb,KFlops,ProjectName,SingularityImage,Slot1_SelfMonitorAge,Slot1_TotalTimeClaimedBusy,Slot1_TotalTimeUnclaimedIdle,SlotID,ROOT_PART_GT_85_PERCENT,Memory,EXECUTE_IS_READONLY,MIPS,MISSING_GPU,InCooloffMode,TmpIsFull,_condor_RequestGPUs,OpSysName"
AutoClusterId = 9973
BytesRecvd = 31572840.0
BytesSent = 0.0
ClusterId = 15872426
Cmd = "/home/erees/autometa_runs/binning_param_sweep/./autometa_binning.sh"
CommittedSlotTime = 0
CommittedSuspensionTime = 0
CommittedTime = 0
CompletionDate = 0
ConcurrencyLimits = "longjob"
CondorPlatform = "$CondorPlatform: x86_64_CentOS7 $"
CondorVersion = "$CondorVersion: 9.9.0 2022-05-09 BuildID: 586544 PackageID: 9.9.0-0.586544 RC $"
CoreSize = 0
CpusProvisioned = 4
CPUsUsage = 0.0
CumulativeRemoteSysCpu = 213.0
CumulativeRemoteUserCpu = 2930.0
CumulativeSlotTime = 5156.0
CumulativeSuspensionTime = 0
CurrentHosts = 0
DiskProvisioned = 2317071
DiskUsage = 32500
DiskUsage_RAW = 30861
DockerImage = "jasonkwan/autometa:2.1.0"
EncryptExecuteDirectory = false
EnteredCurrentStatus = 1653508218
Environment = ""
Err = "10000Mbp_autometa_binning_dbscan_comp10_pur10_cov5_gc5_15872426_5189.err"
ExecutableSize = 2
ExecutableSize_RAW = 2
ExitBySignal = false
ExitStatus = 0
GlobalJobId = "submit-1.chtc.wisc.edu#15872426.5189#1653145687"
HoldReason = "Error from slot1_3@e301.chtc.wisc.edu: Docker job has gone over memory limit of 16384 Mb"
HoldReasonCode = 34
HoldReasonSubCode = 0
ImageSize = 15000
ImageSize_RAW = 13275
In = "/dev/null"
IoHeavyProvisioned = 0
IsCHTCSubmit = true
Iwd = "/home/erees/autometa_runs/binning_param_sweep/data/10000Mbp"
JobCurrentFinishTransferInputDate = 1653506929
JobCurrentStartDate = 1653506929
JobCurrentStartExecutingDate = 1653506930
JobCurrentStartTransferInputDate = 1653506929
JOBGLIDEIN_ResourceName = "$$([IfThenElse(IsUndefined(TARGET.GLIDEIN_ResourceName), IfThenElse(IsUndefined(TARGET.GLIDEIN_Site), \"Local Job\", TARGET.GLIDEIN_Site), TARGET.GLIDEIN_ResourceName)])"
JobLeaseDuration = 2400
JobNotification = 0
JobPrio = 0
JobRunCount = 1
JobStartDate = 1653506929
JobStatus = 5
JobSubmitMethod = 0
JobUniverse = 5
LastJobLeaseRenewal = 1653508162
LastJobStatus = 2
LastMatchTime = 1653506929
LastPublicClaimId = "<128.105.68.214:9618?addrs=128.105.68.214-9618+[2607-f388-2200-100-1e6a-7aff-fe26-c57b]-9618&alias=e301.chtc.wisc.edu&noUDP&sock=startd_7430_f0c2>#1652441844#8788#..."
LastRejMatchReason = "no match found "
LastRejMatchTime = 1653506921
LastRemoteHost = "slot1_3@e301.chtc.wisc.edu"
LastRemoteWallClockTime = 1289.0
LastSuspensionTime = 0
LeaveJobInQueue = false
LongJob = true
MachineAttrCpus0 = 4
MachineAttrSlotWeight0 = 4
MATCH_EXP_JOBGLIDEIN_ResourceName = "Local Job"
MaxHosts = 1
MemoryProvisioned = 16384
MemoryUsage = 13275
MinHosts = 1
MyType = "Job"
NetworkInputMb = 0.001076
NetworkOutputMb = 0.0
NumCkpts = 0
NumCkpts_RAW = 0
NumHolds = 1
NumHoldsByReason = [ JobOutOfResources = 1 ]
NumJobCompletions = 0
NumJobMatches = 1
NumJobStarts = 1
NumRestarts = 0
NumShadowStarts = 1
NumSystemHolds = 0
OnExitHold = false
OnExitRemove = true
OrigMaxHosts = 1
Out = "10000Mbp_autometa_binning_dbscan_comp10_pur10_cov5_gc5_15872426_5189.out"
Owner = "erees"
PeriodicHold = false
PeriodicRelease = false
PeriodicRemove = false
ProcId = 5189
ProjectName = "GLOW"
QDate = 1653145683
Rank = 0.0
RemoteSysCpu = 213.0
RemoteUserCpu = 2930.0
RemoteWallClockTime = 1289.0
RequestCpus = 4
RequestDisk = 2097152
RequestMemory = 16384
Requirements = (Target.CanRunLongJobs =?= true) && (Target.OpSysMajorVer == 7) && (Target.OpSysMajorVer == 7) && (OpSysName =!= "Debian") && ((Target.HasCHTCStaging == true)) && TARGET.HasDocker && (TARGET.Disk >= RequestDisk) && (TARGET.Memory >= RequestMemory) && (TARGET.Cpus >= RequestCpus) && (TARGET.HasFileTransfer)
ResidentSetSize = 15000000
ResidentSetSize_RAW = 13594592
RootDir = "/"
ScratchDirFileCount = 17
ServerTime = 1654009842
ShouldTransferFiles = "YES"
StartdPrincipal = "execute-side@matchsession/128.105.68.214"
StreamErr = false
StreamOut = false
TargetType = "Machine"
TotalSubmitProcs = 7776
TotalSuspensions = 0
TransferIn = false
TransferInFinished = 1653506929
TransferInput = "5mers.am_clr.bhsne.tsv,coverage.tsv,gc_content.tsv,bacteria.markers.tsv,taxonomy.tsv,autometa_binning.sh"
TransferInputSizeMB = 30
TransferInputStats = [ CedarFilesCountLastRun = 6; CedarFilesCountTotal = 6 ]
TransferInStarted = 1653506929
TransferOutputStats = [  ]
User = "erees@chtc.wisc.edu"
UserLog = "/home/erees/autometa_runs/binning_param_sweep/data/10000Mbp/10000Mbp_autometa_binning_dbscan_comp10_pur10_cov5_gc5_15872426_5189.log"
WantDocker = true
WantFlocking = true
WhenToTransferOutput = "ON_EXIT"
```

### Runtime/Monitoring Notes

- 108 jobs for 78Mbp did not produce an output binning file
  - 105 of these were HDBSCAN jobs with a coverage std.dev. cutoff at 2%
  - 3 of these were test runs where the output parameter was incorrectly specified in the template causing the run to fail. (These were test runs prior to running the full parameter sweep)
- taxon-profiling (`autometa_preprocess_taxonomy.sub`) for 2500Mbp and 5000Mbp failed due to job time limit (re-submitted with `+LongJob = true`)

#### Autometa v2 nextflow binning process

```groovy
process AUTOMETA_V2 {
    publishDir "${params.outdir}/${meta.id}/autometa_v2", mode: "${params.publish_dir_mode}"
    tag "${meta.id} ${cluster_method} comp:${completeness} pur:${purity} cov:${cov_stddev_limit} gc:${gc_stddev_limit}"

    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }

    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(kmers), path(coverage), path(gc_content), path(markers), path(taxonomy), val(cluster_method), val(completeness), val(purity), val(cov_stddev_limit), val(gc_stddev_limit)
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv")

    script:
        template 'autometa_v2.sh'
}
```
