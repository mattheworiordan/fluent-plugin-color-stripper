require 'colorize'
require 'fluent/test'
require 'fluent/plugin/out_color_stripper'

class ColorStripperOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::OutputTestDriver.new(Fluent::ColorStripperOutput).configure(conf)
  end

  def test_selected_fields
    d1 = create_driver %[
      type color_stripper
      tag  formatted
      strip_fields decolorize, decolorize_also
    ]

    d1.run do
      d1.emit({ 'keep_color' => 'red'.colorize(:red), 'decolorize' => 'green'.colorize(:green) })
      d1.emit({ 'no_color' => 'no_color', 'decolorize_also' => 'yellow'.colorize(:yellow) })
    end

    assert_equal [
      {
        'keep_color' => 'red'.colorize(:red),
        'decolorize' => 'green'
      },
      {
        'no_color' => 'no_color',
        'decolorize_also' => 'yellow'
      }
    ], d1.records
  end

  def test_all_fields
    d1 = create_driver %[
      type color_stripper
      tag  formatted
    ]

    d1.run do
      d1.emit({ 'color' => 'red'.colorize(:red), 'decolorize' => 'green'.colorize(:green) })
      d1.emit({ 'no_color' => 'no_color', 'decolorize_also' => 'yellow'.colorize(:yellow) })
    end

    assert_equal [
      {
        'color' => 'red',
        'decolorize' => 'green'
      },
      {
        'no_color' => 'no_color',
        'decolorize_also' => 'yellow'
      }
    ], d1.records
  end

  def test_missing_tag
    err = assert_raises Fluent::ConfigError do
      create_driver %[
        type color_stripper
      ]
    end

    assert_match /tag.*required/, err.message
  end

  def test_dangling_colors
    d1 = create_driver %[
      type color_stripper
      tag  formatted
    ]

    d1.run do
      d1.emit('decolorize' => "\033[0m")
      d1.emit('decolorize' => "\033[0;36;1m")
      d1.emit('decolorize' => "\033[0;36m")
    end

    assert_equal [
      {'decolorize' => ''},
      {'decolorize' => ''},
      {'decolorize' => ''}
    ], d1.records
  end
end
