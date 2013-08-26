#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys, os, hashlib, re, httplib, urllib, urllib2, collections
from urlparse import urlparse
from xml.etree.ElementTree import parse

# get command line arguments
dataDir = sys.argv[1]
manifestDir = sys.argv[2]
dataUrlRoot = sys.argv[3]
naans = sys.argv[4]
depositObjectIds = sys.argv[5] # single object ID, list of IDs, or 'all' (all objects)

#############################################################################
#############################################################################
class OacManifests:

  def __init__(self, dataDir, manifestDir, dataUrlRoot, naans, depositObjectIds):
    """ Constructor """
    self.dataDir = dataDir 
    self.dataUrlRoot = dataUrlRoot
    self.depositObjectIds = depositObjectIds
    if self.depositObjectIds != 'all':
      self.depositObjectIds = self.depositObjectIds.split(",") 
    self.naans = naans.split(",")
    #self.naan = '13030' # FIXME allow for multiple NAANs
    self.manifestFileExt = '.checkm'
    self.metadataFileExt = '.dc.xml'
    self.batchManifestOutputDir = manifestDir
    # self.batchManifestOutputDir = os.path.join(self.dataDir, 'manifests') # FIXME
    self.objManifestOutputDir = os.path.join(self.batchManifestOutputDir, 'objectManifests')
    self.specialProfiles = []
    self.specialProfiles.append(['eadExtractedImages', 'http://ark.cdlib.org/ark:/13030/kt3q2nb7vz'])
    self.specialProfiles.append(['lstaMarc', 'http://ark.cdlib.org/ark:/13030/kt400011f8'])
    self.specialProfiles.append(['lstaDc', 'http://ark.cdlib.org/ark:/13030/kt4g5012g0'])
    self.overwrite = 1

############################################################################# 
  def writeBatchManifest(self, naan, pair, manifestInfo):
    """ write a batch manifest file to the filesystem """
    if len(manifestInfo) < 1: return

    fullpath = os.path.join(self.batchManifestOutputDir, naan, naan + pair + self.manifestFileExt)

    with open(fullpath, 'w') as f:
      f.write('#%checkm_0.7\n')
      f.write('#%profile | http://uc3.cdlib.org/registry/ingest/manifest/mrt-batch-manifest\n')
      f.write('# utf8, OAC/Calishere ARK local ID, primary ID in Merritt will be different ARK\n')
      f.write('# url ||||| manifest.checkm | | local_ark | creator[1] or contributor[1] | title[1] | date[1]\n')
      for infoLine in manifestInfo:
        if infoLine.strip() != '':
          f.write(infoLine + '\n')
      f.write('#%eof')

############################################################################# 
  def writeObjectManifest(self, objectId, objectDir, manifestInfoDict):
    """ write an object manifest file to the filesystem """
    if len(manifestInfoDict) < 1: return

    manifestInfoDict = self.dedupFilenames(manifestInfoDict)

    fullpath = os.path.join(objectDir, objectId + self.manifestFileExt)
    with open(fullpath, 'w') as f:
      f.write('#%checkm_0.7\n')
      f.write('#%profile | http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n')
      f.write('#%prefix | mrt: | http://merritt.cdlib.org/terms#\n')
      f.write('#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n')
      f.write('#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n')
      for infoLine in manifestInfoDict:
        if len(infoLine):
          f.write(infoLine['fileUrl'] + '|' + infoLine['hashAlgorithm'] + '|' + infoLine['hashValue'] + '|' + infoLine['fileSize'] + '|' + infoLine['fileLastModified'] + '|' + infoLine['fileName'] + '\n')
      f.write('#%eof')

############################################################################# 
  def checkFileUrl(self, fileUrl):
    """ check that URL is valid """
    req = urllib2.Request(fileUrl)
    try:
      res = urllib2.urlopen(req)
      valid = 1
    except urllib2.HTTPError as e:
      print e.code, fileUrl
      valid = 0
    except urllib2.URLError as ue:
      print ue.reason, fileUrl
      valid = 0

    return valid

