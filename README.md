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
new language features (e.g. `c++11`) and good libraries. So here is `packman`.
It will download all the needed software packages, so you can upload them onto
the server which has no internet connection, and then run

``` $ packman install <config file> ```

to install the packages you need.

The configure file may looks like:
```
package_root = "/opt/packman/packages"
install_root = "/opt/packman"
active_compiler_set = 1
compiler_set_0 = {
  "c" => "gcc",
  "c++" => "g++",
  "fortran" => "gfortran"
}
compiler_set_1 = {
  "installed_by_packman" => "gcc"
}
package_gcc = {
  "compiler_set" => 0
}
package_netcdf_cxx = {
  "compiler_set" => [0,1]
}
```
So you can specify multiple compiler sets (see `compiler_set_0` and
`compiler_set_1`), and build the packages with different compiler sets (see
`[0,1]`). Then you can switch among the sets by setting `active_compiler_set`
and run:
``` $ packman switch <config file> ```

I would like to thank the Homebrew community, since I have referred the design
of it quite a lot.

Features
========

- No root privilege is needed.
- Offline installation suite for big server with no internet connection.
- The packages can be installed anywhere you like.
- All processes are automatically (basicly).

Todo list
=========

- Check if the packages, which are not sensitive to compiler, are already
  installed by system. If yes, use the system one.
- Combine the install prefix of 'netcdf_c', 'netcdf_cxx' and 'netcdf_fortran'.

Author
======

- Li Dong <dongli@lasg.iap.ac.cn>
