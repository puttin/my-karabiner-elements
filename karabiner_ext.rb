require_relative 'karabiner.rb'

module Karabiner
    def self.rule(desc, manipulators:, **extra)
        h = {
            "description" => desc,
            "manipulators" => manipulators,
        }
        if extra.is_a?(Hash)
            h.merge!(extra)
        end
        h
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

    class << self
        alias modifiers from_modifiers
    end
    def self.any_modifiers
        modifiers(nil, ["any"])
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

        def from_modifiers(modifiers)
            h = {
                'modifiers' => modifiers
            }

            from(h)
        end

        def from(from)
            set("from",from)
        end

        def to_key(code, **extra)
            h = { "key_code" => code }
            if extra.is_a?(Hash)
                h.merge!(extra)
            end
            to(h)
        end

        def to(to)
            set("to",to)
        end

        def set(key,value)
            self[key] = value
            self
        end

        def conditions(conditions)
            v = nil
            if conditions.is_a?(Array)
                v = conditions
            else
                v = [conditions]
            end
            set("conditions", v)
        end

        def to_if_alone(to_if_alone)
            v = nil
            if to_if_alone.is_a?(Hash)
                v = to_if_alone
            elsif to_if_alone.is_a?(String)
                v = {key_code: to_if_alone}
            else
                raise "#{__method__} arg invalid"
            end
            set("to_if_alone", v)
        end

        def virtual_modifier(key)
            to([Karabiner.set_variable(key, 1)])
            set("to_after_key_up", [Karabiner.set_variable(key, 0)])
        end
    end
end
