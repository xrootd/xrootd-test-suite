#!/bin/bash

source /etc/XrdTest/utils/functions.sh

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------
HOSTNAME="`hostname`"

#-------------------------------------------------------------------------------
# Install stuff
#-------------------------------------------------------------------------------
if [ x"$HOSTNAME" == x"client1" ]; then
  log "Installing cppunit-text-runner..."
  run yum install -y cppunit-text-runner
else
  log "Starting up xrootd services"
  run service xrootd start
  run service cmsd start
fi
