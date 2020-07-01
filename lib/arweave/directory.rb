module Arweave
  class Directory
    MANIFEST = 'arweave/paths'
    VERSION = '0.1.0'

    def initialize(index: nil, paths: {})
      if index && !paths.keys.include?(index)
        raise PathDoesNotExist.new('`index` path should be included in `paths` argument')
      end

      @index = index
      @paths = paths
    end

    def add(paths)
      @paths.merge!(paths)
      self
    end

    def paths
      @paths.reduce({}) do |acc, (key, value)|
        acc.merge(key => { id: value })
      end
    end

    def as_json(options = {})
      {
        manifest: MANIFEST,
        version: VERSION,
        **(@index ? { index: { path: @index } } : {}),
        paths: paths
      }
    end

    def transaction
      Transaction.new(data: self.to_json).add_tag(name: 'Content-Type', value: 'application/x.arweave-manifest+json')
    end
  end
end