############################################################################# 
  def createManifests(self):
    """ create batch and object manifests """
    print 'createManifests()'

    for naan in self.naans:
      fullpath = os.path.join(self.dataDir, naan)
      print 'fullpath:', fullpath
      self.createManifestsForNaan(naan, fullpath) 

#############################################################################
  def createManifestsForNaan(self, naan, naanDataDir):
    """ create batch and object manifests for a given NAAN """ 
    # LEVEL 1. dirs like '00', 'd7'
    print 'processing NAAN dir', naanDataDir
    topDirs = os.listdir(naanDataDir)
    if self.depositObjectIds == 'all':
      self.depositObjectIds = topDirs
    for topDir in topDirs:
      validPair = 0
      processBatch = 0
      manifestPath = ''
      # check that the directory name is a valid pair name
      if os.path.isdir(os.path.join(naanDataDir, topDir)) and topDir in self.depositObjectIds and topDir != 'manifests':
        validPair = 1
        processBatch = 1
      # check that the manifest file doesn't already exist
      if validPair and not self.overwrite:
        manifestPath = os.path.join(self.batchManifestOutputDir, naan + topDir + self.manifestFileExt)
        if os.path.isfile(manifestPath):
          processBatch = 0
 
      if processBatch:
        print '  processing', topDir
        batchManifestInfo = [] # new batch
        # LEVEL 2. dirs like 'kt296nd8zz'
        for objectId in os.listdir(os.path.join(naanDataDir, topDir)):
          if os.path.isdir(os.path.join(naanDataDir, topDir, objectId)):
            objectManifestInfo = [] # new object
            # LEVEL 3. 
            for listing in os.listdir(os.path.join(naanDataDir, topDir, objectId)):
              if os.path.isdir(os.path.join(naanDataDir, topDir, objectId, listing)):
                # LEVEL 4.
                for file in os.listdir(os.path.join(naanDataDir, topDir, objectId, listing)):
                  # get info for object manifest
                  objectManifestInfo.append(self.getObjectManifestInfo(naan, os.path.join(topDir, objectId, listing, file), file, topDir, objectId))
              else:
                #get info for object manifest
                objectManifestInfo.append(self.getObjectManifestInfo(naan, os.path.join(topDir, objectId, listing), listing, topDir, objectId))
                # get info for any non-local files 
                specialProfileLines = self.processSpecialProfiles(listing, os.path.join(naanDataDir, topDir, objectId, listing), objectId)
                for line in specialProfileLines:
                  objectManifestInfo.append(line)
                # get info for batch manifest
                if listing == objectId + self.metadataFileExt:
                  batchManifestInfo.append(self.getBatchManifestInfo(os.path.join(naanDataDir, topDir, objectId, listing), listing, naan, topDir, objectId))

            # CREATE OBJECT MANIFEST (e.g. data/13030/1k/kt9h4nb81k/manifest.checkm)
            objectDir = os.path.join(naanDataDir, topDir, objectId)
            self.writeObjectManifest(objectId, objectDir, objectManifestInfo) 

        # CREATE BATCH MANIFEST (e.g.: manifests/130301k.checkm)
        self.writeBatchManifest(naan, topDir, batchManifestInfo)

############################################################################# 
  def dedupFilenames(self, objectInfo):
    """ given a dictionary of info for an object, disambiguate duplicate filenames """
    filenames = []
    duplicates = []

    # get a list of duplicate filenames. 
    # I can't get Counter from collections to import, otherwise I'd use it here
    for info in objectInfo:
      if len(info):
        if info['fileName'] in filenames and not info['fileName'] in duplicates:
          duplicates.append(info['fileName'])
        filenames.append(info['fileName'])

    # dedup filenames by prepending with part of path
    # doing this crudely for now...
    for info in objectInfo:
      if len(info):
        if info['fileName'] in duplicates:
          urlParts = info['fileUrl'].split('/')
          newFilename = os.path.join(urlParts[-3], urlParts[-2], info['fileName'])
          info['fileName'] = newFilename

    return objectInfo

