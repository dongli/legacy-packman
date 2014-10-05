Introduction
============

This is a tool written in Ruby to make the installation of packages
automatically and painless. You may say we have already package managers in
different Linux distributions, or even in Mac OS X (see Homebrew), but as a
researcher who needs to run programs on the server will always face the
problems:

- The libraries on the server are too old!
- The compilers are also too old! (GCC 4.1.2, seriously?)
- The server login node is not even connected with the internet!
- The software dependencies are nightmare!

All these problems make porting programs a headache, and we hesitate about using
new language features (e.g. `c++11`) and good libraries, so here is `packman`.
For more usage information, please refer [here](https://github.com/dongli/packman/wiki/Basic-Usages).

I would like to thank the Homebrew community, since I have referred the design
of it quite a lot, but I do not just copycat `homebrew`. If you find `packman` is
helpful, join me to form a great community to further improve it.

Features
========

- No root privilege is needed.
- Offline installation suite for big server with no internet connection.
- Easy FTP mirror setup.
- The packages can be installed anywhere you like.
- All processes are automatically (basicly).

Donation
========

If you find `packman` is useful (I spent hours to create it) and would like to
support the further development of it, consider make a generous donation please:

![](https://gist.githubusercontent.com/dongli/9634592/raw/52aaee8b20222e9757429bce3efc6b8c819037a8/ap4l61nbskhw46qnef.png =32x32)

Author
======

- Li Dong <dongli@lasg.iap.ac.cn>
