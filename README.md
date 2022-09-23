# snappurge
simple bash script thats deletes zfs snapshots older than a custom amount of days.

this script was written to purge snapshots with the date schema "2022-09-20" (%Y-%m-%d) after X days


## config
edit following vars at the start of the script

timespan=60
timespan in days to keep snapshots

dataset="pool/dataset"
dataset that will be processed recursively

snapshotname="autosnap_.*_daily"
regex of the snapshot name that should be processed
