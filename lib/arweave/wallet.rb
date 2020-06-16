require 'json/jwt'
require 'base64'
require 'digest'

module Arweave
  class Wallet
    attr_reader :address, :owner

    def initialize(jwk)
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
      private_key.sign_pss('SHA256', message, salt_length: 0, mgf1_hash: 'SHA256')
    end

    private

    attr_reader :jwk

    def private_key
      JSON::JWK.new(jwk).to_key
    end
  end
end
