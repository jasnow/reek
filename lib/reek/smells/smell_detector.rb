require 'set'
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'core', 'smell_configuration')

module Reek
  module Smells

    module ExcludeInitialize
      def self.default_config
        super.adopt(EXCLUDE_KEY => ['initialize'])
      end
      def initialize(source, config = self.class.default_config)
        super(source, config)
      end
    end

    #
    # Shared responsibilities of all smell detectors.
    #
    class SmellDetector

      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'

      # The default value for the +EXCLUDE_KEY+ if it isn't specified
      # in any configuration file.
      DEFAULT_EXCLUDE_SET = []

      class << self
        def contexts      # :nodoc:
          [:defn, :defs]
        end

        def default_config
          {
            Core::SmellConfiguration::ENABLED_KEY => true,
            EXCLUDE_KEY => DEFAULT_EXCLUDE_SET
          }
        end
      end

      attr_reader :smells_found   # SMELL: only published for tests

      def initialize(source, config = self.class.default_config)
        @source = source
        @config = Core::SmellConfiguration.new(config)
        @smells_found = Set.new
      end

      def register(hooks)
        return unless @config.enabled?
        self.class.contexts.each { |ctx| hooks[ctx] << self }
      end

      # SMELL: Getter (only used in 1 test)
      def enabled?
        @config.enabled?
      end

      def configure_with(config)
        @config.adopt!(config)
      end

      def examine(context)
        examine_context(context) if @config.enabled? && config_for(context)[Core::SmellConfiguration::ENABLED_KEY] != false && !exception?(context)
      end

      def examine_context(context)
      end

      def exception?(context)
        context.matches?(value(EXCLUDE_KEY, context, DEFAULT_EXCLUDE_SET))
      end

      def report_on(report)
        @smells_found.each { |smell| smell.report_on(report) }
      end

      def value(key, ctx, fall_back)
        config_for(ctx)[key] || @config.value(key, ctx, fall_back)
        # BUG: the correct value should be found earlier in this object's
        # lifecycle, so that the subclasses don't have to call up into the
        # superclass.
      end

      def config_for(ctx)
        ContextConfiguration.new(ctx).config[self.class.name.split(/::/)[-1]] || {}
      end

      #
      # Contextual configuration from comments for smell detectors
      #
      class ContextConfiguration
        def initialize(context)
          @context = context
        end

        def config
          return Hash.new if @context.nil? || @context.exp.nil?
          config = inline_config
          ContextConfiguration.new(@context.instance_variable_get('@outer')).config.push_keys(config)
          # no tests for this -------------------------------------^
          config
        end

      protected
        def inline_config
          Source::CodeComment.new(@context.exp.comments || '').config
        end
      end
      
    end
  end
end
