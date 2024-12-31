<?php
// Check if OpenSSL extension is loaded
if (!extension_loaded('openssl')) {
    echo "OpenSSL extension is not loaded.\n";
    exit(1);
}

// Generate a private and public key pair
$res = openssl_pkey_new([
    "private_key_bits" => 2048,
    "private_key_type" => OPENSSL_KEYTYPE_RSA,
]);

if (!$res) {
    echo "Failed to generate key pair.\n";
    exit(1);
}

// Export the private key
openssl_pkey_export($res, $privateKey);

// Extract the public key
$details = openssl_pkey_get_details($res);
$publicKey = $details['key'];

// Display the keys
echo "Private Key:\n$privateKey\n";
echo "Public Key:\n$publicKey\n";

// Test encryption and decryption
$data = "Test OpenSSL functionality";
echo "Original Data: $data\n";

// Encrypt the data
openssl_public_encrypt($data, $encryptedData, $publicKey);
echo "Encrypted Data: " . base64_encode($encryptedData) . "\n";

// Decrypt the data
openssl_private_decrypt($encryptedData, $decryptedData, $privateKey);
echo "Decrypted Data: $decryptedData\n";

?>