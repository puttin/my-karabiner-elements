def my_devices
    require 'yaml'
    YAML.load(File.read('my_devices.yml'))
end

if __FILE__ == $0
    require 'json'
    puts JSON.pretty_generate(my_devices, {:indent => "    "})
end
