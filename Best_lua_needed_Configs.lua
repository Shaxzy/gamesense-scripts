local globals_realtime = globals.realtime
local globals_curtime = globals.curtime
local globals_frametime = globals.frametime
local globals_maxplayers = globals.maxplayers
local globals_tickcount = globals.tickcount
local globals_tickinterval = globals.tickinterval
local globals_mapname = globals.mapname
local client_set_event_callback = client.set_event_callback
local client_log = client.log
local client_exec = client.exec
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
local client_draw_circle = client.draw_circle
local client_draw_circle_outline = client.draw_circle_outline
local client_world_to_screen = client.world_to_screen
local client_screen_size = client.screen_size
local client_visible = client.visible
local client_delay_call = client.delay_call
local client_latency = client.latency
local client_camera_angles = client.camera_angles
local client_eye_position = client.eye_position
local client_draw_indicator = client.draw_indicator
local ui_new_checkbox = ui.new_checkbox
local ui_new_slider = ui.new_slider
local ui_new_combobox = ui.new_combobox
local ui_new_multiselect = ui.new_multiselect
local ui_new_hotkey = ui.new_hotkey
local ui_new_button = ui.new_button
local ui_reference = ui.reference
local ui_set = ui.set
local ui_get = ui.get
local ui_set_callback = ui.set_callback
local ui_set_visible = ui.set_visible
local ui_is_menu_open = ui.is_menu_open
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

local table_insert, table_remove = table.insert, table.remove
local math_sqrt, math_abs, math_floor, math_ceil, math_max, math_min = math.sqrt, math.abs, math.floor, math.ceil, math.max, math.min
local to_number = tonumber
local bit_band = bit.band

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math_floor(num * mult + 0.5) / mult
end

--//////////////////////////////////////////////
--// references

local ref_amount = ui_reference("aa", "fake lag", "Amount")
local ref_var = ui_reference("aa", "fake lag", "Variance")
local ref_limit = ui_reference("aa", "fake lag", "Limit")
local ref_shoot = ui_reference("aa", "fake lag", "Fake lag while shooting")
local ref_bhop = ui_reference("aa", "fake lag", "Reset on bunny hop")
local ref_standstill = ui_reference("aa", "fake lag", "Reset on standstill")

local debug = false

if debug == false then
    ui_set_visible(ref_amount, false)
    ui_set_visible(ref_var, false)
    ui_set_visible(ref_limit, false)
    ui_set_visible(ref_shoot, false)
    ui_set_visible(ref_bhop, false)
    ui_set_visible(ref_standstill, false)
else
    ui_set_visible(ref_amount, true)
    ui_set_visible(ref_var, true)
    ui_set_visible(ref_limit, true)
    ui_set_visible(ref_shoot, true)
    ui_set_visible(ref_bhop, true)
    ui_set_visible(ref_standstill, true)
end

--//////////////////////////////////////////////
--// ui definitions/callbacks

local new_amount = ui_new_combobox("AA", "Fake lag", "Amount", {"Dynamic", "Maximum", "Fluctuate", "Jitter", "Dynamic Jitter", "Dynamic Minimum", "Minimum", "Step", "Min Max"})
local new_var = ui_new_slider("AA", "Fake lag", "Variance", 0, 100, 0, true, "%")
local new_limit = ui_new_slider("AA", "Fake lag", "Limit", 1, 14, 1, true)
local new_step_increment = ui_new_slider("aa", "fake lag", "Step increment", 1, 6, 2, true)
ui_set_visible(new_step_increment, false)
local new_shoot = ui_new_combobox("AA", "Fake lag", "Fake lag while shooting", {"-", "Always on", "On first shot", "Modulo"})
local new_modulo_slider = ui_new_slider("aa", "fake lag", "Modulo", 2, 4, 2, true)
ui_set_visible(new_modulo_slider, false)
local new_bhop = ui_new_checkbox("AA", "Fake lag", "Reset on bunny hop")
local new_standstill = ui_new_checkbox("aa", "fake lag", "Reset on standstill")

