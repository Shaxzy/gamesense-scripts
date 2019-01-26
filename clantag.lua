local globals_realtime = globals.realtime
local globals_curtime = globals.curtime
local globals_frametime = globals.frametime
local globals_absolute_frametime = globals.absoluteframetime
local globals_maxplayers = globals.maxplayers
local globals_tickcount = globals.tickcount
local globals_tickinterval = globals.tickinterval
local globals_mapname = globals.mapname

local client_set_event_callback = client.set_event_callback
local client_console_log = client.log
local client_color_log = client.color_log
local client_console_cmd = client.exec
local client_userid_to_entindex = client.userid_to_entindex
local client_get_cvar = client.get_cvar
local client_set_cvar = client.set_cvar
local client_draw_debug_text = client.draw_debug_text
local client_draw_hitboxes = client.draw_hitboxes
local client_draw_indicator = client.draw_indicator
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
local client_trace_line = client.trace_line
local client_eye_position = client.eye_position
local client_set_clan_tag = client.set_clan_tag
local client_system_time = client.system_time

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
local entity_get_steam64 = entity.get_steam64
local entity_get_bounding_box = entity.get_bounding_box
local entity_is_alive = entity.is_alive
local entity_is_dormant = entity.is_dormant

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
local ui_is_menu_open = ui.is_menu_open

local math_floor = math.floor
local math_random = math.random
local math_sqrt = math.sqrt
local table_insert = table.insert
local table_remove = table.remove
local table_size = table.getn
local table_sort = table.sort
local string_format = string.format
local string_length = string.len
local string_reverse = string.reverse
local string_sub = string.sub

local clantags = {

    ["Skeet"] = "skeet.cc",
    ["Crying?"] = "Is that a tear I see?"

}

local function getMenuItems()

    local names = {}

    for k, v in pairs(clantags) do

        names[#names + 1] = k

    end

    table_sort(names)
    table_insert(names, 1, "Disabled")
    table_insert(names, "Custom")

    return names

end

local menu = {

    enabled = ui_new_checkbox("MISC", "Miscellaneous", "Clantag changer"),
    clantags = ui_new_combobox("MISC", "Miscellaneous", "Clan tags", getMenuItems()),
    animated = ui_new_checkbox("MISC", "Miscellaneous", "Animated tag"),
    style = ui_new_combobox("MISC", "Miscellaneous", "Animation style", "Default", "Reverse"),
    speed = ui_new_slider("MISC", "Miscellaneous", "Animation speed", 0, 100, 25, true, "%", 1)

}

local function handle_menu()

    if ui_get(menu.enabled) then

        ui_set_visible(menu.clantags, true)
        ui_set_visible(menu.animated, true)

        if ui_get(menu.animated) then

            ui_set_visible(menu.style, true)
            ui_set_visible(menu.speed, true)

        else

            ui_set_visible(menu.style, false)
            ui_set_visible(menu.speed, false)

        end

    else

        ui_set_visible(menu.clantags, false)
        ui_set_visible(menu.animated, false)
        ui_set_visible(menu.style, false)
        ui_set_visible(menu.speed, false)
    
    end

end

handle_menu()
ui_set_callback(menu.enabled, handle_menu)
ui_set_callback(menu.animated, handle_menu)

local bSendPacket = false

client_set_event_callback("run_command", function(e)

    if e.chokedcommands == 0 then

        bSendPacket = false

    else

        bSendPacket = true

    end

end)

local sClanTag = nil
local iTagLength = nil
local bStaticSet = false

local function handleClanTags()

    if not ui_get(menu.enabled) or ui_get(menu.clantags) == "Disabled" then

        return

    end

    if ui_get(menu.clantags) == "Custom" then

        if sClanTag ~= client_get_cvar("r_eyegloss") then

            sClanTag = client_get_cvar("r_eyegloss")
            bStaticSet = false

        end
        

    else

        if sClanTag ~= clantags[ui_get(menu.clantags)] then

            sClanTag = clantags[ui_get(menu.clantags)]
            bStaticSet = false

        end
        
    end

    if string_length(sClanTag) > 16 then

        iTagLength = 16
        sClanTag = string_sub(sClanTag, 1, 16)
    
    else


        iTagLength = string_length(sClanTag)

    end

end

handleClanTags()
ui_set_callback(menu.clantags, handleClanTags)

local bShouldReverse = false
local bUseReverse = false
local iCurrentIndex = nil
local iLastIndex = nil

client_set_event_callback("paint", function(ctx)

    if not ui_get(menu.enabled) or ui_get(menu.clantags) == "Disabled" then

        return

    end

    handleClanTags()

    if not ui_get(menu.animated) then

        if not bStaticSet then

            client_set_clan_tag(sClanTag)
            bStaticSet = true

        end
        
        return

    end

    if not entity_is_alive(entity_get_local_player()) then

        bSendPacket = false

    end

    iCurrentIndex = math_floor((globals_curtime() * (ui_get(menu.speed) / 10)) % iTagLength)  

    if iCurrentIndex + 1 == iTagLength then

       if not bShouldReverse then

            bShouldReverse = true
            bUseReverse = not bUseReverse

       end

    else

        if bShouldReverse then

            bShouldReverse = false

        end

    end

     if iLastIndex == nil then

        iLastIndex = iCurrentIndex

    end

    if iCurrentIndex == iLastIndex then

        return

    end

    if bSendPacket then

        return

    end

    if ui_get(menu.style) == "Default" then

        client_set_clan_tag(string_sub(sClanTag, 1, iCurrentIndex + 1))

    elseif ui_get(menu.style) == "Reverse" then

        if iCurrentIndex + 1 == iTagLength then

            iCurrentIndex = 0

        end

        if bUseReverse then
            
            client_set_clan_tag(string_sub(sClanTag, 1, iTagLength - iCurrentIndex))

        else

            client_set_clan_tag(string_sub(sClanTag, 1, iCurrentIndex + 1))
            
        end

    end

    iLastIndex = iCurrentIndex

end)