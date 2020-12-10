#!/bin/sh
#$ -N align_2_GRCz11
#$ -pe parallel 24
#$ -l h_vmem=24G
#$ -o align_2_GRCz11_o.log
#$ -e align_2_GRCz11_e.log

common_resouces='/ebio/ecnv_projects/common_resourses/data/'
grcz11_basename='Danio_rerio.GRCz11.dna.primary_assembly'
grcz11_path="$common_resouces/reference_genome/GRCz11/"

ln -s "$grcz11_path"/"$grcz11_basename".fa "$grcz11_basename".fa
ln -s "$grcz11_path"/"$grcz11_basename".fa.sa "$grcz11_basename".fa.sa
ln -s "$grcz11_path"/"$grcz11_basename".fa.pac "$grcz11_basename".fa.pac
ln -s "$grcz11_path"/"$grcz11_basename".fa.ann "$grcz11_basename".fa.ann
ln -s "$grcz11_path"/"$grcz11_basename".fa.amb "$grcz11_basename".fa.amb
ln -s "$grcz11_path"/"$grcz11_basename".fa.bwt "$grcz11_basename".fa.bwt
ln -s "$grcz11_path"/"$grcz11_basename".fa.fai "$grcz11_basename".fa.fai
ln -s "$grcz11_path"/"$grcz11_basename".dict "$grcz11_basename".dict


ln -s "$common_resources"/software/picard-tools-1.130/picard.jar picard.jar

while read -r line
do
bwa mem -t 24 -M -R "@RG\tID:${line}\tLB:${line}\tPL:ILLUMINA\tPM:HISEQ\tSM:${line}"   "$grcz11_basename".fa "${line}"* > /tmp/"${line}".sam
java -jar -Xmx23g picard.jar SortSam INPUT=/tmp/"${line}".sam OUTPUT=/tmp/"${line}"_sorted.bam SORT_ORDER=coordinate
rm /tmp/"${line}".sam
java -jar -Xmx23g picard.jar CollectAlignmentSummaryMetrics R="$grcz11_basename".fa I=/tmp/"${line}"_sorted.bam O="${line}"_alignment_metrics.txt &
java -jar -Xmx23g picard.jar CollectInsertSizeMetrics INPUT=/tmp/"${line}"_sorted.bam OUTPUT="${line}"_insert_metrics.txt HISTOGRAM_FILE="${line}"_insert_size_histogram.pdf &
java -jar -Xmx23g picard.jar MarkDuplicates INPUT=/tmp/"${line}"_sorted.bam OUTPUT="${line}"_dedup_reads.bam METRICS_FILE="${line}"_dedup_reads_metrics.txt
java -jar -Xmx23g picard.jar BuildBamIndex INPUT="${line}"_dedup_reads.bam
rm /tmp/"${line}"_sorted.bam
done < sample.list
