require_relative 'my_complex_rules.rb'
require_relative 'my_devices.rb'

default_profile = {
    complex_modifications: {
        rules: my_complex_rules
    },
    devices: my_devices,
    name: 'Default profile',
}

config = {
    profiles: [
        default_profile
    ],
}

require 'json'
puts JSON.pretty_generate(config, {:indent => "    "})
