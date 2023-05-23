## To install OpenSSL on Ubuntu, you can use the following command:

```shell
sudo apt-get update && sudo apt-get install openssl
```

This will update your package list and install OpenSSL on your system.

To create a `certificate.crt` and `private.key` file in the current directory using a single command, you can run the following OpenSSL command:

```shell
openssl -days 365  req -x509 -newkey rsa:2048 -nodes -keyout private.key -out certificate.crt -subj "/CN=example.com"
```
This command generates a self-signed certificate with a validity of `365` days, using a `2048-bit RSA` key. The private key is saved to a file named `private.key`, and the certificate is saved to a file named `certificate.crt`. The `-subj` option is used to set the subject DN (Distinguished Name) of the certificate. In this example, the common name (CN) is set to "example.com".

Note that this self-signed certificate should only be used for testing or development purposes. For a production environment, a certificate signed by a trusted Certificate Authority should be used instead.