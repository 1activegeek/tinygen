#!/bin/bash
blackhole -ssl=False -host=192.168.88.68 --group=root -user=root -mode=accept -port=2525 --message_size_limit=9000000 $1
