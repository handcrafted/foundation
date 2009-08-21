module NewRelic
  # Metric parsing logic mixin.  Given a metric name (attribute called "name"), provide a set of accessors
  # that enable inspection of the metric.  A metric has 2 or more segments, each separated
  # by the '/' character.  The metric's category is specified by its first segment. Following
  # are the set of categories currently supported by NewRelic's default metric set:
  #
  # * Controller
  # * ActiveRecord
  # * Rails
  # * WebService
  # * View
  # * Database
  # * Custom
  #
  # Based on the category of the metric, specific parsing logic is defined in the source files
  # countained in the "metric_parsers" sub directory local to this file.
  #
  
  class MetricParser
    
    SEPARATOR = '/' unless defined? SEPARATOR
    attr_reader :name
    
    # Load in the parsers classes in the plugin:
    Dir[File.join(File.dirname(__FILE__), "metric_parser", "*.rb")].each { | file | require file }
    
    # return a string that is parsable via the Metric parser APIs
    def self.for_metric_named(s)
      category = (s =~ /^([^\/]*)/) && $1
      parser_class = self
      if category
        parser_class = NewRelic::MetricParser.const_get(category) if (NewRelic::MetricParser.const_defined?(category) rescue nil)
      end
      parser_class.new s
    end

    def self.parse(s)
      for_metric_named(s)
    end
    
    def method_missing(method_name, *args)
      return false if method_name.to_s =~ /^is_.*\?/
      super
    end
    # The short name for the metric is defined as all of the segments
    # of the metric name except for its first (its domain).
    def short_name
      if segments.empty?
        ''
      elsif segments.length == 1
        segments[0]
      else
        segments[1..-1].join(SEPARATOR)
      end
    end
    
    def pie_chart_label
      developer_name
    end
    
    def developer_name
      short_name
    end
    
    # Return the name of another metric if the current
    # metric is really add-on data for another metric.
    def base_metric_name
      nil
    end
    
    def category
      segments[0]
    end
    
    def segments
      return [] if !name
      @segments ||= name.split(SEPARATOR).freeze
    end
    
    # --
    # These accessors are used to allow chart to use a specific segment  in the metric
    # name for label construction as a zero-arg accessor
    # ++
    def segment_0; segments[0]; end
    def segment_1; segments[1]; end
    def segment_2; segments[2]; end
    def segment_3; segments[3]; end
    def segment_4; segments[4]; end
    def last_segment; segments.last; end
    
    # This is the suffix used for call rate or throughput.  By default, it's cpm
    # but things like controller actions will override to use something like 'rpm'
    # for requests per minute
    def call_rate_suffix
    'cpm'
    end
    
    def url
    ''
    end

    def initialize(name)
      @name = name
    end
    
  end  
end
