# Arweave Ruby SDK
Got any important data that should be accessable for mankind in the future?
Love to build great things with Ruby?
Here comes your Ruby flavoured Arweave SDK solution.
Combine arweave's permanent storage solution and Ruby, so that your data will be stored for 200 years plus and create like that your own precious data Ruby.

## Installation
Run `gem install arweave`

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
jwk = JSON.parse(File.read('/path/to/arweave-keyfile.json'))
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

You can get the transaction attributes from the attributes hash:
```ruby
transaction.attributes[:id]
# => "tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz"
```

### Adding tags
You can add tags to a transaction using `add_tag` method:
```ruby
transaction.add_tag(name: 'tag_name', value: 'tag_value')
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
```

**NOTE**: You should add tags before commiting the transaction, because once the
transcation created, then you can't modify it and add tags to it.

You can also retrieve tags using `tags` method on the transaction instance:
```ruby
transaction.tags
# => [{ :name => "tag_name", :value => "tag_value" }]
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
the `status` class method returns an open struct that responds to `pending?` and
`accepted?` methods. If you need the text status, you can use `to_s` and
`to_sym` methods. To see the status JSON data, use the `data` method.
```ruby
status = Arweave::Transaction.status('tSF6pxiknBk0hBUTkdzq02E0zvsrT0xe4UtCzZit-bz')
status.pending? # => false
status.accepted? # => true
status.to_s # => "accepted"
status.to_sym # => :accepted
status.data
# => {
#   "block_height": 468306,
#   "block_indep_hash": "hh0ceHGfEOuTQWYMXGNzb2AabezqZUhtSw5vtUPKTtGmkViPArX5WeLBKBYZIwlS",
#   "number_of_confirmations": 388
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

## Directories
Directories are an abstract logical grouping around transactions which is implemented using path manifests. For more information, you can take a look at [path manifests](https://github.com/ArweaveTeam/arweave/wiki/Path-Manifests) documentation.

### Create a directory
To create a directory, first you must have transaction ids you want to put under the new directory and then specify a name for them.
```ruby
directory = Arweave::Directory.new(paths: { 'index.html' => 'BsHjWHBwSlmW_VgOcgLmsQacQjpohmvVDLMMVyuAkie' })
# => #<Arweave::Directory:0x00007ff3400b2350 @paths={...}>
```
Then you should get the transaction out of the directory instance and commit it.
```ruby
transaction = directory.transaction
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
transaction.sign(wallet).commit
# => #<Arweavev::Transaction:0x00007f9b61299330 @attributes={...}>
```
Then you can check your files in the directory using the name you've specified for the files. The endpoint for checking directory files is `/:dir_transaction_id/:filename`. For example
```
https:/arweave.net/JxiKsfr2es55AuCTSZg5oJLz7j4phRgireZt5SpChE/index.html
```

### Directory index
Arweave creates an HTML file to index your files in a directory, but if you like, you can set one of the files in the paths argument as index file.
```ruby
directory =
  Arweave::Directory.new(
    index: 'index.html',
    paths: {
      'index.html' => 'BsHjWHBwSlmW_VgOcgLmsQacQjpohmvVDLMMVyuAkie',
      'contact.html' => '-3U2-Oks289pQPH0Umz9Fy0G1Ti2UMlQYIr7NGIYL_M',
    }
  ) # => #<Arweave::Directory:0x00007ff3400b2350 @index="...", @paths={...}>
```

### Adding files to a directory
You can add files to a directory using the `add` method on a directory instance.
```ruby
directory.add('about.html' => 'LhT2WHBwFbv9_Pey67LmsQacQjpZxsyjDLMMVyuAkie')
# => #<Arweave::Directory:0x00007ff3400b2350 @index="...", @paths={...}>
```
**NOTE**: You should add the files to the directory before commiting the transaction,
else nothing will be added to the directory. In case you want to modify your directory,
you should create a new transaction for that.
