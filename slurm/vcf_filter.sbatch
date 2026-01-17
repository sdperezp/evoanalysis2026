#!/usr/bin/env bash
#SBATCH --job-name=vcf_filt
#SBATCH -A evoanalysis
#SBATCH --time=03:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=24G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOUREMAIL@uwyo.edu
#SBATCH --error=logs/err_filt_%A.err
#SBATCH --output=logs/std_filt_%A.out

set -euo pipefail

module load gcc/14.2.0 bcftools/1.20 vcftools/0.1.17

REPO="/project/evoanalysis/sperez11/evoanalysis2026"
VCFDIR="${REPO}"
VCF_IN="${VCFDIR}/genome.vcf.gz"
VCF_OUT="${VCFDIR}/genome.filtered.vcf.gz"

# Filtering parameters
MAF=0              # keep all alleles 
MISS=0.7           # max fraction of missing data allowed
QUAL=30            # site quality
MIN_DEPTH=7        # minimum depth per genotype
MIN_ALLELES=2
MAX_ALLELES=2      # keep only biallelic SNPs


vcftools --gzvcf "$VCF_IN" \
  --remove-indels \
  --maf "$MAF" \
  --max-missing "$MISS" \
  --minQ "$QUAL" \
  --minDP "$MIN_DEPTH" \
  --min-alleles "$MIN_ALLELES" \
  --max-alleles "$MAX_ALLELES" \
  --recode --stdout \
| gzip -c > "$VCF_OUT"

# Index filtered bcftools index -t "$VCF_OUT"

echo "VCF filtering complete"
