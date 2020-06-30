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
        }.merge(attributes).transform_keys!(&:to_sym).yield_self do |hash|
          if hash[:data]
            hash[:data] = Base64.urlsafe_encode64(hash[:data], padding: false)
          end
          hash
        end
    end

    def sign(wallet)
      @attributes[:last_tx] = self.class.anchor
      @attributes[:reward] =
        Api.instance.reward(
          @attributes.fetch(:data, '').length,
          @attributes.fetch(:target, nil)
        ).body
      @attributes[:owner] = wallet.owner

      signature = wallet.sign(get_signature_data)
      @attributes[:signature] =
        Base64.urlsafe_encode64 signature, padding: false
      @attributes[:id] =
        Base64.urlsafe_encode64 Digest::SHA256.digest(signature), padding: false

      # TODO: verify signature
      self
    end

    def commit
      raise Arweave::TransactionNotSigned if @attributes[:signature].empty?

      Api.instance.commit(self)
      self
    end

    def add_tag(name:, value:)
      attributes[:tags].push(
        {
          name: Base64.urlsafe_encode64(name, padding: false),
          value: Base64.urlsafe_encode64(value, padding: false)
        }
      )

      self
    end

    def tags
      attributes[:tags].map do |tag|
        tag.transform_keys!(&:to_sym)
        {
          name: Base64.urlsafe_decode64(tag[:name]),
          value: Base64.urlsafe_decode64(tag[:value])
        }
      end
    end

    class << self
      def anchor
        Api.instance.get_transaction_anchor.body
      end

      def find(id)
        res = Api.instance.get_transaction(id)
        raise TransactionNotFound if res.not_found?
        data =
          JSON.parse(res.body).transform_keys!(&:to_sym).yield_self do |hash|
            hash[:data] = Base64.urlsafe_decode64(hash[:data]) if hash[:data]
            hash
          end

        new(data)
      end

      def data(id)
        res = Api.instance.get_transaction_data(id)
        raise TransactionNotFound if res.not_found?

        Base64.urlsafe_decode64(res.body)
      end

      def status(id)
        res = Api.instance.get_transaction_status(id)
        raise TransactionNotFound if res.not_found?

        create_status_object(
          :accepted,
          JSON.parse(res.body).transform_keys!(&:to_sym)
        )
      rescue JSON::ParserError
        create_status_object(:pending, {})
      end

      def create_status_object(status, data)
        status_object = OpenStruct.new(status: status, data: data)

        status_object.instance_eval do
          def accepted?
            status == :accepted
          end

          def pending?
            status == :pending
          end

          def to_s
            status.to_s
          end

          def to_sym
            status
          end
        end

        status_object
      end
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
      attributes.fetch(:tags).reduce('') do |acc, tag|
        acc + Base64.urlsafe_decode64(tag[:name]) +
          Base64.urlsafe_decode64(tag[:value])
      end
    end
  end
end
