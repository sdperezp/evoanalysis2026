#!/usr/bin/env bash
#SBATCH --job-name=combinevcfs
#SBATCH -A evoanalysis
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_combinevcfs_%A.err
#SBATCH --output=logs/std_combinevcfs_%A.out

set -euo pipefail

module load gcc/14.2.0 bcftools/1.20

REPO="/project/evoanalysis/sperez11/evoanalysis2026"
VCFDIR="${REPO}/vcf_by_scaffold"
OUTVCF="${REPO}/genome.vcf.gz"

mkdir -p logs
cd "$VCFDIR"

# Create a sorted list of VCFs (critical!)
ls -1 *.vcf.gz | sort > vcf_list.txt

echo "Number of VCFs to combine:"
wc -l vcf_list.txt

# Concatenate
bcftools concat \
  -f vcf_list.txt \
  -O z \
  -o "$OUTVCF"

# Index combined VCF
bcftools index -t "$OUTVCF"

echo "VCF concatenation complete:"
echo "$OUTVCF"
