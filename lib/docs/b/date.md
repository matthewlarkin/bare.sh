
# date

Date functions, calendars, and reminders

## Options

`cal`   Print a calendar
`date`   Print the current date and time
`stamp`   Print the current date and time in a timestamp format
`countdown`   Print a countdown to a given date and time
`add`   Add a given number of days to the current date
`subtract`   Subtract a given number of days from the current date
`format`   Format a given date and time string
`parse`   Parse a given date and time string

## Examples

# Print a calendar for December 2020
> b/date cal -m 12 -y 2020

# Print the current date and time
> b/date date

# Print the current date and time in a timestamp format
> b/date stamp

# Print a countdown to Christmas
> b/date countdown -d "2020-12-25 00:00:00"

