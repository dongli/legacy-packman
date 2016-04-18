#!/usr/bin/fish

set -x PACKMAN_ROOT (cd (dirname (status -f)); and pwd)
set -x PATH $PACKMAN_ROOT $PATH

function __fish_packman_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'packman' ]
    return 0
  end
  return 1
end

function __fish_packman_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

function __fish_packman_get_packages
  for file in (ls "$PACKMAN_ROOT/packages")
    basename "$file" .rb
  end
end

set -l subcommands_line (awk '/PermittedSubcommands = {/ { start = 1 };
    { if (start == 1 && match($1, ":")) { print $0 } };
    /}.freeze/ { exit }' "$PACKMAN_ROOT/framework/command_line.rb")

for line in $subcommands_line
  set -l subcommand (echo $line|sed 's/^\s*:\(\S*\)\s*=>.*$/\1/')
  set -l subcommand_description (echo $line|sed 's/^.*=>\s*\'\(.*\)\'.*$/\1/')
  complete -f -c packman -n '__fish_packman_needs_command' -a "$subcommand" -d "$subcommand_description"
  set -l subcommand_opts (awk -v subcommand=$subcommand '
        /PermittedOptions = {/ { start = 2 };
        { if (start == 2 && match($1, subcommand)) start = 3 };
        { if (start == 3 && match($1, "-")) { print $0 } };
        /}/ { if (start == 3) exit }' "$PACKMAN_ROOT/framework/command_line.rb")
  for optline in $subcommand_opts
    set -l opt (echo $optline|sed 's/^\s*\'-\(.*\)\'\s*=>.*$/\1/')
    set -l opt_description (echo $optline|sed 's/^.*=>\s*\'\(.*\)\'.*$/\1/')
    complete -f -c packman -n "__fish_packman_using_command $subcommand" -o "$opt" -d "$opt_description"
  end
  switch $subcommand
    case collect edit install remove start status stop upgrade link unlink store
      complete -f -c packman -n "__fish_packman_using_command $subcommand" -a '(__fish_packman_get_packages)'
  end
end

set -l common_opts (awk '/PermittedCommonOptions = {/ { start = 1 };
        { if (start == 1 && match($1, "-")) { print $0 }};
        /}.freeze/ { start = 2; }' "$PACKMAN_ROOT/framework/command_line.rb" )

for line in $common_opts
  set -l opt (echo $line|sed 's/^\s*\'-\(.*\)\'\s*=>.*$/\1/')
  set -l opt_description (echo $line|sed 's/^.*=>\s*\'\(.*\)\'.*$/\1/')
  complete -f -c packman -n 'not __fish_packman_needs_command' -o "$opt" -d "$opt_description"
end

if test -f "$PACKMAN_ROOT/packman.config"
  set -l install_root (grep install_root $PACKMAN_ROOT/packman.config | cut -d '=' -f 2 | cut -d "'" -f 2 | cut -d '"' -f 2)
  set -l active_root (echo $install_root|sed "s#~/#$HOME/#")/packman.active
  switch (uname)
    case Linux
      set ld_library_path_name LD_LIBRARY_PATH
    case Darwin
      set ld_library_path_name DYLD_LIBRARY_PATH
  end
  set -x PATH "$active_root/bin" $PATH
  eval "set -x $ld_library_path_name \"$active_root/lib\" \"$active_root/lib64\" $ld_library_path_name"
  set -x MANPATH "$active_root/share/man" $MANPATH
  set -x PKG_CONFIG_PATH "$active_root/lib/pkgconfig" $PKG_CONFIG_PATH
end

function __fish_packman_use_packman_installed_ruby
  if test -d "$PACKMAN_ROOT/ruby/bin"
    set -x PATH "$PACKMAN_ROOT/ruby/bin" $PATH
  else
    echo "[Error]: There is no Ruby for PACKMAN!"
    return 1
  end
end

if not which ruby 2>&1 1> /dev/null 2>&1
  __fish_packman_use_packman_installed_ruby
else
  set -l RUBY_VERSION (ruby -v | cut -d ' ' -f 2)
  if echo $RUBY_VERSION|grep '^1\.[89]' > /dev/null
    __fish_packman_use_packman_installed_ruby
  end
end
