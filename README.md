# doedatabox
department of education data task 2016 0525 - 0528

*installation*
```
$ sudo apt-get install sqlite3
$ sudo apt-get install file
$ sudo apt-get install tofrodos
$ sudo apt-get install dos2unix
$ sudo apt-get install column

$ sqlite3 --version
3.9.2 2015-11-02 18:31:45 bda77dda9697c463c3d0704014d51627fceee328
```


*file processing*
```
$ file scores.txt schools.txt Demographics.txt
scores.txt:       ASCII text, with CRLF line terminators
schools.txt:      ASCII text, with CRLF line terminators
Demographics.txt: ASCII text, with CRLF line  terminators

$ dos2unix scores.txt schools.txt Demographics.txt
dos2unix: converting file scores.txt to Unix format ...
dos2unix: converting file schools.txt to Unix format ...
dos2unix: converting file Demographics.txt to Unix format ...

$ file scores.txt schools.txt Demographics.txt
scores.txt:       ASCII text
schools.txt:      ASCII text
Demographics.txt: ASCII text
```

*usage*
```
Use ".open FILENAME" to reopen on a persistent database.
```

*errors*
```
Error: multi-character column separators not allowed for import
https://goo.gl/VuUbLI

Windows CTRL Chars
http://ascii-table.com/control-chars.php

temporary solution
https://danielmiessler.com/study/crlf/
```

*data preparation*
```
$ sqlite3 students.db

```
