#MOLGENIS walltime=35:59:00 mem=12gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string project
#string snpEffVersion
#string hpoTerms
#string javaVersion
#string molgenisAnnotatorVersion
#string projectDellyAnnotatorOutputVcf

sleep 5


makeTmpDir ${projectDellyAnnotatorOutputVcf}
tmpprojectDellyAnnotatorOutputVcf=${MC_tmpFile}

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

${stage} ${javaVersion}
${stage} ${snpEffVersion}
${stage} ${molgenisAnnotatorVersion}
${checkStage}



#Run Molgenis CmdLineAnnotator with snpEff to add "Gene_Name" to be used for HPO annotation
java -Xmx10g -jar ${EBROOTCMDLINEANNOTATOR}/CmdLineAnnotator-1.9.0.jar \
snpEff \
${EBROOTSNPEFF}/snpEff.jar \
${intermediateDir}/${project}.delly.vcf \
${intermediateDir}/${project}.delly.snpeff.vcf

echo "Finished SnpEff annotation"

#Annotate with HPO
java -Xmx10g -jar ${EBROOTCMDLINEANNOTATOR}/CmdLineAnnotator-1.9.0.jar \
hpo \
${hpoTerms} \
${intermediateDir}/${project}.delly.snpeff.vcf \
${tmpprojectDellyAnnotatorOutputVcf}

echo "Finished HPO annotation"

    mv ${tmpprojectDellyAnnotatorOutputVcf} ${projectDellyAnnotatorOutputVcf}
