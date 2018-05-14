<?php

$base58 = base58_encode("Hello world");

echo $base58, " - ", base58_decode($base58), "\n";

