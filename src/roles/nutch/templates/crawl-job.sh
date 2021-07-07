#!/bin/bash

export DISPLAY=:0 
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64
cd {{ nutch_path }}/apache-nutch-{{nutch_version}}

## Get current date ##
_now=$(date +"%m_%d_%Y")
_log="/tmp/nutch_cron_$_now.log"

bin/crawl -i -s urls/seed.txt crawl/ 1 >> $_log 2>&1
