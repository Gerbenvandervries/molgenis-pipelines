#MOLGENIS walltime=3:00:00 mem=10gb ppn=2

### variables to help adding to database (have to use weave)
#string project
#string sampleName
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string dbsnpVcf
#string dbsnpVcfIdx

#string tabixVersion
#string genotypeHarmonizerVersion
#string samtoolsVersion
#string haplotyperDir
#string bqsrDir
#string projectDir
#string ASReadsDir
#string couplingFile
#string bqsrBam
#string ASReads
#string bqsrDir
#string AseVersion
echo "## "$(date)" Start $0"

getFile ${genotypedVcf}

#Load gatk module
${stage} tabix/${tabixVersion}
${stage} GenotypeHarmonizer/${genotypeHarmonizerVersion}
${stage} ASE/${AseVersion}
${checkStage}

mkdir -p ${ASReadsDir}

bgzip -c ${imputedVcf} > ${genotypedVcf}.gz
tabix -p vcf ${genotypedVcf}.gz
GenotypeHarmonizer.sh --input ${imputedVcf}.gz --outputType TRITYPER --output ${ASReadsDir}
ls ${bqsrDir}*.bam | awk {'gsub(".bam","",$1); gsub("${bqsrDir}","",$1); print $1 "\t"  $1}' > ${couplingFile}

if java -XX:ParallelGCThreads=2 -jar ${EBROOTASE}/cellTypeSpecificAlleleSpecificExpression.jar \
--action 1 \
--output ${ASReads} \
--coupling_file ${couplingFile} \
--genotype_location ${ASReadsDir} \
--bam_file ${bqsrBam}

then
 echo "returncode: $?";
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
