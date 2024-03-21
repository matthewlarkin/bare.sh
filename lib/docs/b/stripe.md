
# stripe

Interact with the Stripe API

## Options

`checkouts.create`   Create a new checkout session
`checkout.get`   Get a checkout session
`customers.list`   List all customers
`customers.create`   Create a new customer

## Examples

#usd|Item | Create a new checkout session
> stripe checkouts.create -a 100 -c usd -u customer_123 -s
https://example.com/success -l 100

# Get a checkout session
> stripe checkout.get -i cs_test_123

# List all customers
> stripe customers.list

