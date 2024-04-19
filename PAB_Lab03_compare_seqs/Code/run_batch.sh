#!/bin/bash
# Author: hdescobarh

#SBATCH --clusters=biocomputo
#SBATCH --nodes=1
#SBATCH --time=00:10:00
#SBATCH --partition=cpu.normal.q
#SBATCH --cpus-per-task=2
#SBATCH --job-name=lab03
#SBATCH --output=lab03-job_%j.out
#SBATCH --error=lab03-job_%j.err

module purge
module load envs/anaconda3
conda activate ~/env
module load apps/blast+/2.12.0

bash "./make_blast_exercise.sh"
bash "./make_NW_alignments.sh"