############################################################################# 
  def encodeUrl(self, url):
    """ urlencode path part of URL """
    parsedUrl = urlparse(url)
    urlPath = parsedUrl.path 
    quotedPath = urllib.quote(urlPath)
    return url.replace(urlPath, quotedPath)

############################################################################# 
  def getBatchManifestInfo(self, fullpath, metadataFilename, naan, pair, objectId):
    """ given an object's metadata file, get info for object manifest """
    delimiter = '|'
    metadata = []

    fileUrl = os.path.join(self.dataUrlRoot, naan, pair, objectId, objectId + self.manifestFileExt)
    fileUrl = self.encodeUrl(fileUrl)
    hashAlgorithm = ''
    hashValue = '' 
    fileSize = '' 
    fileLastModified = ''
    fileName = objectId + self.manifestFileExt
    mimeType = ''
    localID = 'ark:/' + naan + '/' + objectId
    (creator, title, date) = self.getObjectMetadata(fullpath)

    metadata.append(fileUrl)
    metadata.append(hashAlgorithm)
    metadata.append(hashValue)
    metadata.append(fileSize)
    metadata.append(fileLastModified)
    metadata.append(fileName)
    metadata.append(mimeType)
    metadata.append(localID)
    metadata.append(creator)
    metadata.append(title)
    metadata.append(date)

    return delimiter.join(metadata)

############################################################################# 
  def getObjectManifestInfo(self, naan, partPath, filename, pair, objectId):
    """ for given file, create line for object manifest """
    delimiter = '|'
    metadata = {}

    if filename != 'cache_info.storable' \
    and filename != 'CVS' \
    and not filename.endswith(';charset=ISO-8859-1') \
    and filename != objectId + self.manifestFileExt:
      fullpath = os.path.join(self.dataDir, naan, partPath)
      fileUrl = os.path.join(self.dataUrlRoot, naan, partPath)
      if self.checkFileUrl(fileUrl):
        fileUrl = self.encodeUrl(fileUrl)
        hashAlgorithm = 'MD5' 
        hashValue = self.md5Checksum(fullpath)
        fileSize = str(os.path.getsize(fullpath))
        fileLastModified = ''
        fileName = filename

        metadata = {'fileUrl': fileUrl, 'hashAlgorithm': hashAlgorithm, 'hashValue': hashValue, 'fileSize': fileSize, 'fileLastModified': fileLastModified, 'fileName': fileName}
      #else:
        #print 'invalid url for', objectId
        #print 'fileUrl:', fileUrl
        #print '\n'
 
    return metadata # we are now returning a dict
    #return delimiter.join(metadata) 

############################################################################# 
  def getObjectManifestInfoSpecial(self, fileurl, objectId):
    """ given info for a file that's part of an object with a special profile, create line for object manifest """
    delimiter = '|'
    metadata = {} 

    fileUrl = fileurl
    if self.checkFileUrl(fileurl):
      fileUrl = self.encodeUrl(fileUrl) 
      hashAlgorithm = ''
      hashValue = ''
      fileSize = ''
      fileLastModified = ''
      fileName = os.path.basename(fileUrl)

      metadata = {'fileUrl': fileUrl, 'hashAlgorithm': hashAlgorithm, 'hashValue': hashValue, 'fileSize': fileSize, 'fileLastModified': fileLastModified, 'fileName': fileName}
    #else:
      #print 'invalid url for', objectId
      #print 'fileUrl:', fileUrl
      #print '\n'

    return metadata
    #return delimiter.join(metadata)

