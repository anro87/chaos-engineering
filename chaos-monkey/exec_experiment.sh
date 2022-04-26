#!/bin/bash
source setup.sh

mkdir -p journals

chaos run --rollback-strategy=always --journal-path ./journals/exp1.json ./experiments/experiment1.json

chaos run --rollback-strategy=always --journal-path ./journals/exp2.json ./experiments/experiment2.json
echo "Waiting for EC2-Instance to reboot..."
sleep 120

chaos run --rollback-strategy=always --journal-path ./journals/exp3.json ./experiments/experiment3.json

chaos run --rollback-strategy=always --journal-path ./journals/exp4.json ./experiments/experiment4.json

chaos run --rollback-strategy=always --journal-path ./journals/exp5.json ./experiments/experiment5.json

#Generate report
docker run --user `id -u` -v `pwd`:/tmp/result -it chaostoolkit/reporting
docker run --user `id -u` -v `pwd`:/tmp/result -it chaostoolkit/reporting -- report --export-format=pdf ./journals/*.json report.pdf
