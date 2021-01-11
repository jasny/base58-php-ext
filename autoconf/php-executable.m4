dnl
dnl Symlink current php executable
dnl
AC_CONFIG_COMMANDS_POST([
  ln -s "$PHP_EXECUTABLE" build/php
])
