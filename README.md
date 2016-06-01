# doedatabox
department of education data task 2016

*installation*
```
Please download and install vagrant
- https://www.vagrantup.com/downloads.html
```

*run the box to get results for parts A and B*
```
$ vagrant up

$ vagrant ssh

vagrant@127.0.0.1's password: vagrant

vagrant@vagrant-ubuntu-trusty-64:~$ ./setup_students

sqlite> .exit

vagrant@vagrant-ubuntu-trusty-64:~$ cat data/studentsLevel.txt

vagrant@vagrant-ubuntu-trusty-64:~$ exit

$ vagrant destroy
```

*results: part A*
```
![part A](/images/partA.png)
```

*results: part B*
![part B](/images/partB.png)

*misc: file processing*
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

*misc: errors*
```
Error: multi-character column separators not allowed for import
https://goo.gl/VuUbLI

Windows CTRL Chars
http://ascii-table.com/control-chars.php

temporary solution
https://danielmiessler.com/study/crlf/
```
