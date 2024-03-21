
# import

Import a file or directory into the $BARE_HOME/.nb directory

## Options

`:1`   The URL or file path to import
`(:2)`   The destination path (defaults to $BARE_HOME/.nb/imports/$(basename
$1))

## Examples

# Import a file from a URL
> b/import https://example.com/image.jpg images/myfolder/imported-
image.jpg`

# Import a file from a file path
> b/import /path/to/file.txt files/myfolder/imported-file.txt`

