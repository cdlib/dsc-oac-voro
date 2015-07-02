#!/bin/bash
# http://stackoverflow.com/a/26096339/1763984

set -eu

OUTPUT="/apps/dsc/data/atdumps"

flags="-u $USER -p$PASSWORD -h $HOST -P $PORT"


databases=`mysql $flags -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump $flags --databases $db > $OUTPUT/`date +%Y%m%d`.$db.sql
        bzip2 $OUTPUT/`date +%Y%m%d`.$db.sql
    fi
done
