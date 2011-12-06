#! /usr/bin/env python

''' Use 2 object list files to figure out which objects are new or updated.

Put both files into dicts, for newer one any new keys are "new".
For matching keys need to compare various values
'''
import os
import sys
import csv
import datetime

import plac

filename_older = '/dsc/data/ingest-stats/data/object_list.20111123.txt'
filename_newer = '/dsc/data/ingest-stats/data/object_list.20111128.txt'

ingest_stats_filename = '/dsc/data/ingest-stats/data/ingest_stats.txt'

def read_object_file(filename):
    stats = {}
    with open(filename) as foo:
        reader = csv.reader(foo, delimiter=' ')
        for row in reader:
            DIR,TYPE,FILE,SIZE,MTIME,CTIME,MD5SUM,TYPESPECIFIC = row
            stats[DIR+'/'+FILE] = (DIR,TYPE,FILE,SIZE,MTIME,CTIME,MD5SUM,TYPESPECIFIC)
    return stats

def update_ingest_stats(stats_previous, stats_current):
    with open(ingest_stats_filename, 'a') as outfile:
        for (key, (DIR,TYPE,FILE,SIZE,MTIME,CTIME,MD5SUM,TYPESPECIFIC)) in stats_current.items():
            stats_old = stats_previous.get(key, None)
            if not stats_old:
                print "%s/%s is a new file" % ( DIR, FILE) #value[0], value[2] )
                outfile.write('%s %s %s new %s "%s"\n' % (DIR, TYPE, FILE, MTIME, TYPESPECIFIC))
            else:
                #compare the file stats
                if TYPE != stats_old[1]:
                    print "%s/%s is a new file" % ( DIR, FILE) #value[0], value[2] )
                    outfile.write('%s %s %s new %s "%s"\n' % (DIR, TYPE, FILE, MTIME, TYPESPECIFIC))
                if MD5SUM != stats_old[6]:
                    print "%s/%s is an updated file" % ( DIR, FILE) #value[0], value[2] )
                    outfile.write('%s %s %s updated %s "%s"\n' % (DIR, TYPE, FILE, MTIME, TYPESPECIFIC))
                #only if md5sum changed is it update
                # need to write info the the ingest_stats.txt file
        #		DIR TYPE FILE [new|updated] MTIME "TYPE-SPECIFIC"

def find_object_file_for_date(date_start, date_end):
    '''Find the first object list file that has this date or the next newer file date
    return "date" of file and filename
    '''
    filename_template='/dsc/data/ingest-stats/data/object_list.%s.txt'
    filename_for_run = filename_template % (date_start.strftime('%Y%m%d'))
    while (not os.path.isfile(filename_for_run)):
        date_start = date_start + datetime.timedelta(1)
        if date_start > date_end:
            sys.exit()
        filename_for_run = filename_template % (date_start.strftime('%Y%m%d'))
    return date_start, filename_for_run

def update_stats_for_date(start_date, end_date):
    date_previous_run, filename_previous_run = find_object_file_for_date(start_date, end_date)
    date_current_run, filename_current_run = find_object_file_for_date(date_previous_run + datetime.timedelta(1), end_date)
    if date_current_run >= end_date:
        sys.exit()
    print "++++++++ PREVIOUS: %s CUR: %s" % (date_previous_run, date_current_run)
    stats_previous = read_object_file(filename_previous_run)
    stats_current = read_object_file(filename_current_run)
    update_ingest_stats(stats_previous, stats_current)
    return date_current_run
    
@plac.annotations(
    start_date="Start date for compiling ingest stats - YYYYMMDD",
    end_date="End date for compiliing ingest stats, defaults to today - YYYYMMDD"
    )
def main(start_date, end_date=datetime.date.today().strftime("%Y%m%d")):
    #if found, inc date for next file, find next file
    # once 2 "adjacent" files are found, compare and update stats filemain
    date_current_run = datetime.datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.datetime.strptime(end_date, '%Y%m%d')
    while (date_current_run < end_date):
        date_current_run = update_stats_for_date(date_current_run, end_date)


if __name__=='__main__':
    plac.call(main)

