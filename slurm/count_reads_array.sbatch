#!/usr/bin/env bash
#SBATCH --job-name=readcount
#SBATCH --output=readcount_%A_%a.out
#SBATCH --error=readcount_%A_%a.err
#SBATCH --time=00:10:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

set -euo pipefail

# paths from medbow
FASTQ_DIR="/project/evoanalysis/d3challenge_fq"
OUTDIR="readcounts"

mkdir -p "$OUTDIR"

# build list of FASTQs
mapfile -t FILES < <(ls -1 "${FASTQ_DIR}"/*.fastq | sort)

# select file for this task
FASTQ="${FILES[$SLURM_ARRAY_TASK_ID]}"
fname="$(basename "$FASTQ")"
OUT="${OUTDIR}/${fname}.readcount.txt"

# count reads (4 lines per read)
lines=$(wc -l < "$FASTQ")
reads=$(( lines / 4 ))

# write output
{
  echo "File: $fname"
  echo "Reads: $reads"
} > "$OUT"

echo "Processed $fname"
