#!bin/sh
set -e

echo "Starting container ..."
if [ ! -f "$RESTIC_REPOSITORY/config" ]; then
    echo "Restic repository '${RESTIC_REPOSITORY}' does not exists. Running restic init."
    restic init | true
fi
echo "Get marathon apps confing via curl"
start=`date +%s`
echo "Starting Backup at $(date +"%Y-%m-%d %H:%M:%S")"
echo "RESTIC_FORGET_ARGS: ${RESTIC_FORGET_ARGS}"
curl -XGET ${MARATHON_API_URI} | jq '.'  > /mnt/marathon_apps/marathon_apps_backup.json

#do backup
restic backup /mnt/marathon_apps
rc=$?
echo "Finished backup at $(date)"
echo "Current snapshots : "
restic snapshots

if [[ $rc == 0 ]]; then
    echo "Backup Successfull"
else
    echo "Backup Failed with Status ${rc}"
    restic unlock
fi

if [ -n "${RESTIC_FORGET_ARGS}" ]; then
    echo "Forget about old snapshots based on RESTIC_FORGET_ARGS = ${RESTIC_FORGET_ARGS}"
    restic forget ${RESTIC_FORGET_ARGS}
    rc=$?
    echo "Finished forget at $(date)"
    if [[ $rc == 0 ]]; then
        echo "Forget Successfull"
    else
        echo "Forget Failed with Status ${rc}"
        restic unlock
    fi
fi

end=`date +%s`
echo "Finished Backup at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) sconds"

