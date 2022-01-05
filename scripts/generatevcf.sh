#!/bin/bash
##PBS -l ncpus=28,mem=128GB,walltime=48:00:00
##PBS -N bcfcall
##PBS -j oe
##PBS -q normalbw
##PBS -P xl04

contigid=$1

module load bcftools

set -euxo pipefail

bcftools mpileup --regions ${contigid} --threads 14 -O u --adjust-MQ 50 --min-MQ 20 --min-BQ 20 --excl-flags UNMAP,SECONDARY,QCFAIL,DUP --incl-flags 3 \
--fasta-ref GCF_004115215.2_mOrnAna1.pri.v4_genomic.fna \
--bam-list vsGCF_004115215.2_mOrnAna1.pri.v4.BAMlist.txt |\
 bcftools call -mv --threads 14 -O z \
-o variants/${contigid}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.vcf.gz \
-A -M --variants-only

touch variants/${contigid}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.done
