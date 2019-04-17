all: dependency gen

gen:
	ruby my_complex_rules.rb

dependency:
	sh fetch-karabiner-rb.sh

clean:
	rm karabiner.rb
