#!/bin/bash

SAMPLE=$1

REF=$2

THREADS=$3

MEM=$4

DOCKERCMD="time -o metashiny_${SAMPLE}_${THREADS}.txt docker run -v $PWD:$PWD --name metashiny_${THREADS} --cpus ${THREADS} --memory ${MEM}g --workdir $PWD --rm metashiny:latest bash /module/rgi_main.sh -s ${SAMPLE} -r ${REF} -t ${THREADS} -m ${MEM}"

date +"[%Y-%m-%d %H:%M:%S] Starting Run using the contained : metashiny:latest"

$DOCKERCMD &

while true 
do
	DOCKERID=$(docker ps --format '{{.ID}}')
	if [ -z "$DOCKERID" ];then
	 echo "Not running"
	else
	docker stats --no-stream | grep metashiny_${THREADS} | awk '{print $4}' >> metashiny_${SAMPLE}_${THREADS}_mem_usage.txt &  docker stats --no-stream | grep metashiny_${THREADS} | awk '{print $3}' >> metashiny_${SAMPLE}_${THREADS}_cpu_usage.txt &  docker stats --no-stream | grep metashiny_${THREADS} | awk '{print $7}' >> metashiny_${SAMPLE}_${THREADS}_peak_mem.txt;
	docker ps --no-trunc | grep "${DOCKERID}" >/dev/null;
		if [ $? -ne 0 ];then
		
		break
		
		fi
	fi
done

date +"[%Y-%m-%d %H:%M:%S] Finished benchmark"
