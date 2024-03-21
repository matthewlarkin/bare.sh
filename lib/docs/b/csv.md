
# csv

Interface with CSV files

## Options

`limit`   Print the first n lines of a csv file
`dedupe`   Deduplicate a csv file
`filter`   Filter a csv file based on a given column and match string
`math`   Perform math operations on a csv file

## Examples

# Print the first n lines of a csv file
> b/csv limit -f file.csv -o output.csv

# Deduplicate a csv file
> b/csv dedupe -f file.csv -o output.csv

# Filter a csv file based on a given column and match string
> b/csv filter -f file.csv -c column -m match

# Perform math operations on a csv file
> b/csv math -f file.csv -c column -o operation

