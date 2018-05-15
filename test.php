<?php

$base58 = base58_encode($argv[1] ?? 'Hello world');

$value = base58_decode($base58);

echo $base58, " <=> ", $value, "\n";