local function handle_new_amount(this)
    local v = ui_get(this)
    if v == "Jitter" or v == "Dynamic Jitter" or v == "Dynamic Minimum" or v == "Minimum" or v == "Step" or v == "Min Max" then
        ui_set(ref_amount, "Maximum")
        ui_set(ref_var, 0)
    else
        ui_set(ref_amount, v)
        ui_set(ref_var, ui_get(new_var))
        ui_set(ref_limit, ui_get(new_limit))
    end

    if v ~= "Step" then
        ui_set_visible(new_step_increment, false)
    end
end
ui_set_callback(new_amount, handle_new_amount)

local step_counter = 2
local function handle_new_var(this)
    local v = ui_get(this)
    local amt = ui_get(new_amount)
    if amt == "Jitter" or amt == "Dynamic Jitter" or amt == "Dynamic Minimum" or amt == "Minimum" or amt == "Step" or amt == "Min Max" then
        ui_set(ref_var, 0)
    elseif amt == "Step" then
        if v > 0 and ui_get(new_limit) > 1 then
            step_counter = math_ceil(ui_get(new_limit) * (v * 0.01))
        else
            step_counter = 2
        end
        ui_set(ref_var, 0)
    else
        ui_set(ref_var, v)
    end
end
ui_set_callback(new_var, handle_new_var)

local function handle_new_limit(this)
    local v = ui_get(this)
    local amt = ui_get(new_amount)
    if amt == "Jitter" or amt == "Dynamic Jitter" or amt == "Dynamic Minimum" or amt == "Minimum" or amt == "Step" or amt == "Min Max" then
        return -- lets handle our new fakelag in paint
    else
        ui_set(ref_limit, v)
    end
end
ui_set_callback(new_limit, handle_new_limit)

local function handle_new_shoot(this)
    local v = ui_get(this)

    if v == "-" then
        ui_set(ref_shoot, false)
    elseif v == "Always on" then
        ui_set(ref_shoot, true)
    elseif v == "On first shot" then
        ui_set(ref_shoot, false)
    elseif v == "Modulo" then
        ui_set(ref_shoot, false)
        ui_set_visible(new_modulo_slider, true)
    end

    if v ~= "Modulo" then
        ui_set_visible(new_modulo_slider, false)
    end
end
ui_set_callback(new_shoot, handle_new_shoot)

local function handle_new_bhop(this)
    local v = ui_get(this)
    ui_set(ref_bhop, v)
end
ui_set_callback(new_bhop, handle_new_bhop)

local function handle_new_standstill(this)
    local v = ui_get(this)
    ui_set(ref_standstill, v)
end
ui_set_callback(new_standstill, handle_new_standstill)

--//////////////////////////////////////////////
--// event callbacks

local choked_cmds = 0
local jitter_flip = false
local dynamicjitter_flip = false
local dynamicminimum_flip = false
local minmax_flip = false

