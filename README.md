# Fluent::Plugin::ColorStripper

An out plugin for [Fluentd](http://fluentd.org) to strip ANSI color from log files.  No more nasty logs from apps that use color that appear similar to:

    [0;33;49mWARN [0m : [0;33;49mRate limit of 6 notifications per hour met for Http monitor 'test' for 'server
    '[0m

You can specify all or specific fields to have the ANSI color stripped

## Installation

    $ gem install fluent-plugin-color-stripper

## Usage

    <match input.tag>
        @type color_stripper
        tag  output.tag
        strip_fields key1, key2
    </match>

Pass this record:

    input.tag: {
        "key1": "\033[30mvalue1\033[0m",
        "key2": "\033[31mvalue2\033[0m"
        "key3": "\033[32mvalue3\033[0m"
    }

Then you get:

    output.tag: {
        "key1": "value1",
        "key2": "value2",
        "key3": "\033[32mvalue3\033[0m"
    }

### strip_fields

If the field `strip_fields` is omitted or is empty then all fields will have their color stripped.

    <match input.tag>
        @type color_stripper
        tag  output.tag
    </match>

Pass this record:

    input.tag: {
        "key1": "\033[30mvalue1\033[0m",
        "key2": "\033[31mvalue2\033[0m"
        "key3": "\033[32mvalue3\033[0m"
    }

Then you get:

    output.tag: {
        "key1": "value1",
        "key2": "value2",
        "key3": "value2"
    }
