#MOLGENIS walltime=20:00:00 nodes=1 ppn=4 mem=6gb

#Parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string indexFile
#string tmpIntermediateDir
#string bwaAlignCores
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string tmpIntermediateDir
#string tmpAlignedSam
#string alignedSam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${seqType}"
echo "bwaVersion: ${bwaVersion}"
echo "indexFile: ${indexFile}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "bwaAlignCores: ${bwaAlignCores}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "tmpAlignedSam: ${tmpAlignedSam}"
echo "alignedSam: ${alignedSam}"

sleep 10

#If paired-end then copy 2 files, else only 1
alloutputsexist \
"${alignedSam}"

getFile ${indexFile}
if [ ${seqType} == "PE" ]
then

	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else

	getFile ${srBarcodeFqGz}

fi

#Load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

#Create tmp dir
mkdir -p "${tmpIntermediateDir}"

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"

#If paired-end use two fq files as input, else only one
if [ ${seqType} == "PE" ]
then
    #Run BWA for paired-end
    bwa mem \
    -M \
    -R $READGROUPLINE \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${peEnd1BarcodeFqGz} \
    ${peEnd2BarcodeFqGz} \
    > ${tmpAlignedSam}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: $returnCode\n\n"

    if [ $returnCode -eq 0 ]
    then
		echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpAlignedSam} ${alignedSam}
		putFile "${alignedSam}"
    else
		echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
		exit -1
    fi
    
else
    #Run BWA for single-read
    bwa mem \
    -M \
    -R $READGROUPLINE \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${srBarcodeFqGz} \
    > ${tmpAlignedSam}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: $returnCode\n\n"

    if [ $returnCode -eq 0 ]
    then
		echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpAlignedSam} ${alignedSam}
		putFile "${alignedSam}"
    else
		echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
		exit -1
    fi
fi

