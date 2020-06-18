# Arweave Ruby SDK
Ruby flavoured Arweave

## installation
Simply run

`gem install arweave`

or put the gem into your gemfile:
```ruby
gem 'arweave', '~> 1.0.0'
```

## Configuration
The default node that this package uses is `https://arweave.net`. But you can simply configure it:

```ruby
Arweave::Client.configure do |config|
  config.host = 'xxx.xxx.xxx.xxx' # a valid node IP
  config.port = '1984'
  config.scheme = 'https'
end
```

## Transaction methods

### Creating transactions
For a complete list of arguments you can pass to the `new` method,
checkout the [documentation](https://docs.arweave.org/developers/server/http-api#submit-a-transaction).

```ruby
jwk = JSON.parse(File.read(File.expand_path(File.join('path-to-keyfile'))))
wallet = Arweave::Wallet.new jwk

transaction = Arweave::Transaction.new(data: '<b>test</b>')
transaction.sign(wallet)
transaction.commit
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
```

You can also chain the methods
```ruby
Arweave::Transaction.new(data: '<b>test</b>').sign(wallet).commit
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
```

You can get the transaction attributes from the attribuets hash:
```ruby
transaction.attributes[:id]
# => "tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz"
```

### Find transaction by id
```ruby
Arweave::Transaction.find('tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz')
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
```

### Getting a transaction data
the transaction `data` class method returns base64 decoded data for data transactions
```ruby
Arweave::Transaction.data('tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz')
# => "<b>test</b>"
```

### Getting transaction status
the `status` class method returns a hash containing transaction status
(which is pending or accepted) and the and the data and a hash about the block.
```ruby
Arweave::Transaction.status('tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz')
# => {
#   "status": "accepted",
#   "data": {
#     "block_height": 468306,
#     "block_indep_hash": "hh0ceHGfEOuTQWYMXGNzb2AabezqZUhtSw5vtUPKTtGmkViPArX5WeLBKBYZIwlS",
#     "number_of_confirmations": 388
#   }
# }
```

## Wallet methods

### Getting wallet owner
The `owner` method returns the full RSA modulus value of the wallet.
```ruby
wallet.owner
# => "...-Tr3S_HBgX2ixr1ZwEMD7iJlUEJrvItE-lBepKHHLd0OFJ3PgkKsP15TEefVezhssSO_s_EQdJ4yA7Ij8Y_XsAGXrjM76MYa7QZNWTLqhc7cixBDBWk0KLPBuN-AdjN71BXYJRZ_5gMzUyu1GKSuaIcvzISTqPbVuJwFPTNLkmm3t-wRtioKAyQzieqskQuh4iYKmeBQ0SAuDd0Xf3wcGxWRIrK7lphP2A0cIA65dUY2klDbiZVwWh_82igD00cGmZLSzFTaVNqIBNyPN5nTLriCGnYbWnMj9-uPghK_NYGyKYOkwPGJB3bZ_fPvLzWkrTnKi1uqyKdp_4AEKAfKLO3agh7rfB3wNKe-..."
```

### Getting wallet address
The address of a wallet is a Base64 URL encoded SHA-256 hash of the `n` value from the JWK.
```ruby
wallet.address
# => "bQ3zPuzKXOpnaZ_O_kcbByRBaso2e4nyIN8KmsQH80"
```

### Getting wallet balance
This method returns an open struct contains the balance both `ar` and `winston`
as `BigDecimal`.
```ruby
balance = wallet.balance
# => #<OpenStruct ar=0.249891527825e0, winston=0.249891527825e12>
balance.ar # => 0.249891527825e0
balance.winston # => 0.249891527825e12

balance.winston.to_i # => 249891527825
```

### Get the wallet's last transaction id
```ruby
wallet.last_transaction_id # => "BsHjWHBwSlmW_VgOcgLmsQacQjpohmvVDLMMVyuAkie"
```
