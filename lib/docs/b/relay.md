
# relay

Relays information (outputs it to the stdout or a file)

## Options

`-c`   Text string to relay
`-o`   Output file to relay to (defaults to stdout)
`-f`   File to relay
`-l`   List the files and directories of the specified directory within the
.nb folder

## Examples

# Relay a string
> relay -c "Hello, world!"

# Relay the contents of a file
> relay -f file.txt

# List the files and directories of the specified directory within the .nb
folder
> relay -l scripts

