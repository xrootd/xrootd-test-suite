#!/usr/bin/env python
import mechanize
import lxml.etree
import sys
import subprocess

try:
  br = mechanize.Browser()
  response = br.open( 'https://teamcity-dss.cern.ch:8443/guestAuth/app/rest/buildTypes/id:bt45/builds' )
  buildDoc = lxml.etree.fromstring( response.read() )
  tags = buildDoc.xpath( '//build[@status="SUCCESS"]' )
  if not tags:
    print >> sys.stderr, '[!] No successful builds found'
    sys.exit(1)
  artifacts = 'https://teamcity-dss.cern.ch:8443/guestAuth/repository/downloadAll/bt45/' + tags[0].attrib['id'] + ':id/artifacts.zip'
  print >> sys.stderr, 'Downloading:', artifacts
  subprocess.check_call('wget --no-check-certificate --quiet ' + artifacts, shell=True)
except Exception, e:
  print >> sys.stderr, 'Problem downloading file', e
  sys.exit(1)