local weapon_fired = false
local weapon_fired_times = 0
local dist_per_tick = 0
local function handle_run_command(e)
    local lp = entity_get_local_player()
    local lp_vx, lp_vy, lp_vz = entity_get_prop(lp, "m_vecVelocity")
    if not lp_vx then client_log("lp_vx nil") return end
    local lp_3dvel = math_sqrt(lp_vx*lp_vx + lp_vy*lp_vy)
    local curtime = globals_curtime()
    local val_new_amount = ui_get(new_amount)
    local val_new_var = ui_get(new_var)
    local val_new_limit = ui_get(new_limit)
    local var_to_limit = math_ceil(val_new_limit * (val_new_var * 0.01))
    local val_new_shoot = ui_get(new_shoot)
    local val_limit = ui_get(ref_limit)
    local val_shoot = ui_get(ref_shoot)

    choked_cmds = e.chokedcommands

    dist_per_tick = lp_3dvel * globals_tickinterval()
    local adaptive_cmds = 14
    local minimum_cmds = 14
    if lp_3dvel ~= 0 then
        minimum_cmds = math_min(math_floor(64.0 / dist_per_tick + client_latency()), val_new_limit) - 1
        adaptive_cmds = math_min(math_ceil(64.0 / dist_per_tick + client_latency()), val_new_limit)
    end

    if val_new_amount == "Jitter" then
        if jitter_flip == false and choked_cmds == var_to_limit then
            ui_set(ref_limit, val_new_limit)
            jitter_flip = true
        elseif jitter_flip == true and choked_cmds == val_new_limit then
            if var_to_limit ~= 0 then
                ui_set(ref_limit, var_to_limit)
                jitter_flip = false
            end
        elseif val_limit ~= val_new_limit and val_limit ~= var_to_limit then
            ui_set(ref_limit, val_new_limit)
        end
    elseif val_new_amount == "Dynamic Jitter" then
            if lp_3dvel ~= 0 then
                adaptive_cmds = math_min(math_ceil(64.0 / dist_per_tick), 14)
            end

            if dynamicjitter_flip == false and choked_cmds == val_new_limit then
                ui_set(ref_limit, adaptive_cmds)
                dynamicjitter_flip = true
            elseif dynamicjitter_flip == true and choked_cmds == adaptive_cmds then
                ui_set(ref_limit, val_new_limit)
                dynamicjitter_flip = false
            elseif val_limit ~= val_new_limit and val_limit ~= adaptive_cmds then
                ui_set(ref_limit, val_new_limit)
            end
    elseif val_new_amount == "Dynamic Minimum" then
        if dynamicminimum_flip == false and choked_cmds == minimum_cmds then
            ui_set(ref_limit, adaptive_cmds)
            dynamicminimum_flip = true
        elseif dynamicminimum_flip == true and choked_cmds == adaptive_cmds then
            ui_set(ref_limit, minimum_cmds)
            dynamicminimum_flip = false
        elseif val_limit ~= minimum_cmds and val_limit ~= adaptive_cmds then
            ui_set(ref_limit, val_new_limit)
        end
    elseif val_new_amount == "Minimum" then
        if val_limit ~= minimum_cmds then
            ui_set(ref_limit, minimum_cmds)
        end
    elseif val_new_amount == "Step" then
        if choked_cmds == step_counter then
            step_counter = step_counter + ui_get(new_step_increment)
        end

        if var_to_limit ~= 0 then
            if step_counter > val_new_limit then
                step_counter = var_to_limit
            end
        else
            step_counter = 2
        end

        if val_limit ~= step_counter then
            ui_set(ref_limit, step_counter)
        end
    elseif val_new_amount == "Min Max" then
        if minmax_flip == false and choked_cmds == val_new_limit then
            ui_set(ref_limit, 2)
            minmax_flip = true
        elseif minmax_flip == true and choked_cmds == 2 then
            ui_set(ref_limit, val_new_limit)
            minmax_flip = false
        elseif val_limit ~= val_new_limit and val_limit ~= 2 then
            ui_set(ref_limit, val_new_limit)
        end
    end


    if val_new_shoot == "Always on" then
        if val_shoot ~= true then
            ui_set(ref_shoot, true)
        end
    elseif val_new_shoot == "On first shot" then
        if curtime - entity_get_prop(entity_get_player_weapon(lp), "m_fLastShotTime") >= 2 then
            ui_set(ref_shoot, true)
        else
            ui_set(ref_shoot, false)
        end
    elseif val_new_shoot == "Modulo" then
        local weapon_fired_time = entity_get_prop(entity_get_player_weapon(lp), "m_fLastShotTime")
        if round(curtime, 1) == round(weapon_fired_time, 1) and weapon_fired == false then
            weapon_fired_times = weapon_fired_times + 1
            weapon_fired = true
        elseif round(curtime, 1) > round(weapon_fired_time, 1) and weapon_fired == true then
            weapon_fired = false
        end

        if weapon_fired_times % ui_get(new_modulo_slider) == 0 then
            ui_set(ref_shoot, true)
        else
            ui_set(ref_shoot, false)
        end
    elseif val_new_shoot == "-" then
        if val_shoot == true then
            ui_set(ref_shoot, false)
        end
    end
end

client.set_event_callback("run_command", handle_run_command)

local function handle_paint(ctx)
    client_draw_indicator(ctx, 255, 255, 255, 255, "choked: ", choked_cmds)
end

client.set_event_callback("paint", handle_paint)