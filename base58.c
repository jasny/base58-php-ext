/*
   +----------------------------------------------------------------------+
   | PHP Version 7                                                        |
   +----------------------------------------------------------------------+
   | Copyright (c) 1997-2010 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
   | Author: Arnold Daniels <arnold@legalthings.io>                       |
   +----------------------------------------------------------------------+
 */

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "php_base58.h"
#include "zend_exceptions.h"
#include "ext/standard/info.h"

#include <libbase58.h>

#if HAVE_BASE58

static const zend_function_entry base58_functions[] = {
    PHP_FE(base58_encode, NULL)
    PHP_FE(base58_decode, NULL)
    PHP_FE_END
};

zend_module_entry base58_module_entry = {
    STANDARD_MODULE_HEADER,
    PHP_BASE58_EXTNAME,
    base58_functions,
    NULL,
    NULL,
    NULL,
    NULL,
    PHP_MINFO(base58),
    PHP_BASE58_VERSION,
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_BASE58
ZEND_GET_MODULE(base58)
#endif

static PHP_MINFO_FUNCTION(base58)
{
	php_info_print_table_start();
	php_info_print_table_row(2, "base58 functions", "enabled");
	php_info_print_table_end();
}

PHP_FUNCTION(base58_encode)
{
    const char *data;
    size_t data_len;

    char *b58;
    size_t b58_len;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &data, &data_len) == FAILURE) {
        RETURN_FALSE;
    }

    b58_len = ceil(data_len * 1.5) + 1;
    b58 = emalloc(b58_len);

    if (!b58enc(b58, &b58_len, data, data_len)) {
        php_error_docref(NULL TSRMLS_CC, E_WARNING, "Failed to base58 encode string");
        RETURN_FALSE;
    }

    RETURN_STRINGL(b58, b58_len - 1);
}

PHP_FUNCTION(base58_decode)
{
    const char *b58;
    size_t b58_len;

    char *data;
    size_t data_len;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &b58, &b58_len) == FAILURE) {
        RETURN_FALSE;
    }

    data_len = b58_len;
    data = emalloc(data_len);

    if (!b58tobin(data, &data_len, b58, b58_len)) {
        php_error_docref(NULL TSRMLS_CC, E_WARNING, "Failed to base58 decode string");
        RETURN_FALSE;
    }

    // libbase58 starts at the end of the buffer, so skip preceding '\0' chars.
    RETURN_STRINGL(data + (b58_len - data_len), data_len);
}

#endif

