
# email

Send and receive email with SMTP/POP3

## Options

`send`   Send email
`check`   Check email

## Examples

# Send an email
> b/email send -t "info@example.com" -f "me@mydomain.com" -s "Hello" -h
"<p>Hey there!</p>" -h "smtp.example.com" -p 465 -p "mypassword"

# Check email
> b/email check -H "pop3.mydomain.com" -P 995 -u "me@mydomain.com" -p
"mypassword"

