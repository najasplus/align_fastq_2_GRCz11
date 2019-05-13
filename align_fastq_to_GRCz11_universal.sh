#!/bin/sh
#$ -N align_2_GRCz11
#$ -pe parallel 24
#$ -l h_vmem=24G
#$ -o align_2_GRCz11_o.log
#$ -e align_2_GRCz11_e.log


ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa Danio_rerio.GRCz11.dna.primary_assembly.fa
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.sa Danio_rerio.GRCz11.dna.primary_assembly.fa.sa
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.pac Danio_rerio.GRCz11.dna.primary_assembly.fa.pac
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.ann Danio_rerio.GRCz11.dna.primary_assembly.fa.ann
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.amb Danio_rerio.GRCz11.dna.primary_assembly.fa.amb
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.bwt Danio_rerio.GRCz11.dna.primary_assembly.fa.bwt
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.fa.fai Danio_rerio.GRCz11.dna.primary_assembly.fa.fai
ln -s /ebio/ecnv_projects/common_resourses/data/reference_genome/GRCz11/Danio_rerio.GRCz11.dna.primary_assembly.dict Danio_rerio.GRCz11.dna.primary_assembly.dict


ln -s /ebio/ecnv_projects/common_resourses/data/software/picard-tools-1.130/picard.jar picard.jar

while read line 
do
bwa mem -t 24 -M -R "@RG\tID:${line}\tLB:${line}\tPL:ILLUMINA\tPM:HISEQ\tSM:${line}"   Danio_rerio.GRCz11.dna.primary_assembly.fa ${line}* > /tmp/${line}.sam
java -jar -Xmx23g picard.jar SortSam INPUT=/tmp/${line}.sam OUTPUT=/tmp/${line}_sorted.bam SORT_ORDER=coordinate
rm /tmp/${line}.sam
java -jar -Xmx23g picard.jar CollectAlignmentSummaryMetrics R=Danio_rerio.GRCz11.dna.primary_assembly.fa I=/tmp/${line}_sorted.bam O=${line}_alignment_metrics.txt &
java -jar -Xmx23g picard.jar CollectInsertSizeMetrics INPUT=/tmp/${line}_sorted.bam OUTPUT=${line}_insert_metrics.txt HISTOGRAM_FILE=${line}_insert_size_histogram.pdf &
java -jar -Xmx23g picard.jar MarkDuplicates INPUT=/tmp/${line}_sorted.bam OUTPUT=${line}_dedup_reads.bam METRICS_FILE=${line}_dedup_reads_metrics.txt
java -jar -Xmx23g picard.jar BuildBamIndex INPUT=${line}_dedup_reads.bam
rm /tmp/${line}_sorted.bam
done < sample.list
