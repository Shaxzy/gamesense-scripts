local GetUi = ui.get
local SetUi = ui.set
local uidToEntIndex = client.userid_to_entindex
local LocalPlayer = entity.get_local_player

local posx, posy = client.screen_size()

-- syntax: client.draw_line(paint_ctx, xa, ya, xb, yb, r, g, b, a)
local DrawLine = client.draw_line

local floor = math.floor

local flHurtTime = 0

local SwastikaHitmarker = ui.new_checkbox("VISUALS", "Player ESP", "Swastika Hitmarker")
local hitmarker_size 	= ui.new_slider("VISUALS", "Player ESP", "Hitmarker Size", 0, 100)
local red_button  		= ui.new_slider("VISUALS", "Player ESP", "Hitmarker Red", 0, 255)
local green_button		= ui.new_slider("VISUALS", "Player ESP", "Hitmarker Green", 0, 255)
local blue_button 		= ui.new_slider("VISUALS", "Player ESP", "Hitmarker Blue", 0, 255)

SetUi(hitmarker_size, 5)

local function on_paint(context)
	local flCurTime = floor(globals.curtime())

	local width = posx / 2
	local height = posy / 2

	local red_color		= GetUi(red_button)
	local green_color	= GetUi(green_button)
	local blue_color	= GetUi(blue_button)
	local size 			= GetUi(hitmarker_size)

	if flHurtTime + 0.25 >= floor(flCurTime) then

		DrawLine(context, width, height, width, height - size, red_color, green_color, blue_color, 255);
		DrawLine(context, width, height - (size ), width + size, height - (size), 	red_color, green_color, blue_color, 255);

		DrawLine(context, width, height, width + (size ), height, red_color, green_color, blue_color, 255);
		DrawLine(context, width + (size ), height, width + (size ), height + (size), red_color, green_color, blue_color, 255);

		DrawLine(context, width, height, width, height + (size ), red_color, green_color, blue_color, 255);
		DrawLine(context, width, height + (size ), width - (size ), height + (size ), red_color, green_color, blue_color, 255);

		DrawLine(context, width, height, width - (size ), height, red_color, green_color, blue_color, 255);
		DrawLine(context, width - (size ), height, width - (size ), height - (size ), red_color, green_color, blue_color, 255);
	end
end

local function on_player_hurt(event)
	if GetUi(SwastikaHitmarker) then
		local attackerUID = event.attacker
		local attackerEntIndex = uidToEntIndex(attackerUID)
		
		if not LocalPlayer then
			client.log("LocalPlayer is nil or " .. LocalPlayer)
			return
		end
	
		if not attackerEntIndex then
			client.log("attackerEntIndex is nil or " .. attackerEntIndex)
			return
		end
	
		if attackerUID == nil then
			client.log("attackerUID is nil or " .. attackerUID)
			return
		end
		
		if attackerEntIndex == LocalPlayer() then
			flHurtTime = globals.curtime()
		end
	end
end

local err = client.set_event_callback('paint', on_paint) or
            client.set_event_callback('player_hurt', on_player_hurt)
if err then
    client.log("set_event_callback failed: ", err)
end

client.log("You successfully loaded the Swastika Hitmarker script.")