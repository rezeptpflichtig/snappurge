#!/bin/bash

#######################
# this script was written to purge snapshots with the date schema "2022-09-20" (%Y-%m-%d) after X days
# edit below to fit your needs
# do a testrun and if you are happy with result uncomment the 'zfs destroy' command at the end of the script to really destroy the listed snapshots.

# timespan in days to keep snapshots
timespan=60

# dataset that will be processed recursively
dataset="pool/dataset"

# regex of the snapshots that should be processed
snapshotname="autosnap_.*_daily"

#######################

echo "there will be snapshots kept for the last $timespan days"
today=`date "+%Y-%m-%d"`
duedate=`date -v-${timespan}d "+%Y-%m-%d"`
year1=`date "+%Y"`
year2=`date -v-${timespan}d "+%Y"`
month1=`date "+%m"`
month2=`date -v-${timespan}d "+%m"`
day1=`date "+%d"`
day2=`date -v-${timespan}d "+%d"`
echo "Today: $today"
echo "shapshots before $duedate will be purged"


function daycalc {
  spanning=""
  #echo "daycalc called with $1 $2 $3"
  for (( n=10#$1; n<=10#$2; n++ )); do
    # start and end same month
    #echo "daycalc loop n:$n"
    if [[ 10#$n -eq 10#$month2 && 10#$n -eq 10#$month1 ]]; then
      #echo "$n is start and end"
      x=$(printf "%02d" $n)
      regex+="($x-("
      for (( u=10#$day2; u<=10#$day1; u++ )); do
       x=$(printf "%02d" $u)
        regex+="$x|"
      done
      regex=${regex::-1}
      regex+=")))"
    # start month
    elif [ $n -eq $1 ] && [ "$3" != "last" ]; then
      #echo "$n is startmonth"
      x=$(printf "%02d" $n)
      regex+="($x-("
      for (( u=10#$day2; u<=31; u++ )); do
        x=$(printf "%02d" $u)
        regex+="$x|"
      done
      regex=${regex::-1}
      regex+="))"
    # end month
    elif [ $n -eq $2 ] && [ "$3" != "first" ]; then
      #echo "$n is endmonth"
      #echo "$3"
      if [ "$3" = "nospan" ]; then
        regex+="|"
      fi
      x=$(printf "%02d" $n)
      regex+="($x-("
      for (( u=01; u<=10#$day1; u++ )); do
        x=$(printf "%02d" $u)
        regex+="$x|"
      done
      regex=${regex::-1}
      regex+=")))"
    # spanning month
    else
      #echo "$n is spanning"
      x=$(printf "%02d" $n)
      spanning+="$x|"
      if [ $n -eq $((10#$2 - 1)) ] && [ "$3" = "last" ]; then
        regex+="(("
        regex+=$spanning
        regex=${regex::-1}
        regex+=")-([0-3][0-9]))|"
      elif [ $n -eq $((10#$2 - 1)) ] && [ "$3" = "nospan" ]; then
        regex+="|(("
        regex+=$spanning
        regex=${regex::-1}
        regex+=")-([0-3][0-9]))"
      elif [ $n -eq $2 ]; then
        regex+="|(("
        regex+=$spanning
        regex=${regex::-1}
        regex+=")-([0-3][0-9]))"
      fi
    fi
  done
  regex+=")"
}

regex=""

for (( i=$year2; i<=$year1; i++ )); do
  if [[ $i -eq $year1 && $i -eq $year2 ]]; then
  # start and endyear is the same
  #echo "start and endyear is the same"
    regex+="(${i}-("
    daycalc $month2 $month1 nospan
    regex+=""
  elif [ $i -eq $year1 ]; then
  # end year
    regex+="|(${i}-("
    daycalc 1 $month1 last
    regex+=")"
  elif [ $i -eq $year2 ]; then
  # start year
    regex+="((${i}-("
    daycalc $month2 12 first
    regex+=")"
  else
  # spanning year
    regex+="|(${i}-(([0-1][0-9])-([0-3][0-9])))|"
  fi
done

echo "calculated regex to match snapshots: $regex"


for snapshot in `zfs list -H -r -t snapshot -o name  $dataset | grep -e "$snapshotname" | grep -v -E "$regex"`; do
  echo "destroying snapshot: $snapshot"
  #zfs destroy $snapshot
done
