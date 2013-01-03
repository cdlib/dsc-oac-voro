#!/usr/bin/env python

import sys, os, time, shlex, subprocess

# get command line arguments
merrittMachine = sys.argv[1]
merrittUser = sys.argv[2]
merrittPass = sys.argv[3]

#############################################################################
#############################################################################
class OacMerrittDeposit:

  def __init__(self, merrittMachine, merrittUser, merrittPass):
    """ constructor """
    self.merrittUser = merrittUser 
    self.merrittPass = merrittPass 
    self.merrittMachine = merrittMachine # stg or prod
    self.manifestDir = '/apps/dsc/data/xtf/data/13030/manifests'
    if self.merrittMachine == 'prod':
      self.merrittUrl = 'https://merritt.cdlib.org/object/ingest'
    else:
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
    + '-u ' + self.merrittUser + ':' + self.merrittPass + ' ' \
    + '-k ' \
    + '-F "file=@' + filename + '" ' \
    + '-F "type=batch-manifest" ' \
    + '-F "profile=cdl_oac_content" ' \
    + self.merrittUrl
    print "apiCmd", apiCmd
    args = shlex.split(apiCmd)
    #p = subprocess.Popen(args, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    #return_code = p.wait()
    #print "return_code:", return_code
    #print "stdout:"
    #for line in p.stdout:
     # print(line.rstrip())
    #print "stderr:"
    #for line in p.stdout:
      #print("stderr: " + line.rstrip())

#############################################################################
def depositManifests(merrittMachine, merrittUser, merrittPass):
  deposit = OacMerrittDeposit(merrittMachine, merrittUser, merrittPass)
  deposit.depositManifests()

#############################################################################
if __name__ == '__main__':
  print "\n### depositMerrittManifests.py: ###\n"
  depositManifests(merrittMachine, merrittUser, merrittPass)
  print "\n### Done! ###\n"
