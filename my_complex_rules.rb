require_relative "karabiner_ext.rb"
KE = KarabinerEXT

using KE
extend KE

def main
    rules = []

    rules << rule("Post F20 if caps is pressed alone, FN otherwise", manipulators: caps_f20_fn_lazy)
    rules << rule("FN + QWE to Music Control", manipulators: fn_qwe_music_control)
    rules << rule("FN + ASD to Volume Control", manipulators: fn_asd_volume_control)
    rules << rule("Switch Command And Option if RGB75", manipulators: switch_RGB75_left_cmd_opt)
    rules << rule("Switch Command And Option if Pure Pro", manipulators: switch_PurePro_left_cmd_opt)
    rules << rule("` to ESC when no modifier if Pure Pro", manipulators: grave_accent_esc_if_PurePro)
    rules << rule("Del to ` if Pure Pro", manipulators: delete_forward_grave_accent_if_PurePro)
    rules << rule("Arrows to Modifiers if not pressed alone and RGB75", manipulators: arrows_modifier_if_not_alone_and_RGB75)
    rules << rule("Change control + mouse motion to scroll wheel", manipulators: ctrl_mouse_scroll_wheel, available_since: "12.3.0")

    rules
end

def caps_f20_fn_lazy
    m = manipulator
    m.from_key("caps_lock", any_modifiers)
    m["to"] = { "key_code": "fn", "lazy": true, }
    m["to_if_alone"] = { "key_code": "f20" }
    [m]
end

def fn_qwe_music_control
    fn = modifiers(["fn"],nil)
    q = manipulator.from_key("q", fn).to_key("rewind")
    w = manipulator.from_key("w", fn).to_key("play_or_pause")
    e = manipulator.from_key("e", fn).to_key("fastforward")
    [q, w, e]
end

def fn_asd_volume_control
    fn = modifiers(["fn"],nil)
    fn_opt_shift = modifiers(["fn"],["option","shift"])
    a = manipulator.from_key("a", fn).to_key("mute")
    s = manipulator.from_key("s", fn_opt_shift).to_key("volume_decrement")
    d = manipulator.from_key("d", fn_opt_shift).to_key("volume_increment")
    [a, s, d]
end

def switch_left_cmd_opt
    switch = []
    switch << manipulator.from_key("left_option", any_modifiers).to_key("left_command")
    switch << manipulator.from_key("left_command", any_modifiers).to_key("left_option")
    switch
end

def grave_accent_esc_no_modifiers
    m = manipulator.from_key("grave_accent_and_tilde").to_key("escape")
    [m]
end

def key_modifier_if_not_alone(from:,modifier:)
    m = manipulator.from_key(from, any_modifiers)
    m["to"] = { "key_code": modifier, "lazy": true, }
    m["to_if_alone"] = { "key_code": from }
    m["to_if_held_down"] = { "key_code": from }
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

RGB75_ID = device_identifier(vendor_id: 1155, product_id: 20518, desc: "RGB75")
PurePro_ID = device_identifier(vendor_id: 3897, product_id: 1649, desc: "KBT Pure Pro")

def if_RGB75
    device_if(RGB75_ID)
end

def if_PurePro
    device_if(PurePro_ID)
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
    m = manipulator.from_key("delete_forward").to_key("grave_accent_and_tilde")
    update_conditions([m], [if_PurePro])
end

def arrows_modifier_if_not_alone_and_RGB75
    update_conditions(arrows_modifier_if_not_alone, [if_RGB75])
end

# from https://github.com/pqrs-org/KE-complex_modifications/blob/master/src/json/mouse_motion_to_scroll.json.rb
def ctrl_mouse_scroll_wheel
    ctrl = modifiers(["control"], nil)
    m = manipulator("mouse_motion_to_scroll").from_modifiers(ctrl)
    [m]
end

require "json"
puts JSON.pretty_generate(main, {:indent => "    "})
