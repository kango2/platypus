#!/bin/bash
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l storage=gdata/if89+gdata/xl04
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -N relernn
#PBS -q gpuvolta
#PBS -o /g/data/xl04/hrp561/platypus/wgs/logs/relernnALL.log
#PBS -l mem=90GB

set -ex

module load bcftools
module load pythonlib/3.9.2
module load tensorflow/2.6.0

function runrelernn () {
	VCF=$1
	DIR=$2
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
	rm -rf ${DIR}
	mkdir -p ${DIR}
	MASK="/g/data/xl04/hrp561/platypus/wgs/metadata/accessibility_mask.bed"
	GENOME="/g/data/xl04/hrp561/platypus/wgs/metadata/genome.bed"

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

}

#for chr in autosomes.chrXs
#for chr in `cut -f 1 /g/data/xl04/hrp561/platypus/wgs/metadata/genome.bed`
#do 
##[hrp561@gadi-login-03 wgs]$ wc -l metadata/unrelatedfemales.txt 
##20 metadata/unrelatedfemales.txt
##[hrp561@gadi-login-03 wgs]$ wc -l metadata/unrelatedmales.txt 
##27 metadata/unrelatedmales.txt
##[hrp561@gadi-login-03 wgs]$ wc -l metadata/unrelatedsamples.txt 
##44 metadata/unrelatedsamples.txt




##unrelated samples on autosomes
subsetvcf=/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.44unrelatedsamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.vcf

bcftools view -m2 -M2 -O u \
--samples-file /g/data/xl04/hrp561/platypus/wgs/metadata/unrelatedsamples.txt \
--regions-file /g/data/xl04/hrp561/platypus/wgs/metadata/autosomes.txt \
--trim-alt-alleles \
--max-ac 86 \
-o ${subsetvcf} \
/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.all58samples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf.gz

runrelernn ${subsetvcf} /g/data/xl04/hrp561/platypus/wgs/relernnout/unrelatedsamples

##unrelated male samples on autosomes
subsetvcf=/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.27unrelatedmalesamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.vcf

bcftools view -m2 -M2 -O u \
--samples-file /g/data/xl04/hrp561/platypus/wgs/metadata/unrelatedmales.txt \
--regions-file /g/data/xl04/hrp561/platypus/wgs/metadata/autosomes.txt \
--trim-alt-alleles \
--max-ac 52 \
-o ${subsetvcf} \
/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.all58samples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf.gz

runrelernn ${subsetvcf} /g/data/xl04/hrp561/platypus/wgs/relernnout/unrelatedmalesamples


##unrelated female samples on autosomes
subsetvcf=/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.20unrelatedfemalesamples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.vcf

bcftools view -m2 -M2 -O u \
--samples-file /g/data/xl04/hrp561/platypus/wgs/metadata/unrelatedfemales.txt \
--regions-file /g/data/xl04/hrp561/platypus/wgs/metadata/autosomes.txt \
--trim-alt-alleles \
--max-ac 38 \
-o ${subsetvcf} \
/g/data/xl04/hrp561/platypus/wgs/variants/PlatypusWGS.all58samples.GCF_004115215.2_mOrnAna1.pri.v4.bcftools.Q60SNPAN116.vcf.gz


runrelernn ${subsetvcf} /g/data/xl04/hrp561/platypus/wgs/relernnout/unrelatedfemalesamples
