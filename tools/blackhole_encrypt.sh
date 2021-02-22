#!/bin/bash
blackhole -ssl=False -host=192.168.88.89 --pid=/tmp/blackhole_encrypt.pid --group=root -user=root -mode=accept -port=10025 --message_size_limit=9000000 $1
