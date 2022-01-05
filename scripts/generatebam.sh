#!/bin/bash
#PBS -j oe
#PBS -l ncpus=16
#PBS -l mem=63GB
#PBS -l walltime=24:00:00
#PBS -P xl04
#PBS -l jobfs=390GB


##howto:
##qsub -N bwamap -v runid=ERR2298694,sampleID=SAMEA104585233,cn=ENA,\
##r1reads=ERR2298694_1.fastq.gz,r2reads=ERR2298694_2.fastq.gz,\
##reference=GCF_004115215.2_mOrnAna1.pri.v4_genomic.fna,outputdir=v4bam generatebam.sh


module load bwa samtools
set -e          #exit on error
set -o pipefail #set exit status of pipeline to the rightmost failed command 
set -u          #unset variables treated as error
set -x          #print command before executing
set -o functrace

bwa mem -t ${PBS_NCPUS} -K 100000000 -Y -R "@RG\tID:${runid}\tPL:ILLUMINA\tCN:${cn}\tSM:${sampleID}\tPI:500\tPU:${runid}" $reference ${r1reads} ${r2reads} |\
samtools fixmate -m --threads ${PBS_NCPUS} --reference $reference - - |\
samtools sort --threads ${PBS_NCPUS} -m 1536M --reference $reference -T ${PBS_JOBFS}/${sampleID}.${runid}.sorttmp |\
samtools markdup -T ${PBS_JOBFS}/${sampleID}.${runid}.deduptmp -O BAM --reference $reference --threads ${PBS_NCPUS} - ${outputdir}/${sampleID}.${runid}.fmsortdedup.bam

samtools index ${outputdir}/${sampleID}.${runid}.fmsortdedup.bam

touch ${outputdir}/${sampleID}.${runid}.map.done
