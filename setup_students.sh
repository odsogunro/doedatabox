#! /usr/bin/env bash

# file processing
file data/scores.txt data/schools.txt data/Demographics.txt 
dos2unix data/scores.txt data/schools.txt data/Demographics.txt

# using column command to resolve ^I tabs for sqlite3 load
## typed ...-t -s"Ctrl+V Ctrl+I"...
column -n -t -s"  " data/scores.txt > data/scoresClean.txt
column -n -t -s"  " data/schools.txt > data/schoolsClean.txt
column -n -t -s"  " data/Demographics.txt > data/demographicsClean.txt

#cat -A data/scores.txt data/schools.txt data/Demographics.txt > /dev/null 2>&1

# run program
sqlite3 students.db -init createStudentsTable.sql 

# delete database: system cleanup
rm students.db
