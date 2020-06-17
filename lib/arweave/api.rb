require 'httparty'

module Arweave
  class Api
    include HTTParty

    class << self
      def instance
        @instance ||=
          new(
            scheme: Client.configuration&.scheme || 'https',
            host: Client.configuration&.host || 'arweave.net',
            port: Client.configuration&.port || '443'
          )
      end
    end

    def get_transaction_anchor
      self.class.get('/tx_anchor')
    end

    def get_transaction(transaction_id)
      self.class.get("/tx/#{transaction_id}")
    end

    def get_transaction_data(transaction_id)
      self.class.get("/tx/#{transaction_id}/data")
    end

    def get_transaction_status(transaction_id)
      self.class.get("/tx/#{transaction_id}/status")
    end

    def get_last_transaction(wallet_address)
      self.class.get("/wallet/#{wallet_address}/last_tx")
    end

    def get_wallet_balance(wallet_address)
      self.class.get("/wallet/#{wallet_address}/balance")
    end

    def reward(byte_size, address = '')
      self.class.get("/price/#{byte_size}/#{address}")
    end

    def commit(transaction)
      self.class.post(
        '/tx',
        body: transaction.attributes.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    private

    def initialize(scheme:, host:, port:)
      self.class.base_uri URI::Generic.build(
                            scheme: scheme, host: host, port: port
                          ).to_s
    end
  end
end
