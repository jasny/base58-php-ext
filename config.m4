dnl $Id$
dnl config.m4 for extension base58

sinclude(./autoconf/pecl.m4)
sinclude(./autoconf/php-executable.m4)

PECL_INIT([base58])

PHP_ARG_ENABLE(base58, whether to enable base58, [ --enable-base58   Enable base58])

if test "$PHP_BASE58" != "no"; then
  AC_DEFINE(HAVE_BASE58, 1, [whether base58 is enabled])
  PHP_NEW_EXTENSION(base58, base58.c lib/libbase58.c, $ext_shared)

  PHP_ADD_MAKEFILE_FRAGMENT
  PHP_INSTALL_HEADERS([ext/base58], [php_base58.h])
fi
