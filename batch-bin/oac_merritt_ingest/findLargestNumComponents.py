#!/usr/bin/env python

import os

dataDir = '/apps/dsc/data/xtf/data/13030/'
objectFileCounts = {}

# LEVEL 1. dirs like '00', 'd7'
topDirs = os.listdir(dataDir)
for topDir in topDirs:
  if os.path.isdir(os.path.join(dataDir, topDir)):
	# LEVEL 2. dirs like 'kt296nd8zz'
	for objectId in os.listdir(os.path.join(dataDir, topDir)):
	  if os.path.isdir(os.path.join(dataDir, topDir, objectId)):
                objectFileCount = 0 # new object
		# LEVEL 3. 
		for listing in os.listdir(os.path.join(dataDir, topDir, objectId)):
		  if os.path.isdir(os.path.join(dataDir, topDir, objectId, listing)):
			# LEVEL 4.
			for file in os.listdir(os.path.join(dataDir, topDir, objectId, listing)):
                          if file != 'cache_info.storable' \
                          and file != 'CVS' \
                          and not file.endswith(';charset=ISO-8859-1') \
                          and file != objectId + '.checkm': 
                            objectFileCount = objectFileCount + 1
		  else:
                        if listing != 'cache_info.storable' \
                        and listing != 'CVS' \
                        and not listing.endswith(';charset=ISO-8859-1') \
                        and listing != objectId + '.checkm':
                          objectFileCount = objectFileCount + 1
			# get info for any non-local files 
			#specialProfileLines = self.processSpecialProfiles(listing, os.path.join(dataDir, topDir, objectId, listing), objectId)
			#for line in specialProfileLines:
			  #objectManifestInfo.append(line)
			# get info for batch manifest
			#if listing == objectId + self.metadataFileExt:
			  #batchManifestInfo.append(self.getBatchManifestInfo(os.path.join(dataDir, topDir, objectId, listing), listing, self.naan, topDir, objectId))

                #objectFileCounts.append([objectId, objectFileCount])
                objectFileCounts[objectId] = objectFileCount

for n in range(5):
  m = max(objectFileCounts, key=objectFileCounts.get)
  print m, objectFileCounts.get(m)
  del objectFileCounts[m]

