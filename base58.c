/*
  +----------------------------------------------------------------------+
  | Base58 PHP extension                                                 |
  +----------------------------------------------------------------------+
  | Copyright (c) 2018 Stichting LegalThings One foundation              |
  +----------------------------------------------------------------------+
  | Permission is hereby granted, free of charge, to any person          |
  | obtaining a copy of this software and associated documentation files |
  | (the "Software"), to deal in the Software without restriction,       |
  | including without limitation the rights to use, copy, modify, merge, |
  | publish, distribute, sublicense, and/or sell copies of the Software, |
  | and to permit persons to whom the Software is furnished to do so,    |
  | subject to the following conditions:                                 |
  |                                                                      |
  | The above copyright notice and this permission notice shall be       |
  | included in all copies or substantial portions of the Software.      |
  |                                                                      |
  | THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
  | EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
  | MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                |
  | NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS  |
  | BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN   |
  | ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN    |
  | CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     |
  | SOFTWARE.                                                            |
  +----------------------------------------------------------------------+
  | Author: Arnold Daniels <arnold@jasny.net>                            |
  +----------------------------------------------------------------------+
*/

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "php.h"
#include "php_base58.h"
#include "zend_exceptions.h"

#include "lib/libbase58.h"

#if HAVE_BASE58

ZEND_BEGIN_ARG_INFO_EX(arginfo_base58_encode, 0, 0, 1)
    ZEND_ARG_TYPE_INFO(0, data, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_base58_decode, 0, 0, 1)
    ZEND_ARG_TYPE_INFO(0, data, IS_STRING, 0)
ZEND_END_ARG_INFO()

static const zend_function_entry base58_functions[] = {
    PHP_FE(base58_encode, arginfo_base58_encode)
    PHP_FE(base58_decode, arginfo_base58_decode)
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
    NULL,
    PHP_BASE58_VERSION,
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_BASE58
ZEND_GET_MODULE(base58)
#endif

PHP_FUNCTION(base58_encode)
{
    zend_string *data;

    zend_string *b58;

    ZEND_PARSE_PARAMETERS_START(1, 1)
        Z_PARAM_STR(data)
    ZEND_PARSE_PARAMETERS_END();

    b58 = zend_string_alloc(ceil(ZSTR_LEN(data) * 1.5) + 1, 0);

    if (!b58enc(ZSTR_VAL(b58), &ZSTR_LEN(b58), ZSTR_VAL(data), ZSTR_LEN(data))) {
        zend_string_free(b58);

        php_error_docref(NULL, E_WARNING, "Failed to base58 encode string");
        RETURN_FALSE;
    }

    /* Exclude ending '\0` from string length */
    ZSTR_LEN(b58)--;

    RETURN_STR(b58);
}

PHP_FUNCTION(base58_decode)
{
    zend_string *b58;

    char *data;
    size_t data_len;

    zend_string *result;

    ZEND_PARSE_PARAMETERS_START(1, 1)
        Z_PARAM_STR(b58)
    ZEND_PARSE_PARAMETERS_END();

    data_len = ZSTR_LEN(b58);
    data = emalloc(data_len);

    if (!b58tobin(data, &data_len, ZSTR_VAL(b58), ZSTR_LEN(b58))) {
        efree(data);

        php_error_docref(NULL, E_WARNING, "Failed to base58 decode string");
        RETURN_FALSE;
    }

    /* libbase58 starts at the end of the buffer, so skip preceding '\0' chars. */
    result = zend_string_init(data + (ZSTR_LEN(b58) - data_len), data_len, 0);
    efree(data);

    RETURN_STR(result);
}

#endif

