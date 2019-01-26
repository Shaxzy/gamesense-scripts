local globals_realtime = globals.realtime
local globals_curltime = globals.curltime
local globals_frametime = globals.frametime
local globals_absolute_frametime = globals.absoluteframetime
local globals_maxplayers = globals.maxplayers
local globals_tickcount = globals.tickcount
local globals_tickinterval = globals.tickinterval
local globals_mapname = globals.mapname

local client_set_event_callback = client.set_event_callback
local client_console_log = client.log
local client_console_cmd = client.exec
local client_userid_to_entindex = client.userid_to_entindex
local client_get_cvar = client.get_cvar
local client_draw_debug_text = client.draw_debug_text
local client_draw_hitboxes = client.draw_hitboxes
local client_random_int = client.random_int
local client_random_float = client.random_float
local client_draw_text = client.draw_text
local client_draw_rectangle = client.draw_rectangle
local client_draw_line = client.draw_line
local client_draw_gradient = client.draw_gradient
local client_draw_cricle = client.draw_circle
local client_draw_circle_outline = client.draW_circle_outline
local client_world_to_screen = client.world_to_screen
local client_screen_size = client.screen_size
local client_visible = client.visible
local client_delay_call = client.delay_call
local client_latency = client.latency
local client_camera_angles = client.camera_angles

local entity_get_local_player = entity.get_local_player
local entity_get_all = entity.get_all
local entity_get_players = entity.get_players
local entity_get_classname = entity.get_classname
local entity_set_prop = entity.set_prop
local entity_get_prop = entity.get_prop
local entity_is_enemy = entity.is_enemy
local entity_get_player_name = entity.get_player_name
local entity_get_player_weapon = entity.get_player_weapon
local entity_hitbox_position = entity.hitbox_position

local ui_new_checkbox = ui.new_checkbox
local ui_new_slider = ui.new_slider
local ui_new_combobox = ui.new_combobox
local ui_new_multiselect = ui.new_multiselect
local ui_new_hotkey = ui.new_hotkey
local ui_new_button = ui.new_button
local ui_new_color_picker = ui.new_color_picker
local ui_reference = ui.reference
local ui_set = ui.set
local ui_get = ui.get
local ui_set_callback = ui.set_callback
local ui_set_visible = ui.set_visible

local math_floor = math.floor
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove
local table_size = table.getn
local string_format = string.format

--[[

    Author: NmChris
    Version: 1.01
    Functionality: Disables anti-aim on knife

    Change log:
        1.01:
            - Fixed bug causing spam to stop working
            
    To-Do:
        N/A
]]--

-- Menu
local menu = {

    callout = ui_new_checkbox("MISC", "Miscellaneous", "Automatic call out"),
    callout_mode = ui_new_combobox("MISC", "Miscellaneous", "Call out mode", "Death", "Spam"),
    callout_chat = ui_new_combobox("MISC", "Miscellaneous", "Call out chat", "Global", "Team")

}

-- Variables
local variable = {

    spamming = false

}

local function handle_menu()


    if ui_get(menu.callout) == true then

        ui_set_visible(menu.callout_mode, true)
        ui_set_visible(menu.callout_chat, true)

    else

        ui_set_visible(menu.callout_mode, false)
        ui_set_visible(menu.callout_chat, false)

    end

end

handle_menu()
ui_set_callback(menu.callout, handle_menu)

