#!/usr/bin/env bash
set -e
set -u 
mkdir -p $HOME/indexes/sqlite3
if [ -e $HOME/indexes/sqlite3/ois.sqlite3 ]; then
  sqlite3 $HOME/indexes/sqlite3/ois.sqlite3 <<EOF
ALTER TABLE "item" ADD COLUMN "google_analytics_tracking_code" varchar(64);
ALTER TABLE "digitalobject" ADD COLUMN "google_analytics_tracking_code" varchar(64);
EOF
fi

