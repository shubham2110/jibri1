#! /bin/bash

logfile="/config/jibri/logs/recording.log"

if [ ! -d "/config/jibri/logs/" ] ; then
        mkdir "/config/jibri/logs/" ; chown -R jibri:jibri "/config/jibri/logs/" ; touch $logfile
        [ "$?" == 0 ] && echo "$(date)|Logs Dir Not found and created successfully" >>$logfile
fi


RECORDINGS_DIR=$1
echo "Recording dir is: $RECORDINGS_DIR"  >> $logfile
#echo "\nJibri recording directory is: $JIBRI_RECORDING_DIR"

# Find files in directory
_recording=$(find ${RECORDINGS_DIR} -type f -name "*.mp4" -exec basename {} .mp4 \; 2>>$logfile)

# check file list
#echo -e "Hi ,\n\nNew conference recording is available:\n\n ${_recording}"

# Move the .mp4 file
mv "$RECORDINGS_DIR/${_recording}.mp4" "$RECORDINGS_DIR/${_recording}_full.mp4"

# ffmpeg need some time to finalize the .mp4 - then remove old folder
# compress recording
ffmpeg -i "$RECORDINGS_DIR/${_recording}_full.mp4" -vcodec h264 -acodec aac "$RECORDINGS_DIR/${_recording}.mp4"
echo "$(date)|RecordingPath: $RECORDINGS_DIR/${_recording}.mp4" >> $logfile

full_file_size=$(du -sh "$RECORDINGS_DIR/${_recording}_full.mp4" | tr [:space:] ',' | cut -d',' -f1)
file_size=$(du -sh "$RECORDINGS_DIR/${_recording}.mp4" | tr [:space:] ',' | cut -d',' -f1)

rm "$RECORDINGS_DIR/${_recording}_full.mp4" "$RECORDINGS_DIR/metadata.json"

echo "\n Using Rclone to move the file to aws s3 bucket"
#/usr/bin/rclone copy ${RECORDINGS_DIR}/*.mp4 googledrive:meet.docadena.in/videos/ -v --log-file=/config/rclone/rclone.log
#move to S3 Bucket using rclone
echo -n "$(date)|" >> $logfile
#aws s3 cp "$RECORDINGS_DIR/" "s3://nextmeet-recordings${RECORDINGS_DIR}/" --recursive >> $logfile
/usr/bin/rclone copy /config/jibri/recording amazons3:nextmeet-recordings/recordings/ -v --log-file=/config/rclone/rclone.log >> $logfile


if [ "$?" == 0 ]; then
echo "$(date)|Upload successfully" >> $logfile

#remove folder from jitsi server
#dir_nm=$(echo $RECORDINGS_DIR | awk -F'/' '{print $3}')
#cd /recordings
rm -rf ${RECORDINGS_DIR}
#cd -

else
echo "$(date)|Couldn't Upload successfully $?" >> $logfile
fi


echo "$(date)|ActualFileSize: $full_file_size" >> $logfile
echo "$(date)|CompressedFileSize: $file_size" >> $logfile

# rmoving extra path from url
short_path=${RECORDINGS_DIR#/config/jibri/recording}
final_path="/recordings${short_path}"
echo "$(date)|Short Path is ${short_path}" >> $logfile
echo "$(date)|Final Path is ${final_path}" >> $logfile
echo "$(date)|_recording is ${_recording}" >> $logfile


curl --header "Content-Type: application/json"  --request POST  --data "{\"recording_path\":\"${final_path}/${_recording}.mp4\", \"file_size\":\"$file_size\"}" https://api.nextmeet.in/api/v1/update_recording_path >>$logfile
echo "----------------------------------------------------------" >> $logfile