module Stencil
  class MissingNeedError < StandardError; end

  class Base
    include HtmlHelpers
    class << self
      def needs(*keys)
        @keys ||= []
        @keys.concat keys.map(&:to_s)
        @keys
      end

      def assert_keys(keys)
        needs.each do |key|
          if !keys.map(&:to_s).include?(key)
            raise MissingNeedError, "Required value \"#{key}\" not included"
          end
        end
      end

      def template(name)
        @template_name = name
      end

      def template_file
        finder = Stencil::Config.default_template_finder
        @template_file ||= finder.find(@template_name)
      end
    end

    def initialize(options={})
      options.each_pair do |k, v|
        self.instance_variable_set "@#{k}", v
      end
      self.class.assert_keys(options.keys)
    end

    def template
      @template ||= Tilt.new(self.class.template_file)
    end

    def to_html
      self.template.render(self)
    end

    alias :render :to_html
  end
end
