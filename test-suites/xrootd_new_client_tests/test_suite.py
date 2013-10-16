from XrdTest.TestUtils import TestSuite, TestCase

def getTestSuite():
  ts = TestSuite( "xrootd_new_client_tests" )
  ts.clusters = ['cluster_meta_manager']
  ts.tests = ['unit_tests']
  ts.schedule = dict(second='00', minute='00', hour='00', day='*', month='*')
  ts.initialize = "file://suite_init.sh"
  ts.finalize = "file://suite_finalize.sh"
  ts.logs = ['/var/log/xrootd/meta/xrootd.log',
             '/var/log/xrootd/meta/cmsd.log',
             '/var/log/xrootd/xrootd.log',
             '/var/log/xrootd/cmsd.log']


  ts.alert_emails = ['ljanyst@cern.ch']
  ts.alert_success = 'NONE'
  ts.alert_failure = 'SUITE'
  return ts
