#!/usr/bin/env bash
#SBATCH --job-name=var_call
#SBATCH -A evoanalysis
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=48G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_varcall_%A_%a.err
#SBATCH --output=logs/std_varcall_%A_%a.out
#SBATCH --array=1-XXX

set -euo pipefail

module load gcc/14.2.0 bcftools/1.20

REPO="/project/evoanalysis/sperez11/evoanalysis2026"

# Input BAMs (after read groups + duplicates removed)
BAMDIR="${REPO}/rmd_bam"

# Reference genome (shared path)
REF="/project/evoanalysis/reference_genomes/YOUR_REFERENCE.fasta"

# Scaffold list (one scaffold name per line)
SCAFLIST="${REPO}/reference/scaffolds.txt"

# Output directory for per-scaffold VCFs
OUTDIR="${REPO}/vcf_by_scaffold"
mkdir -p "$OUTDIR" logs

# Select scaffold for this task (array is 1-indexed)
scaf="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SCAFLIST")"

echo "started scaffold: $scaf"

# Call variants for that scaffold across all samples
bcftools mpileup \
  --threads "$SLURM_CPUS_PER_TASK" \
  -a DP,AD \
  -r "$scaf" \
  -f "$REF" \
  "${BAMDIR}"/*.rmd.bam \
| bcftools call \
  -m --variants-only \
  --threads "$SLURM_CPUS_PER_TASK" \
  -O z -o "${OUTDIR}/${scaf}.vcf.gz"

bcftools index -t "${OUTDIR}/${scaf}.vcf.gz"

echo "completed scaffold: $scaf"
