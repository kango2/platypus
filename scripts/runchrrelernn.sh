#!/bin/bash
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l walltime=04:00:00
#PBS -j oe
#PBS -N relernn
#PBS -q gpuvolta
#PBS -l mem=90GB

set -ex

module load bcftools
module load pythonlib/3.9.2
module load tensorflow

RUNPATH=$(realpath $(dirname $0))

for chr in `cut -f 1 ${RUNPATH}/../metadata/genome.bed`
do 

bcftools view -m2 -M2 -O u -o ${RUNPATH}/../variants/${chr}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf \
${RUNPATH}/../variants/${chr}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf.gz

SIMULATE="ReLERNN_SIMULATE"
TRAIN="ReLERNN_TRAIN"
PREDICT="ReLERNN_PREDICT"
BSCORRECT="ReLERNN_BSCORRECT"
CPU="12"
#MU="1e-8"
#mutation rate and generation time from https://doi.org/10.1093/molbev/msy041
MU="0.0000000070"
AGT="10"
RTR="1"
DIR="${RUNPATH}/../relernnout/${chr}"
rm -rf ${DIR}
mkdir -p ${DIR}
VCF="${RUNPATH}/../variants/${chr}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf"
GENOME="${RUNPATH}/../metadata/${chr}.bed"
MASK="${RUNPATH}/../metadata/accessibility_mask.bed"

grep ${chr} ${RUNPATH}/../metadata/genome.bed >${GENOME}
#    --mask ${MASK} \

# Simulate data
${SIMULATE} \
    --vcf ${VCF} \
    --genome ${GENOME} \
    --unphased \
    --projectDir ${DIR} \
    --assumedMu ${MU} \
    --assumedGenTime ${AGT} \
    --upperRhoThetaRatio ${RTR} \
    --nTrain 12800 \
    --nVali 2000 \
    --nTest 100 \
    --nCPU ${CPU}

# Train network
${TRAIN} \
    --projectDir ${DIR} \
    --nEpochs 2 \
    --nValSteps 2

# Predict
${PREDICT} \
    --vcf ${VCF} \
    --projectDir ${DIR}

# Parametric Bootstrapping
${BSCORRECT} \
    --projectDir ${DIR} \
    --nCPU ${CPU} \
    --nSlice 2 \
    --nReps 2

rm ${RUNPATH}/../variants/${chr}.20211213.vsGCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf
rm ${GENOME}
done
