dnl $Id$
dnl config.m4 for extension base58

PHP_ARG_WITH(base58, for base58 support,
[  --with-base58[=DIR]       Include base58 support])

if test "$PHP_BASE58" != "no"; then
  SEARCH_PATH="/usr/local /usr"     # you might want to change this
  SEARCH_FOR="/include/libbase58.h"  # you most likely want to change this

  AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
  AC_MSG_CHECKING([for libbase58])

  dnl user provided location
  if test -r $PHP_BASE58/$SEARCH_FOR; then # path given as parameter
    LIBBASE58_DIR=$PHP_BASE58
    AC_MSG_RESULT([found in $PHP_BASE58])

  dnl pkg-config output
  elif test -x "$PKG_CONFIG" && $PKG_CONFIG --exists libbase58; then
    LIBBASE58_VERSION=`$PKG_CONFIG libbase58 --modversion`
    LIBBASE58_CFLAGS=`$PKG_CONFIG libbase58 --cflags`
    LIBBASE58_LIBS=`$PKG_CONFIG libbase58 --libs`
    AC_MSG_RESULT(version $LIBBASE58_VERSION found using pkg-config)
    PHP_EVAL_LIBLINE($LIBBASE58_LIBS, BASE58_SHARED_LIBADD)
    PHP_EVAL_INCLINE($LIBBASE58_CFLAGS)

  dnl search default path list
  else
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        LIBBASE58_DIR=$i
        AC_MSG_RESULT(found in $i)
      fi
    done
    if test -z "$LIBBASE58_DIR"; then
      AC_MSG_ERROR([Please install libbase58 - See https://github.com/bitcoin/libbase58])
    fi
  fi

  LIBNAME=libbase58

  if test -n "$LIBBASE58_DIR"; then
    PHP_ADD_INCLUDE($LIBBASE58_DIR/include)
    PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $LIBBASE58_DIR/$PHP_LIBDIR, BASE58_SHARED_LIBADD)
  fi

  PHP_SUBST(BASE58_SHARED_LIBADD)

  AC_DEFINE(HAVE_BASE58, 1, [Whether you have base58 support])
  PHP_NEW_EXTENSION(base58, base58.c, $ext_shared)
fi

