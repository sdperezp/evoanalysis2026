#!/usr/bin/env bash
#SBATCH --job-name=fastp_se
#SBATCH -A evoanalysis
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --output=logs/fastp_%A_%a.out
#SBATCH --error=logs/fastp_%A_%a.err
#SBATCH --array=0-37

set -euo pipefail

module load fastp/0.23.4

IN_DIR="/project/evoanalysis/d3challenge_fq"
OUT_DIR="/project/evoanalysis/sperez11/evoanalysis2026/trimmed_fastq"
REP_DIR="/project/evoanalysis/sperez11/evoanalysis2026/fastp_reports"

mkdir -p "$OUT_DIR" "$REP_DIR" logs

# Stable, reproducible file list
mapfile -t FILES < <(ls -1 "${IN_DIR}"/*.fastq | sort)

IN_FASTQ="${FILES[$SLURM_ARRAY_TASK_ID]}"
base="$(basename "$IN_FASTQ")"
sample="${base%.fastq}"

OUT_FASTQ="${OUT_DIR}/${sample}.trim.fastq"
JSON="${REP_DIR}/${sample}.fastp.json"
HTML="${REP_DIR}/${sample}.fastp.html"

echo "Trimming: $IN_FASTQ"
echo "Output  : $OUT_FASTQ"

fastp \
  -i "$IN_FASTQ" \
  -o "$OUT_FASTQ" \
  -w "$SLURM_CPUS_PER_TASK" \
  --detect_adapter_for_pe \
  --cut_tail --cut_window_size 4 --cut_mean_quality 20 \
  --qualified_quality_phred 15 \
  --unqualified_percent_limit 40 \
  --json "$JSON" \
  --html "$HTML"
