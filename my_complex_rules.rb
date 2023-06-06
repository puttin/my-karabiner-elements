require_relative "karabiner_ext.rb"
KE = KarabinerEXT

using KE
extend KE

def my_complex_rules
    rules = []

    rules << rule("Post F20 if caps is pressed alone, Meta otherwise", manipulators: caps_f20_alone_meta_otherwise)
    rules << rule("Meta + QWE to Music Control", manipulators: meta_qwe_music_control)
    rules << rule("Meta + ASD to Volume Control", manipulators: meta_asd_volume_control)
    # for RGB75
    rules << rule("Switch Command And Option if RGB75", manipulators: switch_RGB75_left_cmd_opt)
    rules << rule("Arrows to Modifiers if not pressed alone and RGB75", manipulators: arrows_modifier_if_not_alone_and_RGB75)
    # for Pure Pro, toggle off:123;on:4
    rules << rule("Switch Command And Option if Pure Pro", manipulators: switch_PurePro_left_cmd_opt)
    rules << rule("` to ESC when no modifier if Pure Pro", manipulators: grave_accent_esc_if_PurePro, comment: 'use simple modifications to modify escape to grave_accent_and_tilde first')
    rules << rule("Del to ` if Pure Pro", manipulators: delete_forward_grave_accent_if_PurePro)
    # for Q1 Pro
    rules << rule("Power to ⌃⌘Q (Lock Screen) if Q1 Pro", manipulators:power_ctrl_cmd_q.if?(if_Q1Pro))
    # for trackball
    rules << rule("Change control + mouse motion to scroll wheel", manipulators: ctrl_mouse_scroll_wheel, available_since: "12.3.0")
    rules << rule("Change button4 + mouse motion to scroll wheel if pressed alone", manipulators: pointing_button_mouse_scroll_wheel_if_alone, available_since: "12.3.0")

    rules
end

def caps_f20_alone_meta_otherwise
    m = manipulator
    m.from_key("caps_lock", any_modifiers)
    m.to_virtual_modifier "meta"
    m.to_if_alone "f20"
end

def meta_qwe_music_control
    q = manipulator.from_key("q").to_key("rewind")
    w = manipulator.from_key("w").to_key("play_or_pause")
    e = manipulator.from_key("e").to_key("fastforward")
    [q, w, e].if? virtual_modifier_is "meta"
end

def meta_asd_volume_control
    opt_shift = modifiers([],["option","shift"])
    a = manipulator.from_key("a").to_key("mute")
    s = manipulator.from_key("s", opt_shift).to_key("volume_decrement")
    d = manipulator.from_key("d", opt_shift).to_key("volume_increment")
    [a, s, d].if? virtual_modifier_is "meta"
end

def switch_left_cmd_opt
    switch = []
    switch << manipulator.from_key("left_option", any_modifiers).to_key("left_command")
    switch << manipulator.from_key("left_command", any_modifiers).to_key("left_option")
    switch
end

def grave_accent_esc_no_modifiers
    m = manipulator.from_key("grave_accent_and_tilde").to_key("escape")
    m
end

def power_ctrl_cmd_q
    manipulator.from_key("power").to_key("q", modifiers: ["control", "command"])
end

def key_modifier_if_not_alone(from:,modifier:)
    m = manipulator.from_key(from, any_modifiers)
    m.to_key(modifier, lazy: true)
    m.to_if_alone from
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

RGB75_ID = device_identifier(vendor_id: 1155, product_id: 20518, desc: "RGB75")
PurePro_ID = device_identifier(vendor_id: 3897, product_id: 1649, desc: "KBT Pure Pro")
Q1Pro_ID = device_identifier(vendor_id: 13364, product_id: 1552, desc: "Keychron Q1 Pro")

def if_RGB75
    device_if(RGB75_ID)
end

def if_PurePro
    device_if(PurePro_ID)
end

def if_Q1Pro
    device_if(Q1Pro_ID)
end

def switch_RGB75_left_cmd_opt
    switch_left_cmd_opt.if? if_RGB75
end

def switch_PurePro_left_cmd_opt
    switch_left_cmd_opt.if? if_PurePro
end

def grave_accent_esc_if_PurePro
    grave_accent_esc_no_modifiers.if? if_PurePro
end

def delete_forward_grave_accent_if_PurePro
    m = manipulator.from_key("delete_forward").to_key("grave_accent_and_tilde")
    m.if? if_PurePro
end

def arrows_modifier_if_not_alone_and_RGB75
    arrows_modifier_if_not_alone.if? if_RGB75
end

# from https://github.com/pqrs-org/KE-complex_modifications/blob/master/src/json/mouse_motion_to_scroll.json.rb
def ctrl_mouse_scroll_wheel
    ctrl = modifiers(["control"], nil)
    m = manipulator("mouse_motion_to_scroll").from_modifiers(ctrl)
    m
end

def pointing_button_mouse_scroll_wheel_if_alone(button = "button4")
    key = 'enable_mouse_motion_to_scroll'

    from = {pointing_button: button, modifiers: any_modifiers}
    variable = manipulator.from(from)
    variable.to_if_alone({pointing_button: button})
    variable.to_virtual_modifier(key)

    m = manipulator("mouse_motion_to_scroll").from_modifiers(any_modifiers)
    m.if? virtual_modifier_is key

    [variable, m]
end

if __FILE__ == $0
    require "json"
    puts JSON.pretty_generate(my_complex_rules, {:indent => "    "})
end
