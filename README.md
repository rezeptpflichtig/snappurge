# snappurge
simple bash script thats deletes zfs snapshots older than a custom amount of days.

this script was written to purge snapshots with the date schema "2022-09-20" (%Y-%m-%d) after X days

## config
edit following vars at the start of the script

### timespan
`timespan=60`
timespan in days to keep snapshots

### dataset
`dataset="pool/dataset"`
dataset that will be processed recursively

### snapshotname
`snapshotname="autosnap_.*_daily"`
regex of the snapshot name that should be processed

## dry-run default
the final `zfs destroy` command at the end of the script is commented out to just give you a 'dry run' output. just uncomment if you are happy with the output.
