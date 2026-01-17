#!/usr/bin/env bash
#SBATCH --job-name=rmd
#SBATCH -A evoanalysis
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=80G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_rmd_%A_%a.err
#SBATCH --output=logs/std_rmd_%A_%a.out
#SBATCH --array=0-37

set -euo pipefail

module load gcc/14.2.0 picard/3.2.0 samtools/1.20

REPO="/project/evoanalysis/sperez11/evoanalysis2026"
IN_DIR="${REPO}/mapped_bam"
OUTDIR="${REPO}/rmd_bam"

mkdir -p "$OUTDIR" logs

# Stable list of BAMs as before
mapfile -t BAMS < <(ls -1 "${IN_DIR}"/*.sorted.bam | sort)
#each array task process one bam file
BAM="${BAMS[$SLURM_ARRAY_TASK_ID]}"
base="$(basename "$BAM")"
sample="${base%.sorted.bam}"

echo "Input BAM : $BAM"
echo "Sample    : $sample"

# read groups
picard AddOrReplaceReadGroups \
  -I "$BAM" \
  -O "${OUTDIR}/${sample}.rg.bam" \
  -RGID "$sample" \
  -RGLB lib1 \
  -RGPL illumina \
  -RGPU unit1 \
  -RGSM "$sample"

#Mark and remove duplicates
picard MarkDuplicates \
  -INPUT "${OUTDIR}/${sample}.rg.bam" \
  -OUTPUT "${OUTDIR}/${sample}.rmd.bam" \
  -METRICS_FILE "${OUTDIR}/${sample}.rmd.metrics.txt" \
  -REMOVE_DUPLICATES true \
  -ASSUME_SORTED true \
  -VALIDATION_STRINGENCY SILENT

#Index final BAM
samtools index "${OUTDIR}/${sample}.rmd.bam"
