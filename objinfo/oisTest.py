import os, sys
import datetime
import oisIndexer

FILE_PATH = os.path.abspath(os.path.split(__file__)[0])
oisIndexer.DIR_ROOT = os.path.join(FILE_PATH, 'test/xmldata')
oisIndexer.DB_FILE = os.path.join(FILE_PATH, 'test/ois-test.sqlite3')

if __name__=="__main__":
    time_start = datetime.datetime.now()
    print "OIS Indexer PID: %d started at: %s " % (os.getpid(), time_start,)
    sys.stdout.flush()
    oisIndexer.process_findingaids()
    #oisIndexer.process_orphans()
    time_finish = datetime.datetime.now()
    time_delta = time_finish - time_start
    print "OIS Finished indexing digital objects"
    print "Started:%s Finished:%s Elapsed:%s" % (time_start, time_finish, time_delta)
