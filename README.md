# Generate BAM files for variant calls

```
awk -F'\t' '$32=="female"' metadata/PRJEB24914.runinfo.txt |\
	cut -f1,4 |\
	grep -v sample |\
	xargs -l bash -c \
	'qsub -N bwamap -o /g/data/xl04/hrp561/platypus/wgs/logs/$1.bwamap.log -v runid=$0,\
sampleID=$1,\
cn=ENA,\
r1reads=/g/data/xl04/hrp561/platypus/wgs/rawdata/${0}_1.fastq.gz,\
r2reads=/g/data/xl04/hrp561/platypus/wgs/rawdata/${0}_2.fastq.gz,\
reference=/g/data/xl04/hrp561/platypus/ref/GCF_004115215.2_mOrnAna1.pri.v4_genomic.xo.fna,\
outputdir=/g/data/xl04/hrp561/platypus/wgs/v4bam \
/g/data/xl04/hrp561/platypus/wgs/scripts/generatebam.sh' 

awk -F'\t' '$32=="male"' metadata/PRJEB24914.runinfo.txt |\
	cut -f1,4 |\
	grep -v sample |\
	xargs -l bash -c \
	'qsub -N bwamap -o /g/data/xl04/hrp561/platypus/wgs/logs/$1.bwamap.log -v runid=$0,\
sampleID=$1,\
cn=ENA,\
r1reads=/g/data/xl04/hrp561/platypus/wgs/rawdata/${0}_1.fastq.gz,\
r2reads=/g/data/xl04/hrp561/platypus/wgs/rawdata/${0}_2.fastq.gz,\
reference=/g/data/xl04/hrp561/platypus/ref/GCF_004115215.2_mOrnAna1.pri.v4_genomic.fna,\
outputdir=/g/data/xl04/hrp561/platypus/wgs/v4bam \
/g/data/xl04/hrp561/platypus/wgs/scripts/generatebam.sh' 

```

# Filter VCF files

1. Retain sites called in all 58 samples (AN == 116)
2. Retain sites with QUAL >= 60
3. Retain SNPs only

```
module load bcftools

for i in /g/data/xl04/hrp561/platypus/wgs/variants/*vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.vcf.gz;
do 
	bcftools view -O z -o $(dirname ${i})/$(basename ${i} .vcf.gz).Q60SNPAN116.vcf.gz -i 'TYPE="snp" && QUAL>=60 && AN==116' ${i};
	bcftools index --tbi --force $(dirname ${i})/$(basename ${i} .vcf.gz).Q60SNPAN116.vcf.gz
done

```
