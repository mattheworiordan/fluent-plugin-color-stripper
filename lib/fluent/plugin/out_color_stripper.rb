module Fluent
  class ColorStripperOutput < Output
    Fluent::Plugin.register_output('color_stripper', self)

    config_param :tag, :string
    config_param :strip_fields, :array, value_type: :string, default: []

    def configure(conf)
      super
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        router.emit(@tag, time, format_record(record))
      end

      chain.next
    end

    private

    def format_record(record)
      record.each_with_object({}) do |(key, val), object|
        object[key] = if strip_field?(key)
          uncolorize(val)
        else
          val
        end
      end
    end

    #
    # Return uncolorized string
    #
    def uncolorize(string)
      string.gsub(/\033\[\d{1,2}(;\d{1,2}){0,2}[mGK]/, '')
    end

    def strip_field?(field)
      @strip_fields.empty? || @strip_fields.include?(field)
    end
  end
end
