#!/usr/bin/env bash
#SBATCH --job-name=fastqc_trim
#SBATCH -A evoanalysis
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --output=logs/fastqc_trim_%A_%a.out
#SBATCH --error=logs/fastqc_trim_%A_%a.err
#SBATCH --array=0-37

set -euo pipefail

module load fastqc/0.12.1

IN_DIR="/project/evoanalysis/sperez11/evoanalysis2026/trimmed_fastq"
OUT_DIR="/project/evoanalysis/sperez11/evoanalysis2026/fastqc_trimmed"

mkdir -p "$OUT_DIR" logs

# stable list of trimmed fastqs
mapfile -t FILES < <(ls -1 "${IN_DIR}"/*.trim.fastq | sort)

FASTQ="${FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Running FastQC on trimmed file: $FASTQ"

fastqc -t "$SLURM_CPUS_PER_TASK" -o "$OUT_DIR" "$FASTQ"
