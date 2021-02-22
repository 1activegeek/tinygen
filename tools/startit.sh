#!/bin/bash
echo starting runit CentOS > /tmp/startup.log
/usr/local/tinygen/runit.CentOS.sh > /tmp/runit.log &
echo starting runit EP >> /tmp/startup.log
/usr/local/tinygen/runit_ep.sh &
echo resetting aliases >> /tmp/startup.log
/usr/local/tinygen/tools/reset_aliases.sleep &
