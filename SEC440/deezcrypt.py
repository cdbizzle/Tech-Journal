import argparse
import os
import binascii
from cryptography.fernet import Fernet
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP

def main():
    parser = argparse.ArgumentParser(description='DeezCrypt: A simple encryption/decryption tool ;)')
    
    # Define arguments/flags
    parser.add_argument('-n', action='store_true', help='New random symmetric key')
    parser.add_argument('-s', help='Encrypt file with random symmetric key')
    parser.add_argument('-a', action='store_true', help='Encrypt symmetric key with assymtric key')
    parser.add_argument('-d', action='store_true', help='Decrypt encrypted symmetric key with assymtric key')
    parser.add_argument('-x', help='Decrypt encrypted file with symmetric key')
    
    args = parser.parse_args()
    
    # Accessing the flag values 
    if args.n:
         # Random symmetric key generation
        key = Fernet.generate_key()
        key = binascii.hexlify(key).decode('utf-8')
        print(f'Copy this symmetric key for later use: {key}')

    if args.s:
        # Check if the file exists, error handling if it doesn't exist
        if not os.path.isfile(args.s):
            print(f'Error: File "{args.s}" does not exist!')
            return

        # Using the generated key 
        key = input('Enter the symmetric key: ')
        key = binascii.unhexlify(key)
        fernet = Fernet(key)
        
        # Opening the original file to encrypt
        with open(args.s, 'rb') as file:
            original = file.read()
            
        # Encrypting the file
        encrypted = fernet.encrypt(original)
        
        # Opening the file in write mode and writing the encrypted file
        with open(args.s + '.deez', 'wb') as encrypted_file:
            encrypted_file.write(encrypted)

        # Remove original file
        os.remove(args.s)

        # Print success message
        print(f'{args.s} has been encrypted successfully!')

    if args.a:
        # Load public key
        public_key = open('public_key.pem', 'rb').read()
        public_key = RSA.import_key(public_key)
        
        # Encrypt the symmetric key with the public RSA key
        cipher = PKCS1_OAEP.new(public_key)
        key = input('Enter the symmetric key: ')
        key = binascii.unhexlify(key)
        ciphertext = cipher.encrypt(key)

        # Convert to hex string for easy copy/paste
        hex_string = binascii.hexlify(ciphertext).decode('utf-8')

        # Display hex string for user to copy to allow for decoding
        print(f'The symmetric key has been encrypted. Copy the following text to allow for decryption:\n\n{hex_string}\n')

    if args.d:
        # Load private key
        private_key = open('private_key.pem', 'rb').read()
        private_key = RSA.import_key(private_key)
        
        # Prompt user to enter encrypted symmetric key
        hex_string = input('Enter the encrypted symmetric key: ')

        # Convert hex string to back to bytes
        ciphertext = binascii.unhexlify(hex_string)

        # Decrypt the symmetric key with the private RSA key
        cipher1 = PKCS1_OAEP.new(private_key)
        message = cipher1.decrypt(ciphertext)
        message = binascii.hexlify(message).decode('utf-8')

        print(f'The symmetric key has been decrypted. Copy the following key to decrypt your file: {message}')
        
    if args.x:
        # Check if the file exists, error handling if it doesn't exist
        if not os.path.isfile(str(args.x) + '.deez'):
            print(f'Error: File "{args.x}.deez" does not exist!')
            return

        # Prompt user to enter key to decrypt file
        input_key = input('Enter your key to decrypt a file: ')
        input_key = binascii.unhexlify(input_key)

        fernet = Fernet(input_key)

        # Opening the encrypted file
        with open(str(args.x) + '.deez', 'rb') as encrypted_file:
            encrypted_data = encrypted_file.read()

        # Decrypting the file
        decrypted = fernet.decrypt(encrypted_data)

        # Opening the file in write mode and writing the decrypted file
        with open(args.x, 'wb') as decrypted_file:
            decrypted_file.write(decrypted)

        # Remove encrypted version of file
        os.remove(str(args.x) + '.deez')

# Run main function
if __name__ == '__main__':
    main()
