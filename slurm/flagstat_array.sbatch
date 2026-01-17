#!/usr/bin/env bash
#SBATCH --job-name=flagstat
#SBATCH -A evoanalysis
#SBATCH --time=36:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_flagstat_%A_%a.err
#SBATCH --output=logs/std_flagstat_%A_%a.out
#SBATCH --array=0-37

set -euo pipefail

module load gcc/14.2.0 samtools/1.20

REPO="/project/evoanalysis/sperez11/evoanalysis2026"

# Choose which BAMs you want to QC:
# Option A (right after mapping):
IN_DIR="${REPO}/mapped_bam"
PATTERN="*.sorted.bam"

# Option B (after duplicates removed):
# IN_DIR="${REPO}/rmd_bam"
# PATTERN="*.rmd.bam"

OUTDIR="${REPO}/qc_flagstat"
mkdir -p "$OUTDIR" logs

# Stable list of BAMs
mapfile -t BAMS < <(ls -1 "${IN_DIR}"/${PATTERN} | sort)

BAM="${BAMS[$SLURM_ARRAY_TASK_ID]}"
base="$(basename "$BAM")"
sample="${base%.bam}"

OUT="${OUTDIR}/${sample}.flagstat.txt"

echo "BAM   : $BAM"
echo "OUT   : $OUT"

samtools flagstat -@ "$SLURM_CPUS_PER_TASK" "$BAM" > "$OUT"
