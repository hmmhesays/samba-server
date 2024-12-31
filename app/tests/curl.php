<?php
// Initialize cURL session
$ch = curl_init();

// Set the URL to fetch
curl_setopt($ch, CURLOPT_URL, "https://example.com");

// Return the response instead of printing it
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

// Execute the cURL session
$response = curl_exec($ch);

// Check for errors
if (curl_errno($ch)) {
    echo 'cURL error: ' . curl_error($ch);
} else {
    // Print the response
    echo $response;
}

// Close the cURL session
curl_close($ch);
?>
