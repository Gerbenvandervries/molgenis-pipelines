#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string sampleSheet
#string runResultsDir
#string MCsampleSheet
#string workDir
#string runPrefix

WHOAMI=$(whoami)
. /home/$WHOAMI/molgenis.cfg


echo "Importing Samplesheet into ${MOLGENISSERVER}"
cp ${sampleSheet} ${MCsampleSheet} 

echo "cp ${sampleSheet} to ${runResultsDir}"
cp ${sampleSheet} ${runResultsDir}

SAMPLESHEETNAME=$( ${sampleSheet} .csv )

if [ ! -f ${workDir}/logs/${SAMPLESHEETNAME}.is.uploaded ]
then

	CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
	TOKEN=${CURLRESPONSE:10:32}
	curl -H "x-molgenis-token:${TOKEN}" -X POST -F"file=@${MCsampleSheet}" -Faction=add -Fnotify=false https://${MOLGENISSERVER}/plugin/importwizard/importFile

	touch ${workDir}/logs/${SAMPLESHEETNAME}.is.uploaded
else
	echo "samplesheet already uploaded to ${MOLGENISSERVER}"
fi
