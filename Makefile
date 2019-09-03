all: dependency gen

gen:
	ruby my_profiles.rb

gen_complex_rules:
	ruby my_complex_rules.rb

gen_devices:
	ruby my_devices.rb

dependency:
	sh fetch-karabiner-rb.sh

clean:
	rm karabiner.rb
