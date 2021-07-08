# echo $MOBSF_URL

# if [ -z "$MOBSF_URL" ] || [ ! -f "$MOBSF_URL" ]; then
#   echo "MOBSF_URL is required to run MobSF action. (MOBSF_URL = $MOBSF_URL)"
#   exit 126
# fi

# if [ -z "$MOBSF_API_KEY" ] || [ ! -f "$MOBSF_API_KEY" ]; then
#   echo "MOBSF_API_KEY is required to run MobSF action. (MOBSF_API_KEY = $MOBSF_API_KEY)"
#   exit 126
# fi

# if [ -z "$INPUT_FILE_NAME" ] || [ ! -f "$INPUT_FILE_NAME" ]; then
#   echo "INPUT_FILE_NAME is required to run MobSF action. (INPUT_FILE_NAME = $INPUT_FILE_NAME)"
#   exit 126
# fi

# if [ -z "$OUTPUT_FILE_NAME" ]; then
#   echo "OUTPUT_FILE_NAME is required to run MobSF action. (OUTPUT_FILE_NAME = $OUTPUT_FILE_NAME)"
#   exit 126
# fi

# if [ -z "$SCAN_TYPE" ]; then
#   echo "OUTPUT_FILE_NAME is required to run MobSF action"
#   exit 126
# else
#   if [ "$SCAN_TYPE" != "apk" ] && [ "$SCAN_TYPE" != "ipa" ] && [ "$SCAN_TYPE" != "appx" ]; then
#     echo "SCAN_TYPE must be apk, ipa or appx. (SCAN_TYPE = $SCAN_TYPE)"
#     exit 126
#   fi
# fi

cd $GITHUB_WORKSPACE

# Upload the app to MobSF.
echo "[/api/v1/upload] Upload the app to MobSF"
RESPONSE=$(curl -F file=@${INPUT_FILE_NAME} ${MOBSF_URL}/api/v1/upload -H "Authorization:${MOBSF_API_KEY}")
# use 'jq' to search the values by keys in the json response.
FILE_NAME=$(echo "${RESPONSE}" | jq -r .file_name)
HASH=$(echo "${RESPONSE}" | jq -r .hash)
SCAN_TYPE=$(echo "${RESPONSE}" | jq -r .scan_type)
# Trim spaces on the end of variables:
FILE_NAME=${FILE_NAME%%*( )}
HASH=${HASH%%*( )}
SCAN_TYPE=${SCAN_TYPE%%*( )}
echo "[/api/v1/upload] Received: FILE_NAME=${FILE_NAME}, HASH=${HASH}, SCAN_TYPE=${SCAN_TYPE}"

# Start the scan.
echo "[/api/v1/scan] Start the scan"
curl -X POST --url ${MOBSF_URL}/api/v1/scan --data "scan_type=${SCAN_TYPE}&file_name=${FILE_NAME}&hash=${HASH}" -H "Authorization:${MOBSF_API_KEY}"
echo "[/api/v1/scan] Scan finisehd"

# Generate the json report.
echo "[/api/v1/report_json] Generate the json report"
curl -X POST --url ${MOBSF_URL}/api/v1/report_json --data "hash=${HASH}" -H "Authorization:${MOBSF_API_KEY}" --output ${OUTPUT_FILE_NAME}.json
echo "[/api/v1/report_json] JSON report generated"

# Generate the pdf report.
echo "[/api/v1/download_pdf] Generate the PDF report"
curl -X POST --url ${MOBSF_URL}/api/v1/download_pdf --data "hash=${HASH}" -H "Authorization:${MOBSF_API_KEY}" --output ${OUTPUT_FILE_NAME}.pdf
echo "[/api/v1/download_pdf] PDF report generated"

# Remove analysis from MobSF server.
# echo "[/api/v1/delete_scan] Remove analysis from MobSF server"
# curl -X POST --url ${MOBSF_URL}/api/v1/delete_scan --data "hash=${HASH}" -H "Authorization:${MOBSF_API_KEY}"
# echo "[/api/v1/delete_scan] Analysis removed"
