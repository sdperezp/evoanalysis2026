#!/usr/bin/env bash
#SBATCH --job-name=bwa
#SBATCH -A evoanalysis
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=64G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_BWA_%A_%a.err
#SBATCH --output=logs/std_BWA_%A_%a.out
#SBATCH --array=0-37

set -euo pipefail

module load gcc/14.2.0 bwa/0.7.17 samtools/1.20

# Repo-root-style paths (simple + reproducible)
REPO="/project/evoanalysis/sperez11/evoanalysis2026"
IN_DIR="${REPO}/trimmed_fastq"
OUTDIR="${REPO}/mapped_bam"
REF="${REPO}/project/evoanalysis/reference_genomes/puncross.gapsEstimated.fasta"

mkdir -p "$OUTDIR" logs

# Build stable list of trimmed FASTQs (single-end)
mapfile -t FILES < <(ls -1 "${IN_DIR}"/*.trim.fastq | sort)

FASTQ="${FILES[$SLURM_ARRAY_TASK_ID]}"
base="$(basename "$FASTQ")"
sample="${base%.trim.fastq}"

BAM="${OUTDIR}/${sample}.sorted.bam"

echo "Sample: $sample"
echo "FASTQ : $FASTQ"
echo "REF   : $REF"
echo "BAM   : $BAM"

# Map (single-end) -> BAM -> sort
bwa mem -M -t "$SLURM_CPUS_PER_TASK" "$REF" "$FASTQ" \
  | samtools view -b - \
  | samtools sort -@ "$SLURM_CPUS_PER_TASK" -o "$BAM" -

# Index BAM
samtools index -@ "$SLURM_CPUS_PER_TASK" "$BAM"
