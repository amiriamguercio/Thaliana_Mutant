##JGCRZ_pipe##

##reads from experiment performed at UC Riverside by A. Guercio and J.Goff 
##flowcell718_lane1_pair1_TGACCA.fastq.gz                 (JGCRZ)
##flowcell718_lane1_pair2_TGACCA.fastq.gz                 (JGCRZ)



##	##Trimmomatic Script##  ##

module load trimmomatic

java -jar /opt/linux/centos/7.x/x86_64/pkgs/trimmomatic/0.33/bin/trimmomatic.jar PE -phred33 \
/rhome/guercioa/shared/SEQ_RUNS/10_12_2017/FASTQ/illumina.bioinfo.ucr.edu/illumina_runs/718/flowcell718_lane1_pair1_TGACCA.fastq.gz \
/rhome/guercioa/shared/SEQ_RUNS/10_12_2017/FASTQ/illumina.bioinfo.ucr.edu/illumina_runs/718/flowcell718_lane1_pair2_TGACCA.fastq.gz \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZforward_paired.fq.gz \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZforward_unpaired.fq.gz \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZreverse_paired.fq.gz \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZreverse_unpaired.fq.gz \
ILLUMINACLIP:/opt/linux/centos/7.x/x86_64/pkgs/trimmomatic/0.33/adapters/TruSeq3-SE.fa:2:30:10 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:75




##	##Align + Sam -> Bam Script##   ##

module load bwa
module load samtools


bwa mem -t 10 -R "@RG\tID:Columbia_Analyses\tSM:JGCRZ\tPL:ILLUMINA" \
/rhome/guercioa/bigdata/thaliana_JGCRZ/thaliana_index/thaliana_index \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZforward_paired.fq.gz \
/rhome/guercioa/bigdata/thaliana_JGCRZ/trimmed_reads/JGCRZreverse_paired.fq.gz \
| samtools sort -T /rhome/guercioa/bigdata/thaliana_JGCRZ/raw_alignments/tmp \
-O bam \
-o /rhome/guercioa/bigdata/thaliana_JGCRZ/raw_alignments/JGCRZ_rawalns.bam




##	##Removing Duplicates with Picard Script##	##

module load picard


java -jar /opt/linux/centos/7.x/x86_64/pkgs/picard/2.10.0/lib/picard.jar MarkDuplicates \
INPUT= /rhome/guercioa/bigdata/thaliana_JGCRZ/raw_alignments/JGCRZ_rawalns.bam \
OUTPUT= /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/JGCRZ_dupfree.bam \
METRICS_FILE= /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/JGCRZ_dupinfo.txt \
REMOVE_DUPLICATES=true \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR= /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/tmp



##	##Indexing reads for GATK##	##

module load samtools


samtools index /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/JGCRZ_dupfree.bam




##	##GATK Realign Around Indels Script##	##

module load gatk


##First use realigner target creator

java -jar /opt/linux/centos/7.x/x86_64/pkgs/gatk/3.7/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R /rhome/guercioa/bigdata/thaliana_JGCRZ/thaliana_index/thaliana_index.fa \
-I /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/JGCRZ_dupfree.bam \
-o /rhome/guercioa/bigdata/thaliana_JGCRZ/realigned_bams/JGCRZint.intervals


##Then use this outfile to help realign with indel realigner

java -jar /opt/linux/centos/7.x/x86_64/pkgs/gatk/3.7/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R /rhome/guercioa/bigdata/thaliana_JGCRZ/thaliana_index/thaliana_index.fa \
-I /rhome/guercioa/bigdata/thaliana_JGCRZ/dupfree_alignments/JGCRZ_dupfree.bam \
-targetIntervals /rhome/guercioa/bigdata/thaliana_JGCRZ/realigned_bams/JGCRZint.intervals \
-o /rhome/guercioa/bigdata/thaliana_JGCRZ/realigned_bams/JGCRZ_realn.bam


##Now take this file into the SNP-caller script.