local function get_weapon(entindex)

    local weapon_id = entity_get_player_weapon(entindex)

    if weapon_id == nil then

        return

    end

    local weapon_item_index = entity_get_prop(weapon_id, "m_iItemDefinitionIndex")
    local current_weapon = nil

    if weapon_item_index > 200000 then

        weapon_item_index = weapon_item_index % 65536

    end

    local weapons = {

        [1] = "Desert Eagle",
        [2] = "Dual Berettas",
        [3] = "Five-SeveN",
        [4] = "Glock-18",
        [7] = "AK-47",
        [8] = "AUG",
        [9] = "AWP",
        [10] = "FAMAS",
        [11] = "G3SG1",
        [13] = "Galil AR",
        [14] = "M249",
        [16] = "M4A4",
        [17] = "MAC-10",
        [19] = "P90",
        [24] = "UMP-45",
        [25] = "XM1014",
        [26] = "PP-Bizon",
        [27] = "MAG-7",
        [28] = "Negev",
        [29] = "Sawed-Off",
        [30] = "Tec-9",
        [32] = "P2000",
        [33] = "MP7",
        [34] = "MP9",
        [35] = "Nova",
        [36] = "P250",
        [38] = "SCAR-20",
        [39] = "SG 553",
        [40] = "SSG 08",
        [41] = "Knife",
        [42] = "Knife",
        [43] = "Flashbang",
        [44] = "Grenade",
        [45] = "Smoke",
        [46] = "Molotov",
        [47] = "Decoy",
        [48] = "Incendiary",
        [49] = "Bomb",
        [59] = "Knife",
        [60] = "M4A1-S",
        [61] = "USP-S",
        [63] = "CZ75-Auto",
        [64] = "R8 Revolver",
        [500] = "Bayonet",
        [505] = "Flip Knife",
        [506] = "Gut Knife",
        [507] = "Karambit",
        [508] = "M9 Bayonet",
        [509] = "Huntsman Knife",
        [512] = "Falchion Knife",
        [514] = "Bowie Knife",
        [516] = "Shadow Daggers"

    }

    for weapon_index, weapon_name in pairs(weapons) do

        if weapon_index == weapon_item_index then

            current_weapon = weapon_name

        end

    end

    client_console_log("Returning weapon")
    return current_weapon

end

local function callout(entindex, index, size, mode, chat)

    if entindex == nil then

        return

    end

    local enemy_name = entity_get_player_name(entindex)
    local enemy_location = entity_get_prop(entindex, "m_szLastPlaceName")
    local enemy_health = entity_get_prop(entindex, "m_iHealth")
    local enemy_weapon = get_weapon(entindex)

    if enemy_health == 0 then

        if index == size then

            variable.spamming = false
            return

        else

            return

        end

    end

    if enemy_name == nil or enemy_health == nil or enemy_weapon == nil then

        client_console_log("Nil check failed")
        return

    end

    if enemy_location == "" then

        enemy_location = "an unknown location"

    end

    if mode == "Death" then

        if chat == "Global" then

            client_console_cmd("say ", enemy_name, " is at ", enemy_location, " with ", enemy_health, "HP using a ", enemy_weapon, ".")

        elseif chat == "Team" then

            client_console_cmd("say_team ", enemy_name, " is at ", enemy_location, " with ", enemy_health, "HP using a ", enemy_weapon, ".")

        end

    elseif mode == "Spam" then

        if chat == "Global" then

            client_console_cmd("say ", enemy_name, " is at ", enemy_location, " with ", enemy_health, "HP using a ", enemy_weapon, ".")

        elseif chat == "Team" then

            client_console_cmd("say_team ", enemy_name, " is at ", enemy_location, " with ", enemy_health, "HP using a ", enemy_weapon, ".")

        end

        if index == size then

            variable.spamming = false

        end

    end

end

local function on_player_death(e)

    if ui_get(menu.callout) == false or ui_get(menu.callout_mode) ~= "Death" then

        return

    end

    local enemy_players = entity_get_players(true)
    local victimEntIndex = client_userid_to_entindex(e.userid)
    
    if victimEntIndex == entity_get_local_player() then

        for i = 1, #enemy_players do

            client_delay_call(0.7 * i, callout, enemy_players[i], i, #enemy_players, "Death", ui_get(menu.callout_chat))

        end

    end

end

local function on_paint(ctx)

    if ui_get(menu.callout) == false or ui_get(menu.callout_mode) ~= "Spam" then

        return

    end

    local enemy_players = entity_get_players(true)

    if #enemy_players == 0 then

        return

    end

    if variable.spamming == false then

        variable.spamming = true
        client_console_log("Spamming")

        for i = 1, #enemy_players do

            client_delay_call(0.7 * i, callout, enemy_players[i], i, #enemy_players, "Spam", ui_get(menu.callout_chat))

        end

    end

end

client_set_event_callback("paint", on_paint)
client_set_event_callback("player_death", on_player_death)