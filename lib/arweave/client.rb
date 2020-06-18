require 'base64'

module Arweave
  class Client
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
