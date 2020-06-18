require 'json/jwt'
require 'base64'
require 'digest'
require 'ostruct'

module Arweave
  class Wallet
    attr_reader :address, :owner, :api

    def initialize(jwk)
      @api = Api.instance
      @jwk = jwk.transform_keys!(&:to_sym)
    end

    def owner
      jwk.dig(:n)
    end

    def address
      Base64.urlsafe_encode64(
        Digest::SHA256.digest(Base64.urlsafe_decode64(owner)),
        padding: false
      )
    end

    def sign(message)
      private_key.sign_pss(
        'SHA256',
        message,
        salt_length: 0, mgf1_hash: 'SHA256'
      )
    end

    def balance
      balance_in_winstons = BigDecimal(api.get_wallet_balance(address).body)

      OpenStruct.new(
        ar: balance_in_winstons / 1e12,
        winston: balance_in_winstons
      )
    end

    def last_transaction_id
      api.get_last_transaction_id(address).body
    end

    private

    attr_reader :jwk

    def private_key
      JSON::JWK.new(jwk).to_key
    end
  end
end
