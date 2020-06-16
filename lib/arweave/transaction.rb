require 'base64'

module Arweave
  class Transaction
    attr_reader :attributes

    def initialize(attributes)
      @attributes =
        {
          id: '',
          last_tx: '',
          owner: '',
          tags: [],
          target: '',
          quantity: '0',
          data: '',
          reward: '0',
          signature: ''
        }.merge(attributes).yield_self do |hash|
          hash.each do |key, value|
            value.respond_to?(:map) ? hash[key] = value : hash[key] = value.to_s
          end

          hash
        end.transform_keys!(&:to_sym)
    end

    def sign(wallet)
      signature = wallet.sign(get_signature_data)

      @attributes[:signature] = Base64.urlsafe_encode64 signature, padding: false
      @attributes[:id] = Base64.urlsafe_encode64 Digest::SHA256.digest(signature), padding: false

      # TODO: verify signature
      signature
    end

    def commit
      Api.instance.commit(self)
    end

    private

    def get_signature_data
      Base64.urlsafe_decode64(attributes.fetch(:owner)) +
        Base64.urlsafe_decode64(attributes.fetch(:target)) +
        Base64.urlsafe_decode64(attributes.fetch(:data)) +
        attributes.fetch(:quantity) + attributes.fetch(:reward) +
        Base64.urlsafe_decode64(attributes.fetch(:last_tx)) + tags_string
    end

    def verify
      true
    end

    def tags_string
      # TODO: Create tags string
      ''
    end
  end
end
