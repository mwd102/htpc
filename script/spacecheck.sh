#!/bin/bash
CURRENT=$(du -sh /data | awk '{ print $1}' | sed 's/%//g')

RCLONETVPID=`ps aux | grep rclone | grep cache | grep tv | awk '{ print $2}'`
SIGHUPTV="kill -SIGHUP $RCLONETVPID"
RCLONEMOVPID=` ps aux | grep rclone | grep cache | grep mov | awk '{ print $2}'`
SIGHUPMOV="kill -SIGHUP $RCLONEMOVPID"

if [ "${CURRENT: -1}" = "G" ]; then
	gigs=(${CURRENT//./ })
	gb=${gigs[0]}
	if [ $gb -gt 14 ]; then
		echo "$(date) - Space too large, syncing to cloud"
		rclone copy /data/sonarr/upload b2:tv-enc && rm -rf /data/sonarr/upload/*
		eval $SIGHUPTV
		rclone copy /data/radarr b2:movies-enc && rm -rf /data/radarr/*
		eval $SIGHUPMOV
		echo "$(date) - Done"
	fi
fi
