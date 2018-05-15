# Base58 PHP extension

PHP extension for base58 encoding and decoding using the Bitcoin alphabet.

Using this extension is an order of magnitude faster than using userspace functions.

## Requirements

* PHP 7.x
* [libbase58](https://github.com/bitcoin/libbase58)

_Ubuntu users can install libbase58 with headers using `apt install libbase58-dev`._

## Installation

    phpize
    ./configure --with-base58
    make
    make install

Add the following line to your `php.ini`

    extension=base58.so

## Functions

### base58_encode

Base58 encode a string.

    string base58_encode(string $data)

Triggers an `E_WARNING` and returns `false` if string can't be encoded.

### base58_encode

Decode a base58 encoded string.

    string base58_decode(string $data)

Triggers an `E_WARNING` and returns `false` if string can't be decoded.

## Caveat

To encode a hash, make sure you're using the raw hash and not a hexidecimal string.

    $rawHash = hash('sha256', 'some string', true); // The `true` makes the function return a raw hash
    $encodedHash = base58_encode($rawHash);

