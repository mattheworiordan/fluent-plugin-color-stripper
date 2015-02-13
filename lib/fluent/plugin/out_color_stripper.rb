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
        Engine.emit(@tag, time, format_record(record))
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
      scan_for_colors(string).inject('') do |str, match|
        str << (match[3] || match[4])
      end
    end

    #
    # Scan for colorized string
    #
    def scan_for_colors(string)
      string.scan(/\033\[([0-9]+);([0-9]+);([0-9]+)m(.+?)\033\[0m|([^\033]+)/m)
    end

    def strip_field?(field)
      puts @strip_fields_arr
      @strip_fields_arr.empty? || @strip_fields_arr.include?(field)
    end
  end
end
