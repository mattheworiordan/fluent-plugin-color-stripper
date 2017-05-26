module Fluent
  class ColorStripperOutput < Output
    Fluent::Plugin.register_output('color_stripper', self)

    config_param :tag, :string
    config_param :strip_fields, :string, default: nil

    def configure(conf)
      super

      @tag = conf.fetch('tag') { raise ArgumentError, 'tag field is required to direct transformed logs to' }

      @strip_fields_arr = conf['strip_fields'].to_s.split(/\s*,\s*/).map do |field|
        field unless field.strip.empty?
      end.compact
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
      @strip_fields_arr.empty? || @strip_fields_arr.include?(field)
    end
  end
end
