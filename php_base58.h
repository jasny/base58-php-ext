#ifndef PHP_BASE58_H
#define PHP_BASE58_H 1

#define PHP_BASE58_VERSION "0.1.0"
#define PHP_BASE58_EXTNAME "base58"

#ifdef PHP_WIN32
# define PHP_SODIUM_API __declspec(dllexport)
#elif defined(__GNUC__) && __GNUC__ >= 4
# define PHP_SODIUM_API __attribute__ ((visibility("default")))
#else
# define PHP_SODIUM_API
#endif

static PHP_MINFO_FUNCTION(base58);

static PHP_FUNCTION(base58_encode);
static PHP_FUNCTION(base58_decode);

extern zend_module_entry base58_module_entry;
#define phpext_base58_ptr &base58_module_entry

#endif

