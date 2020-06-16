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
