require 'base64'

module Arweave
  class Client
    def initialize
      @api = Api.instance
    end

    def create_transaction(wallet:, **attributes)
      attributes.transform_keys!(&:to_sym)

      transaction =
        Transaction.new(
          last_tx: api.get_transaction_anchor,
          owner: wallet.owner,
          tags: [],
          target: attributes.fetch(:target, ''),
          quantity: attributes.fetch(:quantity, '0'),
          data:
            Base64.urlsafe_encode64(
              attributes.fetch(:data, ''),
              padding: false
            ),
          reward:
            api.reward(
              attributes.fetch(:data, '').length,
              attributes.fetch(:target, nil)
            )
        )

      transaction.sign(wallet)
      transaction
    end

    def get_transaction(transaction_id)
      res = api.get_transaction(transaction_id)
      raise TransactionNotFound if res.not_found?

      Transaction.new(JSON.parse(res.body))
    end

    def get_transaction_data(transaction_id)
      res = api.get_transaction_data(transaction_id)
      raise TransactionNotFound if res.not_found?

      Base64.urlsafe_decode64(res.body)
    end

    def get_transaction_status(transaction_id)
      res = api.get_transaction_status(transaction_id)
      raise TransactionNotFound if res.not_found?

      {
        status: :accepted,
        data: JSON.parse(res.body).transform_keys(&:to_sym)
      }
    rescue JSON::ParserError
      {
        status: :pending,
        data: {}
      }
    end

    def commit(transaction)
      api.commit(transaction)
    end

    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield @configuration
    end

    private

    class Configuration
      attr_accessor :scheme, :host, :port

      def initialize
        @scheme = 'https'
        @port = '443'
        @host = 'arweave.net'
      end
    end

    attr_reader :api
  end
end
