# evoanalysis2026
## FASTQ read counting with Slurm

This repository includes a simple, reproducible Slurm job array to count the number of reads in FASTQ files (4 lines per read).

### Scripts
- `slurm/count_reads_array.sbatch`: Slurm job array that processes all FASTQ files located in `/project/evoanalysis/d3challenge_fq`.  
  Each array task handles one FASTQ file.

### Output
- Read counts are written to the `readcounts/` directory.
- Each output file is named `<fastq_filename>.readcount.txt` and contains the FASTQ filename and the total number of reads.

The output files are included in this repository for assignment submission.

