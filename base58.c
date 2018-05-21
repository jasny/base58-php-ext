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
    NULL,
    PHP_BASE58_VERSION,
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_BASE58
ZEND_GET_MODULE(base58)
#endif

PHP_FUNCTION(base58_encode)
{
    const char *data;
    size_t data_len;

    zend_string *b58;

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "s", &data, &data_len) == FAILURE) {
        RETURN_FALSE;
    }

    b58 = zend_string_alloc(ceil(data_len * 1.5) + 1, 0);

    if (!b58enc(ZSTR_VAL(b58), &ZSTR_LEN(b58), data, data_len)) {
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
    const char *b58;
    size_t b58_len;

    char *data;
    size_t data_len;

    zend_string *result;

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "s", &b58, &b58_len) == FAILURE) {
        RETURN_FALSE;
    }

    data_len = b58_len;
    data = emalloc(data_len);

    if (!b58tobin(data, &data_len, b58, b58_len)) {
        efree(data);

        php_error_docref(NULL, E_WARNING, "Failed to base58 decode string");
        RETURN_FALSE;
    }

    /* libbase58 starts at the end of the buffer, so skip preceding '\0' chars. */
    result = zend_string_init(data + (b58_len - data_len), data_len, 0);
    efree(data);

    RETURN_STR(result);
}

#endif

