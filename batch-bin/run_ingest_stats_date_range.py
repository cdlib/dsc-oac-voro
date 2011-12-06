
'''Run the voro_ingest_stats.pl components in a historical date range. Need to call the find_new_and_updated.pl and summarize_new_and_updated.pl directly in order to pass in the date

'''
import  datetime
from datetime import timedelta
import shlex, subprocess

import plac

@plac.annotations(
        start_date="Start date for run : YYYYMMDD",
        end_date="End date for run : YYYYMMDD"
)
def main(start_date, end_date):
    '''Run the ingest stats for the given date range
    '''
    start_date = datetime.datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.datetime.strptime(end_date, '%Y%m%d')
    print "START: %s END: %s" % (start_date, end_date)
    for workdate in (start_date + timedelta(n) for n in range((end_date - start_date).days)):
        print "WORKDATE:", workdate 
        # run the find_new_and_updated will i need to sort -u ???
        file_prefix = '/dsc/data/ingest-stats/data/object_list.'
        previous_day_list = file_prefix + (workdate - timedelta(1)).strftime('%Y%m%d') + '.txt'
        current_day_list = file_prefix + (workdate).strftime('%Y%m%d') + '.txt'
        command_line = '/dsc/branches/production/voro/batch-bin/find_new_and_updated.pl %s %s' % (previous_day_list, current_day_list)
        args = shlex.split(command_line)
        print args
        p = subprocess.Popen(args)
        p.wait()
        print "++++++++ FINISHED ", args

if __name__=='__main__':
    plac.call(main)
