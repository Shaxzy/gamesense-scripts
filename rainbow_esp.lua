local ui_get, ui_set, ui_new_checkbox, ui_new_slider, ui_new_colorpicker, ui_new_multiselect = ui.get, ui.set, ui.new_checkbox, ui.new_slider, ui.new_color_picker, ui.new_multiselect
local cl_log = client.log
local math_floor = math.floor

local self_esp, self_cp = ui.reference("visuals", "colored models", "show teammates")
local player_esp, player_cp = ui.reference("visuals", "colored models", "player")
local playerbw_esp, playerbw_cp = ui.reference("visuals", "colored models", "player behind wall")
local box_esp, box_cp = ui.reference("visuals", "player esp", "bounding box")
local glow_esp, glow_cp = ui.reference("visuals", "player esp", "glow")
local bullet_esp, bullet_cp = ui.reference("visuals", "effects", "bullet tracers")
local skeleton_esp, skeleton_cp = ui.reference("visuals", "player esp", "skeleton")
local sound_esp, sound_cp = ui.reference("visuals", "player esp", "visualize sounds")
local name_esp, name_cp = ui.reference("visuals", "player esp", "name")
local shadow_esp, shadow_cp = ui.reference("visuals", "colored models", "shadow")
local spread_esp, spread_cp = ui.reference("visuals", "other esp", "inaccuracy overlay")
local Rainbow = ui_new_multiselect("visuals", "player esp", "Rainbow ESP", "Self / Team", "Enemy", "Enemy behind wall", "Shadow", "Box", "Glow", "Bullet tracers", "Skeleton", "Visualize sounds", "Name", "Spread circle")
local RainbowAlpha = ui_new_slider("visuals", "player esp", "Rainbow Alpha", 0, 255, 200, true)



local function on_paint(ctx)
		alpha = ui_get(RainbowAlpha)
		local tickcount = globals.tickcount
	function hsv_to_rgb(h, s, v, a)
	local r, g, b

	local i = math_floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
		elseif i == 1 then r, g, b = q, v, p
		elseif i == 2 then r, g, b = p, v, t
		elseif i == 3 then r, g, b = p, q, v
		elseif i == 4 then r, g, b = t, p, v
		elseif i == 5 then r, g, b = v, p, q
	end

	return r * 255, g * 255, b * 255, a * alpha
end
	

	local selectedRainbow = ui_get(Rainbow)
	for i=1, #selectedRainbow do
		if selectedRainbow[i] == "Self / Team" then
			ui_set(self_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Enemy" then
			ui_set(player_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Enemy behind wall" then
			ui_set(playerbw_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Shadow" then
			ui_set(shadow_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Box" then
			ui_set(box_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Glow" then
			ui_set(glow_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Bullet tracers" then
			ui_set(bullet_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Skeleton" then
			ui_set(skeleton_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Visualize sounds" then 
			ui_set(sound_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Name" then
			ui_set(name_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		elseif selectedRainbow[i] == "Spread circle" then
			ui_set(spread_cp, hsv_to_rgb(tickcount() % 350 / 350, 1, 1, 1, alpha))
		end
	end
end	

client.set_event_callback("paint", on_paint)