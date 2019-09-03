require_relative 'karabiner.rb'

module Karabiner
    def self.rule(manipulators:, desc:)
        h = {
            "description" => desc,
            "manipulators" => manipulators,
        }
    end

    def self.manipulator(type = "basic")
        h = {
            "type" => type,
        }
    end

    def self.device_identifier(vendor_id:, product_id:, desc: nil)
        h = {
            "vendor_id" => vendor_id,
            "product_id" => product_id,
        }
        unless desc.to_s.empty?
            h["description"] = desc
        end
        h
    end

    def self.device_if(*_identifiers)
        identifiers = _identifiers.flatten
        {
            "type" => "device_if",
            "identifiers" => identifiers,
        }
    end

    def self.any_modifiers
        from_modifiers(nil, ["any"])
    end
end

module KarabinerEXT
    def method_missing(m, *args, &block)
        unless Karabiner.respond_to?(m)
            super
        end
        Karabiner.send(m, *args, &block)
    end

    refine Hash do
        # method_missing won't work here https://bugs.ruby-lang.org/issues/13129

        def from_key(code, modifiers = nil)
            h = {
                "key_code" => code,
            }
            h['modifiers'] = modifiers unless modifiers.nil?

            from(h)
        end

        def from(from)
            set("from",from)
        end

        def to_key(code)
            h = { "key_code" => code }
            to(h)
        end

        def to(to)
            set("to",to)
        end

        def set(key,value)
            self[key] = value
            self
        end
    end
end
