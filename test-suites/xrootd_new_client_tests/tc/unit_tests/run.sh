#!/bin/bash

source /etc/XrdTest/utils/functions.sh

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------
HOSTNAME="`hostname`"

if [ x"$HOSTNAME" == x"client1" ]; then
  #-----------------------------------------------------------------------------
  # Set up the envvars
  #-----------------------------------------------------------------------------
  log "Setting up the envvars..."
  export XRDTEST_MAINSERVERURL=metaman.xrd.test
  export XRDTEST_DISKSERVERURL=srv1.xrd.test
  export XRDTEST_LOCALFILE=/data/a048e67f-4397-4bb8-85eb-8d7e40d90763.dat
  export XRDTEST_MULTIIPSERVERURL=multiip.xrd.test
  log "XRDTEST_MAINSERVERURL:    $XRDTEST_MAINSERVERURL"
  log "XRDTEST_DISKSERVERURL:    $XRDTEST_DISKSERVERURL"
  log "XRDTEST_LOCALFILE:        $XRDTEST_LOCALFILE"
  log "XRDTEST_MULTIIPSERVERURL: $XRDTEST_MULTIIPSERVERURL"

  #-----------------------------------------------------------------------------
  # Run the test suite
  #-----------------------------------------------------------------------------
  set -e
  cppunit-text-runner /usr/lib64/libXrdClTests.so "All Tests"
  set +e
fi
