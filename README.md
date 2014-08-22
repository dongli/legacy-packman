Introduction
============

This is a tool written in Ruby to make the installation of packages
automatically. You may say we have already package managers in different Linux
distributions, or even Mac OS X (see Homebrew), but as a researcher who needs
to run programs on the server will always face the problems:

- The libraries on the server are toooo old!
- The compilers are also toooo old!
- The server login node is not even connected with the internet!
- The software dependencies are nightmare!

All these problems make porting programs a headache. So here is `packman`. It
will download all the needed software packages, so you can upload them onto the
server which has no internet connection, and then run

``` $ packman install <config file> ```

to install the packages you need.

I would like to thank the Homebrew community, since I have referred the design
of it quite a lot.

Features
========

- Offline installation suite for big server with no internet connection.
- The packages can be installed anywhere you like.
- All processes are automatically (basicly).

Author
======

- Li Dong <dongli@lasg.iap.ac.cn>
