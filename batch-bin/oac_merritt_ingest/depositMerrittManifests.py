#!/usr/bin/env python

import os, time, shlex, subprocess

#############################################################################
#############################################################################
class OacMerrittDeposit:

  def __init__(self):
    """ constructor """
    self.manifestDir = '/apps/dsc/data/xtf/data/13030/manifests'
    self.merrittPem = '/apps/dsc/workspace/oac-merritt-ingest/merritt-stage.pem'
    self.merrittUrl = 'https://merritt-stage.cdlib.org/object/ingest'

#############################################################################
  def depositManifests(self):
    """ deposit existing OAC batch manifests to Merritt repository """
    manifests = os.listdir(self.manifestDir)
    for manifest in manifests:
      #if manifest.endswith('checkm'):
      if manifest == '13030mt.checkm': # for testing object with most components (hb5199p1mt with 5668 files)
        self.depositBatch(os.path.join(self.manifestDir, manifest))
        time.sleep(2) # pause 2 seconds

#############################################################################
  def depositBatch(self, filename):
    """ deposit a batch manifest to Merritt """     
    print '\ndepositing', filename
    apiCmd = 'curl --silent' \
    + '-u bhui:xxxxxxxx ' \
    + '-k ' \
    + '-F "file=@' + filename + '" ' \
    + '-F "type=batch-manifest" ' \
    + '-F "profile=cdl_oac_content" ' \
    + self.merrittUrl
    args = shlex.split(apiCmd)
    p = subprocess.Popen(args, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    return_code = p.wait()
    print "return_code:", return_code
    print "stdout:"
    for line in p.stdout:
      print(line.rstrip())
    print "stderr:"
    for line in p.stdout:
      print("stderr: " + line.rstrip())

#############################################################################
def depositManifests():
  deposit = OacMerrittDeposit()
  deposit.depositManifests()

#############################################################################
if __name__ == '__main__':
  print "\n### depositMerrittManifests.py: ###\n"
  depositManifests()
  print "\n### Done! ###\n"
