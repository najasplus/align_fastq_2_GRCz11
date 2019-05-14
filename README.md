# Align fastq to zebrafish genome version GRCz11 on cluster

The script is for submitting the alignment jobs on compute cluster of EBio. The job runs on 24 cores and requests 24G RAM per core.

Short reads in fastq format are aligned to zebrafish reference genome (version GRCz11) by bwa. The alignment file in sam format is written to /tmp directory, converted to .bam, sorted and deduplicated by Picard (Broad institute), the deduplicated file is indexed by samtools (EBI). 

## Input
The working directory should contain:

* file named sample.list 
lists the sample names, 1 name per line. At least 1 sample should be present.

Example:
```
sample1
sample2
sample3
```

* fastq files (accepts .fastq/.fq/fastq.gz/fq.gz)
Short reads from whole genome or exome sequencing (not RNA sequencing!): original files or links; 
the file name should start with sample name. Paired reads should be in separate files.

Example of fastq.gz paired reads naming:

```
sample1.1.fastq.gz
sample1.2.fastq.gz
sample2.1.fastq.gz
sample2.2.fastq.gz
```  
## Submitting job
In the working directory that contains fastq files and sample.list file run:

``` {bash}
qsub -cwd /path/to/align_fastq_to_GRCz11_universal.sh
```

## Output

Your working directory will contain indexed deduplicated alignment file in bam file and alignment statistics.

