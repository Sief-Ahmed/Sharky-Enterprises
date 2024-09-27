<?php
// index.php

header('Content-Type: application/json');

// Parse the request URI
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Route handling
if ($uri === '/quote') {
    // Define the quote
    $quote = "When in doubt, fish";

    // Return the quote as JSON
    echo json_encode(['quote' => $quote]);
} else {
    // Return a 404 Not Found response for other routes
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
}
?>
