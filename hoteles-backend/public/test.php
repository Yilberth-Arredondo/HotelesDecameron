<?php

header('Content-Type: application/json');
header('X-Response-Time: ' . (microtime(true) - $_SERVER["REQUEST_TIME_FLOAT"]));

echo json_encode([
    'ok' => true,
    'endpoint' => 'test.php',
    'time' => date('c')
]);