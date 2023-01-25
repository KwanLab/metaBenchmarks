#!/bin/bash
#SBATCH --partition=queue
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks
#SBATCH --cpus-per-task=20
#SBATCH --error=get_db_78.%J.err
#SBATCH --output=get_db_78.%J.out

cd /media/bigdrive1/Databases/mmseqs2_nr
mmseqs databases NR mmseqs2_NR NR_tmp --threads ${task.cpus}
