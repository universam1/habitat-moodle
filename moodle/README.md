# Moodle #

## Building Habitat packages for Moodle ##

Let's assume:
* a working habitat studio
* default origin is set to 'my'
* command are executed from working directory: `/src/` inside the studio

### Build the package ###

* Build the required packages

```shell
build moodle-php5
build moodle-nginx-proxy
build moodle
```

### Start Moodle using the Supervisor ###

* Create a toml file to properly configure core/mysql

```shell
cat<<EOF > /src/mysql_moodle.toml
app_username = 'moodleroot'
app_password = 'S3cret'
root_password = 'SuperS3cret'
EOF
```

* Stop (just to be sure) and start the supervisor and apply the configuration

```shell
sup-term
sup-run
hab config apply mysql.default $(date +%s) mysql_moodle.toml
```

* Start core/mysql (optionally, test the connection)

```shell
hab start core/mysql
hab pkg exec core/mysql-client mysql -umoodleroot -pS3cret -h127.0.0.1
# debug tip: have a look at /hab/svc/mysql/config/init.sql to see if users are set up correctly
```

* Start nginx (optionally test if the web server is listening)

```shell
hab start my/moodle-nginx-proxy
hab pkg exec core/curl curl 127.0.0.1
# should give output: 502 Bad Gateway
```

* Start moodle (and watch it fail...)

```shell
hab start my/moodle --bind database:mysql.default
sl # alias to see the Supervisor Log; Ctrl + C to exit it
```

### Quickly do a clean restart (after rebuilding a package for example) ###

```shell
sup-term # stop supervisor
rm -rf /hab/svc/{moodle,moodle-nginx-proxy,mysql} # remove all files of previously started services (will be recreated)
sup-run # start the supervisor
hab config apply mysql.default $(date +%s) mysql_moodle.toml # apply the mysql configuration
hab start core/mysql # start mysql
hab start my/moodle-nginx-proxy # start the nginx proxy
hab start my/moodle --bind database:mysql.default # start php-fpm for moodle
sup-log # see the output
```

# Obsolete (solved)

### Debugging php ###

* Enable making of coredumps (commands executed inside the studio)

```shell
# create directory to put in the coredumps
mkdir /tmp/coredumps
# tell the kernel where to store them
echo "/tmp/coredumps/core-%e.%p">/proc/sys/kernel/core_pattern
# completely disable gdb security protection by adding / to safe-path (we are inside a jail right?)
echo "set auto-load safe-path /" > /root/.gbdinit
# install GNU Debugger
hab pkg install core/gdb
```

* Rebuild my/moodle-php and my/moodle with debug option enabled

```shell
# adjust files inside my directory to enable the debug option
sed 's/no-debug/debug/g' -i my/moodle/config/php.ini
sed 's/configure --prefix="$pkg_prefix"/configure --prefix="$pkg_prefix" --enable-debug/g' -i my/moodle-php/plan.sh

# rebuild plans
build my/moodle-php
build my/moodle
```

* Trigger Segmentation fault by re-running the supervisor with the rebuild packages

```shell
cd /src
sup-term
rm -rf /hab/svc/{moodle,moodle-nginx-proxy,mysql}
sup-run
hab config apply mysql.default $(date +%s) mysql_moodle.toml
hab start core/mysql
hab start my/moodle --bind database:mysql.default
hab pkg exec core/gdb gdb $(hab pkg path my/moodle-php)/bin/php /tmp/coredumps/core-php.<pid>
# inside gdb type 'bt' to see the back trace and 'quit' to exit the program
```

* Mannually again trigger the php command that segfaults (does the same as the command executed in `/hav/svc/moodle/hooks/init`)

Note: this only works if mysql is still running and my/moodle has run once so that the php files and configuration is deployed in `/hab/svc/moodle/static/moodle`.

```shell
hab pkg exec core/mysql-client mysql -umoodleroot -pS3cret -h127.0.0.1 -e 'DROP DATABASE moodle;'
hab pkg exec core/mysql-client mysql -umoodleroot -pS3cret -h127.0.0.1 -e 'CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
hab pkg exec my/moodle-php php -c /hab/svc/moodle/config /hab/svc/moodle/static/moodle/admin/cli/install_database.php --adminuser=admin --adminpass=S3cret --adminemail=admin@example.com --agree-license
pkg exec core/gdb gdb $(hab pkg path my/moodle-php)/bin/php /tmp/coredumps/core-php.<pid>
```

## Summary of things tried to solve the segmentation fault issue ##

Things already tested:
* core/php doesn't work, missing support for zip
* core/php5 doesn't work, missing support for mysql
* my/moodle-php is copied from core/php with some adjustments (take a look at plan.sh) -> but it fails (segfault)

