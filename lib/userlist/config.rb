module Userlist
  class Config
    DEFAULT_CONFIGURATION = {
      push_key:           nil,
      push_endpoint:      'https://push.userlist.io/',
      push_strategy:      :threaded,
      log_level:          :warn
    }.freeze

    def initialize(config_from_initialize = {})
      @config = default_config
        .merge(config_from_initialize)
        .merge(config_from_environment)
    end

    def merge(other_config)
      self.class.new(config.merge(other_config.to_h))
    end

    def to_h
      config
    end

    def ==(other)
      config == other.config
    end

  protected

    attr_reader :config

    def default_config
      DEFAULT_CONFIGURATION
    end

    def config_from_environment
      default_config.keys.each_with_object({}) do |key, config|
        value = ENV["USERLIST_#{key.to_s.upcase}"]
        config[key] = value if value
      end
    end

    def respond_to_missing?(name, include_private = false)
      name = name.to_s.sub(/=$/, '')
      config.key?(name.to_sym) || super
    end

    def method_missing(name, *args, &block)
      if respond_to_missing?(name)
        name = name.to_s
        method = name.match?(/=$/) ? :[]= : :[]
        name = name.sub(/=$/, '').to_sym
        config.public_send(method, name, *args, &block)
      else
        super
      end
    end
  end
end
