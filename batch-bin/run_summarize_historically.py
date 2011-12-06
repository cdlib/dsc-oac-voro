#! /usr/bin/env python
'''Run the summarize_new_and_updated.pl from 2011-02-04 forward by weeks to
Dec 1 2011
using python because of good date incrementing
'''
import datetime
import subprocess
import shlex

import plac

tdelta = datetime.timedelta(7)

@plac.annotations(
    start_date="Start date for summarizing ingest stats - YYYYMMDD",
    end_date="End date for summarizing ingest stats, defaults to today - YYYYMMDD"
    )
def main(start_date, end_date):
    print start_date, end_date
    start_date = datetime.datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.datetime.strptime(end_date, '%Y%m%d')
    while start_date < end_date:
        command_line = '/dsc/branches/production/voro/batch-bin/summarize_new_and_updated.pl /dsc/data/ingest-stats/data/ingest_stats.txt %s' % ( start_date.strftime('%Y/%m/%d'), )
        print command_line
        args = shlex.split(command_line)
        p = subprocess.Popen(args)
        p.wait()
        print "++++++++ FINISHED ", command_line
        start_date = start_date+tdelta

if __name__=='__main__':
    plac.call(main)
