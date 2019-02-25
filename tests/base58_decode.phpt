--TEST--
Test base58_decode
--SKIPIF--
<?php if (!extension_loaded("base58")) print "skip"; ?>
--FILE--
<?php
var_dump(base58_decode("JxF12TrwUP45BMd"));
var_dump(bin2hex(base58_decode("111")));
var_dump(bin2hex(base58_decode("3yMApqCuCjXDWPrbjfR5mjCPTHqFG8Pux1TxQrEM35jj")));

?>
--EXPECT--
string(11) "Hello World"
string(6) "000000"
string(64) "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae"

