require_relative 'karabiner.rb'

module Karabiner
    def self.rule(manipulators:, desc:)
        h = {
            "description" => desc,
            "manipulators" => manipulators,
        }
    end

    def self.manipulator
        h = {
            "type" => "basic",
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

class Hash
    def KE_from(from)
        self["from"] = from
        self
    end

    def KE_from_key_(code:, modifiers: nil)
        from = {
            "key_code" => code,
        }
        from['modifiers'] = modifiers unless modifiers.nil?
        KE_from(from)
    end

    def KE_to(to)
        self["to"] = to
        self
    end

    def KE_to_key_(code:)
        to = [{ "key_code" => code }]
        KE_to(to)
    end
end
