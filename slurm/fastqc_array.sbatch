#!/usr/bin/env bash
#SBATCH --job-name=fastqc
#SBATCH -A evoanalysis
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sperez11@uwyo.edu
#SBATCH --output=logs/fastqc_%A_%a.out
#SBATCH --error=logs/fastqc_%A_%a.err
#SBATCH --array=0-37

set -euo pipefail

#Same logic as the 3rd assignment
module load fastqc/0.12.1

FASTQ_DIR="/project/evoanalysis/d3challenge_fq"
OUTDIR="/project/evoanalysis/sperez11/evoanalysis2026/fastqc_raw"
mkdir -p "$OUTDIR" logs

# build a stable sorted list of FASTQs
mapfile -t FILES < <(ls -1 "${FASTQ_DIR}"/*.fastq | sort)

FASTQ="${FILES[$SLURM_ARRAY_TASK_ID]}"


fastqc -t "${SLURM_CPUS_PER_TASK}" -o "$OUTDIR" "$FASTQ"
