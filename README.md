# Arweave Ruby SDK
Ruby flavoured Arweave

## installation
Simply run

`gem install arweave`

or put the gem into your gemfile:
```ruby
gem 'arweave'
```
## Usage

### Configuration
The default node that this package uses is `https://arweave.net`. But you can simply configure it:

```ruby
Arweave::Client.configure do |config|
  config.host = 'xxx.xxx.xxx.xxx' # a valid node IP
  config.port = '1984'
  config.scheme = 'https'
end
```

### Creating transactions
For a complete list of argument you can pass to the `create_transaction` method, checkout the [documentation](https://docs.arweave.org/developers/server/http-api#submit-a-transaction).

```ruby
client = Arweave::Client.new
jwk = JSON.parse(File.read(File.expand_path(File.join('path-to-keyfile'))))
client.create_transaction(wallet: wallet, data: '<b>test</b>').commit
```
