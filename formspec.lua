
local S = core.get_translator(equip_exam.name)


local tool_types = {
	["cracky"] = "mine level",
	["choppy"] = "chop level",
	["crumbly"] = "dig level",
	["snappy"] = "snap level",
}

local weapon_types = {
	["fleshy"] = "attack",
	["uses"] = "durability",
	["punch_attack_uses"] = "durability",
}

local armor_types = {
	["fleshy"] = "defense",
	["armor_head"] = "head def.",
	["armor_torso"] = "torso def.",
	["armor_legs"] = "legs def.",
	["armor_feet"] = "feet def.",
	["armor_shield"] = "shield def.",
	["armor_use"] = "durability",
	["armor_heal"] = "healing:",
	["armor_radiation"] = "radiation",
}

local other_types = {
	["flammable"] = "flammability",
	["full_punch_interval"] = "speed interval",
}

local function get_item_specs(item)
	if not item then return nil end

	local specs = {}
	local name = item.short_description
	if not name then name = item.description end
	local id = item.name

	if not name then
		table.insert(specs, S("ID: @1", id))
	else
		table.insert(specs, S("Name: @1", name))
		table.insert(specs, S("ID: @1", id))
	end

	local groups = item.groups or {}
	local tool_capabilities = item.tool_capabilities or {}
	tool_capabilities.damage_groups = tool_capabilities.damage_groups or {}
	tool_capabilities.groupcaps = tool_capabilities.groupcaps or {}
	local armor_groups = item.armor_groups or {}

	local specs_tool = {}
	local specs_weapon = {}
	local specs_armor = {}
	local specs_other = {}

	for k, v in pairs(tool_capabilities) do
		if type(v) ~= "table" then
			if tool_types[k] then
				table.insert(specs_tool, S(tool_types[k] .. ": @1", v))
			elseif weapon_types[k] then
				table.insert(specs_other, S(weapon_types[k] .. ": @1", v))
			elseif armor_types[k] then
				table.insert(specs_other, S(armor_types[k] .. ": @1", v))
			elseif other_types[k] then
				table.insert(specs_other, S(other_types[k] .. ": @1", v))
			else
				table.insert(specs_other, k .. ": " .. v)
			end
		end
	end

	for k, v in pairs(tool_capabilities.groupcaps) do
		if type(v) ~= "table" then
			table.insert(specs_other, k .. ": " .. v)
		else
			if v.maxlevel then
				if tool_types[k] then
					table.insert(specs_tool, S(tool_types[k] .. ": @1", v.maxlevel))
					if v.uses then
						table.insert(specs_tool, S("durability: @1", v.uses))
					end
				elseif other_types[k] then
					table.insert(specs_other, S(other_types[k] .. ": @1", v.maxlevel))
					if v.uses then
						table.insert(specs_other, S("durability: @1", v.uses))
					end
				else
					table.insert(specs_other, k .. ": " .. v.maxelevel)
					if v.uses then
						table.insert(specs_other, S("durability: @1", v.uses))
					end
				end
			end
		end
	end

	for k, v in pairs(tool_capabilities.damage_groups) do
		if weapon_types[k] then
			table.insert(specs_weapon, S(weapon_types[k] .. ": @1", v))
		elseif other_types[k] then
			table.insert(specs_other, S(other_types[k] .. ": @1", v))
		else
			table.insert(specs_other, k .. ": " .. v)
		end
	end

	for k, v in pairs(armor_groups) do
		if armor_types[k] then
			table.insert(specs_armor, S(armor_types[k] .. ": @1", v))
		elseif other_types[k] then
			table.insert(specs_other, S(other_types[k] .. ": @1", v))
		else
			table.insert(specs_other, k .. ": " .. v)
		end
	end

	for k, v in pairs(groups) do
		if tool_types[k] then
			table.insert(specs_tool, S(tool_types[k] .. ": @1", v))
		elseif weapon_types[k] then
			table.insert(specs_weapon, S(weapon_types[k] .. ": @1", v))
		elseif armor_types[k] then
			table.insert(specs_armor, S(armor_types[k] .. ": @1", v))
		elseif other_types[k] then
			table.insert(specs_other, S(other_types[k] .. ": @1", v))
		else
			table.insert(specs_other, k .. ": " .. v)
		end
	end

	if #specs_tool > 0 then
		table.insert(specs, S("Tool:"))
		for _, sp in ipairs(specs_tool) do
			table.insert(specs, "  " .. sp)
		end
	end
	if #specs_weapon > 0 then
		table.insert(specs, S("Weapon:"))
		for _, sp in ipairs(specs_weapon) do
			table.insert(specs, "  " .. sp)
		end
	end
	if #specs_armor > 0 then
		table.insert(specs, S("Armor:"))
		for _, sp in ipairs(specs_armor) do
			table.insert(specs, "  " .. sp)
		end
	end
	if #specs_other > 0 then
		table.insert(specs, S("Other:"))
		for _, sp in ipairs(specs_other) do
			table.insert(specs, "  " .. sp)
		end
	end

	if not specs then return end

	return table.concat(specs, ",")
end


--- Retrieves formspec string.
--
--  @function equip_exam:get_formspec
--  @param item The item name string.
--  @param empty If *true*, no stats information will be printed.
function equip_exam:get_formspec(item, empty)
	local specs
	if not empty then
		specs = get_item_specs(core.registered_items[item])
	else
		specs = "" -- empty
	end

	if not specs then
		specs = S("Specs unavailable")
	end

	local formspec = "formspec_version[4]"
		.. "size[12,9]"
		.. "list[context;input;1,1;1,1;0]"
		.. "button_exit[0.25,3.1;2.5,0.8;close;" .. S("Close") .. "]"
		.. "label[3,0.7;" .. S("Specs:") .. "]"
		.. "textlist[3,1;8,3;speclist;" .. specs .. ";1;false]"
		.. "list[current_player;main;1.15,4.1;8,4;0]"

	return formspec
end


--- Displays the formspec to a player.
--
--  @function equip_exam:show_formspec
--  @param pos The coordinates where the node is located.
--  @param player Player object to whom formspec will be displayed.
function equip_exam:show_formspec(pos, player)
	local playername = player:get_player_name()
	if not playername or not player:is_player() then return end

	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local contents = inv:get_list("input")[1]

	core.show_formspec(playername, equip_exam.name, equip_exam:get_formspec(contents:get_name(), inv:is_empty("input")))
end