############################################################################# 
  def getObjectMetadata(self, fullpath):
    """ get metadata values from given dc.xml file """
    tree = parse(fullpath)
    title = self.getFirstElement(fullpath, tree, 'title')
    date = self.getFirstElement(fullpath, tree, 'date') 
    creator = self.getFirstElement(fullpath, tree, 'creator') 
    contributor = self.getFirstElement(fullpath, tree, 'contributor')
    creatorOrContributor = creator or contributor
    return (creatorOrContributor, title, date) 

############################################################################# 
  def getFirstElement(self, fullpath, xmltree, elementName):
    """ get text value of first element of given name from xmltree """
    textvalue = ''
    elements = xmltree.findall(elementName) # must be better way to just get 1st
    if len(elements) > 0:
      textvalue = unicode(elements[0].text).encode('utf-8')

    textvalue = " ".join(textvalue.split()) # get rid of extraneous whitespace chars

    # replace any pipes (|) with broken pipes
    if "|" in textvalue:
      print 'before:', textvalue
      encodedBrokenPipe = u'¦'.encode('utf8')
      textvalue = textvalue.replace("|", encodedBrokenPipe)
      print "NOTICE: Replaced pipe in file", fullpath
      print 'after:', textvalue 
    return textvalue 

############################################################################# 
  def getSpecialFileInfo(self, filename, filepath, profile):
    """ get file info for object with special profile """

    fileInfo = []
    xmlns = '{http://www.loc.gov/METS/}'
    xlink = ['{http://www.w3.org/1999/xlink}', '{http://www.w3.org/TR/xlink}']

    xmltree = parse(filepath)
    root = xmltree.getroot()
    for element in root.findall(xmlns + "fileSec/" + xmlns + "fileGrp/" + xmlns + "file/" + xmlns + "FLocat"):
      # this is horrible -- there must be a better way to deal with multiple namespaces
      href = element.get(xlink[0] + 'href', 0) or element.get(xlink[1] + 'href', 0)
      role = element.get(xlink[0] + 'role', 0) or element.get(xlink[1] + 'role', 0)

      # capture info for all non-archival files
      if role != 'archival':
        if role and href:
          fileInfo.append([href, role])           
        else:
          print '**ERROR: href or role missing**'
          print 'href: ', href
          print 'role: ', role

    return fileInfo

############################################################################# 
  def md5Checksum(self, filepath):
    """ get md5 checksum for a given file """
    # http://www.joelverhagen.com/blog/2011/02/md5-hash-of-file-in-python/
    f = open(filepath, 'rb') # open for reading in binary mode
    m = hashlib.md5()
    while True:
      data = f.read(8192) # file is read in 8192 byte chunks to minimize memory use to ~8k
      if not data:
        break
      m.update(data)
    return m.hexdigest()

############################################################################# 
  def processSpecialProfiles(self, filename, filepath, objectId):
    """ create manifest for object with special mets profile """
    manifestLines = []
    if filename.endswith('.mets.xml'):
      # read in the file and look for special profile
      with open(filepath, 'r') as f:
        filestring = f.read()

      for specialProfile in self.specialProfiles:
        profileName = specialProfile[0]
        searchString = specialProfile[1]
        if re.search(searchString, filestring):
          # special profile found. get file info.
          specialFileInfo = self.getSpecialFileInfo(filename, filepath, profileName) 

          # for each file, create line of info for object manifest
          for info in specialFileInfo:
            manifestLines.append(self.getObjectManifestInfoSpecial(info[0], objectId))
    return manifestLines

#############################################################################
def createManifests(dataDir, manifestDir, dataUrlRoot, naans, depositObjectIds):
  manifests = OacManifests(dataDir, manifestDir, dataUrlRoot, naans, depositObjectIds)
  manifests.createManifests()

#############################################################################
if __name__ == '__main__':
  print "\n### merrittManifests.py: ###\n"
  createManifests(dataDir, manifestDir, dataUrlRoot, naans, depositObjectIds)
  print "\n### Done! ###\n"