```shell
# Cause php to segfault
[default:/src:0]# hab pkg exec my/moodle-php php -c /hab/svc/moodle/config /hab/svc/moodle/static/moodle/admin/cli/install_database.php --adminuser=admin --adminpass=S3cret --adminemail=admin@example.com --agree-license
-------------------------------------------------------------------------------
== Setting up database ==
-->System
^[zend_mm_heap corrupted
Segmentation fault (core dumped)

# Run the debugger
[default:/src:0]# hab pkg exec core/gdb gdb $(hab pkg path my/moodle-php)/bin/php /tmp/coredumps/core-php.18304
GNU gdb (The Habitat Maintainers 7.12/20170514010131) 7.12
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /hab/pkgs/my/moodle-php/7.1.4/20170607143704/bin/php...(no debugging symbols found)...done.
[New LWP 18304]

warning: Unable to find libthread_db matching inferior's thread library, thread debugging will not be available.

warning: Unable to find libthread_db matching inferior's thread library, thread debugging will not be available.
Core was generated by `/hab/pkgs/my/moodle-php/7.1.4/20170607143704/bin/php -c /hab/svc/moodle/config'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x00007fb9882bd6c7 in kill () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
(gdb) bt
#0  0x00007fb9882bd6c7 in kill () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#1  0x00000000009a30d3 in ?? ()
#2  0x00000000009a4ee3 in ?? ()
#3  0x00000000009a76d1 in _efree ()
#4  0x00000000006be1bd in ?? ()
#5  0x00000000006c2262 in ?? ()
#6  0x0000000000a3d7a9 in ?? ()
#7  0x0000000000a3cec9 in execute_ex ()
#8  0x0000000000a3cfda in zend_execute ()
#9  0x00000000009de2fa in zend_execute_scripts ()
#10 0x000000000094ca5b in php_execute_script ()
#11 0x0000000000abe742 in ?? ()
#12 0x0000000000abf712 in ?? ()
#13 0x00007fb9882aa5e0 in __libc_start_main () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#14 0x0000000000432409 in _start ()
(gdb)
```

* tested php 7.0 and 7.1 with moodle outside of habitat (on Archlinux and Ubuntu 16.04) -> works

```shell
# on Archlinux with php 7.1.5-1
php admin/cli/install_database.php --adminpass=S3cret --adminemail=admin@example.com --agree-license
-------------------------------------------------------------------------------
== Setting up database ==
-->System
...
-->logstore_standard
++ Success ++
Installation completed successfully.
```

* tried disabling opcache for my/moodle-php -> still segfaults
* tried to start with `USE_ZEND_ALLOC=0`

```shell
# Cause php to segfault
[default:/src:0]# USE_ZEND_ALLOC=0 hab pkg exec my/moodle-php php -c /hab/svc/moodle/config /hab/svc/moodle/static/moodle/admin/cli/install_database.php --adminuser=admin --adminpass=S3cret --adminemail=admin@example.com --agree-license
-------------------------------------------------------------------------------
== Setting up database ==
-->System
*** Error in `/hab/pkgs/my/moodle-php/7.1.4/20170607143704/bin/php': free(): invalid pointer: 0x00007f635bab0a50 ***
Aborted (core dumped)

# Run the debugger
[default:/src:0]# hab pkg exec core/gdb gdb $(hab pkg path my/moodle-php)/bin/php /tmp/coredumps/core-php.16806
GNU gdb (The Habitat Maintainers 7.12/20170514010131) 7.12
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /hab/pkgs/my/moodle-php/7.1.4/20170607143704/bin/php...(no debugging symbols found)...done.
[New LWP 16806]

warning: Unable to find libthread_db matching inferior's thread library, thread debugging will not be available.

warning: Unable to find libthread_db matching inferior's thread library, thread debugging will not be available.
Core was generated by `/hab/pkgs/my/moodle-php/7.1.4/20170607143704/bin/php -c /hab/svc/moodle/config'.
Program terminated with signal SIGABRT, Aborted.
#0  0x00007f635949a388 in raise () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
(gdb) bt
#0  0x00007f635949a388 in raise () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#1  0x00007f635949b80a in abort () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#2  0x00007f63594d8e0a in ?? () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#3  0x00007f63594de756 in ?? () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#4  0x00007f63594def3e in ?? () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#5  0x00000000009a76a7 in _efree ()
#6  0x00000000006be1bd in ?? ()
#7  0x00000000006c2262 in ?? ()
#8  0x0000000000a3d7a9 in ?? ()
#9  0x0000000000a3cec9 in execute_ex ()
#10 0x0000000000a3cfda in zend_execute ()
#11 0x00000000009de2fa in zend_execute_scripts ()
#12 0x000000000094ca5b in php_execute_script ()
#13 0x0000000000abe742 in ?? ()
#14 0x0000000000abf712 in ?? ()
#15 0x00007f63594875e0 in __libc_start_main () from /hab/pkgs/core/glibc/2.22/20170513201042/lib/libc.so.6
#16 0x0000000000432409 in _start ()
(gdb)
```

Next steps to debug this issue:

* Re-build core/php5 with mysql (and zip) support and test if it also gives a segfault
* Dive into the package build source for php 7.x on Archlinux and Ubuntu 16.04 and use that to rebuild my/moodle-php

**Solution was to move the PHP5**
