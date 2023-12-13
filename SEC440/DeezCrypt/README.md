# DeezCrypt

DeezCrypt is a command-line tool for file encryption and decryption using symmetric and asymmetric keys.

## Installation

1. Download code from: github.com/cdbizzle/Tech-Journal/blob/master/SEC440/DeezCrypt/deezcrypt.py
2. Optional: Download keypair generator and CSV generator (for testing)
3. Install all dependancies specified in deezcrypt.py

## Usage

Run `deezcrypt.py` with the following command-line options:

- `-n`: Generate a new random symmetric key.
- `-s <file>`: Encrypt a file with a random symmetric key.
- `-a`: Encrypt the symmetric key with an asymmetric key.
- `-d`: Decrypt the encrypted symmetric key with an asymmetric key.
- `-x <file>`: Decrypt an encrypted file with a symmetric key.

### Examples

Generate a new random symmetric key:

    ```
    python deezcrypt.py -n
    ```

Encrypt a file with a random symmetric key:

    ```
    python deezcrypt.py -s myfile.txt
    ```

Encrypt the symmetric key with an asymmetric key:

    ```
    python deezcrypt.py -a
    ```

Decrypt the encrypted symmetric key with an asymmetric key:

    ```
    python deezcrypt.py -d
    ```

Decrypt an encrypted file with a symmetric key:

    ```
    python deezcrypt.py -x myfile.deez
    ```
