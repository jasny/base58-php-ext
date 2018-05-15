--TEST--
Check for base58_encode
--SKIPIF--
<?php if (!extension_loaded("base58")) print "skip"; ?>
--FILE--
<?php
var_dump(base58_encode("Hello World"));
var_dump(base58_encode("\0\0\0"));
var_dump(base58_encode(hash('sha256', 'foo', true)));

?>
--EXPECT--
string(15) "JxF12TrwUP45BMd"
string(3) "111"
string(44) "3yMApqCuCjXDWPrbjfR5mjCPTHqFG8Pux1TxQrEM35jj"

