
# encrypt

Encrypt strings and files with AES-256-CBC

## Options

`-s`   The string to encrypt
`-f`   The file to encrypt
`-o`   The output file
`-k`   The encryption key

## Examples

# Encrypt a string
> b/encrypt -s "Hello, world!" -k "mypassword"

# Encrypt a file
> b/encrypt -f file.txt -o file.enc -k "mypassword"

