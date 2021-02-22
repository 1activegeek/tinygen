#!/bin/bash
>/usr/local/tinygen/tools/aliases.txt
 for ipaddr in `ip addr | grep secondary | awk '{print $2 }'` 
 do echo $ipaddr>> /usr/local/tinygen/tools/aliases.txt
 done

