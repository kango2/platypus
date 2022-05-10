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
