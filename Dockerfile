FROM kamsz/restic:0.7.3
LABEL MAINTAINER="Adam Drozdz <adrozdz@container-labs.com>"
LABEL NAME="marathon_backup"

RUN apk add --no-cache curl jq

RUN mkdir /mnt/marathon_bck
RUN mkdir /mnt/marathon_apps

ENV RESTIC_PASSWORD=test
ENV RESTIC_BCK=/mnt/marathon_apps
# change to s3:bucket
ENV RESTIC_REPOSITORY=/mnt/marathon_bck
ENV RESTIC_FORGET_ARGS="--keep-last 10"
ENV MARATHON_API_URI=http://localhost:8080/v2/apps

COPY entry.sh /entry.sh

WORKDIR "/"

ENTRYPOINT ["/entry.sh"]
