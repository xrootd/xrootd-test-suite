#!/bin/bash

source /etc/XrdTest/utils/functions.sh

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------
HOSTNAME="`hostname`"
DATASOURCE="http://xrootd.cern.ch/tests/test-files/"
REPOFILES="@proto@://master.xrd.test:@port@/downloadScript/"
#REPOFILES="http://xrootd.cern.ch/tests/test-scripts/"
CONFIGDIR=/test-suites/xrootd_new_client_tests/config/
FILES=
BIGDIR=no
CURRENTDIR=`pwd`
TEMPDIR=`mktemp -d /tmp/xrd-tests.XXXXXXXXXX`
EXTRAPACKAGES="python-mechanize python-lxml cppunit"

if [ x$HOSTNAME == xsrv1 ]; then
  BIGDIR=yes
  FILES="a048e67f-4397-4bb8-85eb-8d7e40d90763.dat"
  FILES="$FILES b3d40b3f-1d15-4ad3-8cb5-a7516acb2bab.dat"
  FILES="$FILES b74d025e-06d6-43e8-91e1-a862feb03c84.dat"
  FILES="$FILES cb4aacf1-6f28-42f2-b68a-90a73460f424.dat"
  FILES="$FILES cef4d954-936f-4945-ae49-60ec715b986e.dat"
elif [ x$HOSTNAME == xsrv2 ]; then
  BIGDIR=yes
  FILES="1db882c8-8cd6-4df1-941f-ce669bad3458.dat"
  FILES="$FILES 3c9a9dd8-bc75-422c-b12c-f00604486cc1.dat"
  FILES="$FILES 7235b5d1-cede-4700-a8f9-596506b4cc38.dat"
  FILES="$FILES 7e480547-fe1a-4eaf-a210-0f3927751a43.dat"
  FILES="$FILES 89120cec-5244-444c-9313-703e4bee72de.dat"
elif [ x$HOSTNAME == xsrv3 ]; then
  BIGDIR=yes
  FILES="1db882c8-8cd6-4df1-941f-ce669bad3458.dat"
  FILES="$FILES 3c9a9dd8-bc75-422c-b12c-f00604486cc1.dat"
  FILES="$FILES 89120cec-5244-444c-9313-703e4bee72de.dat"
  FILES="$FILES b74d025e-06d6-43e8-91e1-a862feb03c84.dat"
  FILES="$FILES cef4d954-936f-4945-ae49-60ec715b986e.dat"
elif [ x$HOSTNAME == xsrv4 ]; then
  BIGDIR=yes
  FILES="1db882c8-8cd6-4df1-941f-ce669bad3458.dat"
  FILES="$FILES 7e480547-fe1a-4eaf-a210-0f3927751a43.dat"
  FILES="$FILES 89120cec-5244-444c-9313-703e4bee72de.dat"
  FILES="$FILES b74d025e-06d6-43e8-91e1-a862feb03c84.dat"
  FILES="$FILES cef4d954-936f-4945-ae49-60ec715b986e.dat"
elif [ x$HOSTNAME == xclient1 ]; then
  FILES="a048e67f-4397-4bb8-85eb-8d7e40d90763.dat"
fi

#-------------------------------------------------------------------------------
# Start the show
#-------------------------------------------------------------------------------
log "Setting stuff up at $HOSTNAME..."

#-------------------------------------------------------------------------------
# Install necessary packages
#-------------------------------------------------------------------------------
for PACK in $EXTRAPACKAGES; do
  log "Installing $PACK..."
  run yum install -y $PACK
done

#-------------------------------------------------------------------------------
# Mount the extra parition if present
#-------------------------------------------------------------------------------
if [ x"`cat /proc/partitions | grep vda`" != x ]; then
  if [ x"`mount | grep /dev/vda`" != x ]; then
    log "/dev/vda already mounted"
  else
    log "Mounting /dev/vda at /data"
    run mkdir -p /data
    run mount -o user_xattr /dev/vda /data
  fi
fi

#-------------------------------------------------------------------------------
# Download the necessary datafiles
#-------------------------------------------------------------------------------
if [ x"$FILES" != x ]; then
  cd /data
  for FILE in $FILES; do
    if [ ! -e $FILE ]; then
      log "Downloading $DATASOURCE/$FILE"
      run wget $DATASOURCE/$FILE
    else
      log "File $FILE alredy exists"
    fi
  done
  cd $CURRENTDIR
fi

#-------------------------------------------------------------------------------
# Create the bigdir
#-------------------------------------------------------------------------------
if [ x"$BIGDIR" == xyes ]; then
  cd /data
  if [ ! -e bigdir ]; then
    log "Creating bigdir..."
    run mkdir bigdir
    for i in `seq 10000`; do
      run touch bigdir/`uuidgen`
    done
  else
    log "Bigdir already exists"
  fi
  cd $CURRENTDIR
fi

#-------------------------------------------------------------------------------
# Uninstall all the xrootd packages if there are any
#-------------------------------------------------------------------------------
log "Uninstalling any previously installed xrootd RPMs..."
PKGS=`rpm -qa | grep xrootd`
if [ x"$PKGS" != x ]; then
  run rpm -e $PKGS
fi

#-------------------------------------------------------------------------------
# Download and install all the necessary xrootd packages
#-------------------------------------------------------------------------------
log "Downloading latest RPMs..."
cd $TEMPDIR
run wget --no-check-certificate $REPOFILES/test-suites/utils/download-teamcity.py
run chmod 755 download-teamcity.py
run ./download-teamcity.py
run unzip artifacts.zip
cd slc-6-x86_64
run rm -rf logs manifest.txt xrootd-*.src.rpm
VERSION="`ls -1 | grep -E 'xrootd-[[:digit:]].*' | sed 's/xrootd-//'`"
VERSION="`echo $VERSION | sed 's/.rpm//'`"
log "Installing $VERSION..."
rpm -i *.rpm
cd $CURRENTDIR
rm -rf $TEMPDIR

#-------------------------------------------------------------------------------
# Change file permissions if needed
#-------------------------------------------------------------------------------
if [ -e /data ]; then
  log "Changing file permissions..."
  run chown xrootd:xrootd -R /data
fi

#-------------------------------------------------------------------------------
# Download the configuration files and start the daemons
#-------------------------------------------------------------------------------
log "Setting up the daemons..."
cd /etc/xrootd/
run rm -f meta_setup.cfg
run wget --no-check-certificate $REPOFILES/$CONFIGDIR/meta_setup.cfg
cd /etc/sysconfig/
run rm -f xrootd
if [ x$HOSTNAME == x"srv2" ]; then
  run wget --no-check-certificate $REPOFILES/$CONFIGDIR/xrootd.sysconfig.meta_and_standalone
  run mv xrootd.sysconfig.meta_and_standalone xrootd
  cd /etc/xrootd
  run rm -f xrootd-standalone.cfg
  run wget --no-check-certificate $REPOFILES/$CONFIGDIR/xrootd-standalone.cfg
else
  run wget --no-check-certificate $REPOFILES/$CONFIGDIR/xrootd.sysconfig.default
  run mv xrootd.sysconfig.default xrootd
fi

cd $CURRENTDIR

