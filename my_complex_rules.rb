require_relative "karabiner_ext.rb"
KE = Karabiner

def main
    rules = {}

    rules["Post F20 if caps is pressed alone, FN otherwise"] = caps_f20_fn_lazy
    rules["FN + QWE to Music Control"] = fn_qwe_music_control
    rules["FN + ASD to Volume Control"] = fn_asd_volume_control
    rules["Switch Command And Option if RGB75"] = switch_RGB75_left_cmd_opt
    rules["Switch Command And Option if Pure Pro"] = switch_PurePro_left_cmd_opt
    rules["` to ESC when no modifier if Pure Pro"] = grave_accent_esc_if_PurePro
    rules["Del to ` if Pure Pro"] = delete_forward_grave_accent_if_PurePro
    rules["Arrows to Modifiers if not pressed alone and RGB75"] = arrows_modifier_if_not_alone_and_RGB75

    gen_rules(rules)
end

def caps_f20_fn_lazy
    m = KE.manipulator
    m.KE_from_key_(code: "caps_lock", modifiers: KE.from_modifiers(nil, ["any"]))
    m["to"] = [{ "key_code": "fn", "lazy": true, }]
    m["to_if_alone"] = [{ "key_code": "f20" }]
    [m]
end

def fn_qwe_music_control
    q = KE.manipulator
    q.KE_from_key_(code: "q", modifiers: KE.from_modifiers(["fn"],nil))
    q.KE_to_key_(code:"rewind")
    w = KE.manipulator
    w.KE_from_key_(code: "w", modifiers: KE.from_modifiers(["fn"],nil))
    w.KE_to_key_(code:"play_or_pause")
    e = KE.manipulator
    e.KE_from_key_(code: "e", modifiers: KE.from_modifiers(["fn"],nil))
    e.KE_to_key_(code:"fastforward")
    [q, w, e]
end

def fn_asd_volume_control
    a = KE.manipulator
    a.KE_from_key_(code: "a", modifiers: KE.from_modifiers(["fn"],nil))
    a.KE_to_key_(code:"mute")
    s = KE.manipulator
    s.KE_from_key_(code: "s", modifiers: KE.from_modifiers(["fn"],["option","shift"]))
    s.KE_to_key_(code:"volume_decrement")
    d = KE.manipulator
    d.KE_from_key_(code: "d", modifiers: KE.from_modifiers(["fn"],["option","shift"]))
    d.KE_to_key_(code:"volume_increment")
    [a, s, d]
end

def switch_left_cmd_opt
    switch = []
    switch << KE.manipulator.KE_from_key_(code: "left_option", modifiers: KE.from_modifiers(nil, ["any"])).KE_to_key_(code:"left_command")
    switch << KE.manipulator.KE_from_key_(code: "left_command", modifiers: KE.from_modifiers(nil, ["any"])).KE_to_key_(code:"left_option")
    switch
end

def grave_accent_esc_no_modifiers
    m = KE.manipulator.KE_from_key_(code: "grave_accent_and_tilde").KE_to_key_(code:"escape")
    [m]
end

def key_modifier_if_not_alone(from:,modifier:)
    m = KE.manipulator.KE_from_key_(code: from, modifiers: KE.from_modifiers(nil, ["any"]))
    m["to"] = [{ "key_code": modifier, "lazy": true, }]
    m["to_if_alone"] = [{ "key_code": from }]
    m["to_if_held_down"] = [{ "key_code": from }]
    m
end

def arrows_modifier_if_not_alone
    up = key_modifier_if_not_alone(from:"up_arrow", modifier: "right_shift")
    left = key_modifier_if_not_alone(from:"left_arrow", modifier: "right_command")
    down = key_modifier_if_not_alone(from:"down_arrow", modifier: "right_option")
    right = key_modifier_if_not_alone(from:"right_arrow", modifier: "right_control")
    [up, left, down, right]
end

def update_conditions(manipulators, conditions)
    manipulators.each do |m|
        m["conditions"] = conditions
    end
    manipulators
end

RGB75_ID = KE.device_identifier(vendor_id: 1155, product_id: 20518, desc: "RGB75")
PurePro_ID = KE.device_identifier(vendor_id: 3897, product_id: 1649, desc: "KBT Pure Pro")

def if_RGB75
    KE.device_if(RGB75_ID)
end

def if_PurePro
    KE.device_if(PurePro_ID)
end

def switch_RGB75_left_cmd_opt
    update_conditions(switch_left_cmd_opt, [if_RGB75])
end

def switch_PurePro_left_cmd_opt
    update_conditions(switch_left_cmd_opt, [if_PurePro])
end

def grave_accent_esc_if_PurePro
    update_conditions(grave_accent_esc_no_modifiers, [if_PurePro])
end

def delete_forward_grave_accent_if_PurePro
    m = KE.manipulator.KE_from_key_(code: "delete_forward").KE_to_key_(code:"grave_accent_and_tilde")
    update_conditions([m], [if_PurePro])
end

def arrows_modifier_if_not_alone_and_RGB75
    update_conditions(arrows_modifier_if_not_alone, [if_RGB75])
end

def gen_rules(rules)
    result = []
    rules.each do |desc, manipulators|
        result << KE.rule(desc: desc, manipulators: manipulators)
    end
    result
end

require "json"
puts JSON.pretty_generate(main, {:indent => "    "})
