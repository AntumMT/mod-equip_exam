
local S = core.get_translator("equip_exam")

equip_exam.formspec_name = "equipExam"


local function get_item_specs(item)
	if not item then return nil end

	local specs = nil
	local name = item.short_description
	if not name then name = item.description end
	local id = item.name

	if not name then
		specs = S("ID: @1", id)
	else
		specs = S("name: @1", name) .. "," .. S("ID: @1", id)
	end

	if item.tool_capabilities.damage_groups then
		for k, v in pairs(item.tool_capabilities.damage_groups) do
			if not specs or specs == "" then
				specs = k .. ": " .. v
			else
				specs = specs .. "," .. S("Damge to @1 type: @2", k, v)
			end
		end
	end

	return specs
end

function equip_exam:get_formspec(item, empty)
	local specs
	if not empty then
		specs = get_item_specs(core.registered_tools[item])
	else
		specs = "" -- empty
	end

	if not specs then
		specs = S("Specs unavailable")
	end

	local formspec = "formspec_version[4]"
		.. "size[12,9]"
		.. "list[context;input;1,1;1,1;0]"
		.. "button_exit[0.25,3.1;2.5,0.8;close;Close]"
		.. "label[3,0.7;" .. S("Specs:") .. "]"
		.. "textlist[3,1;8,3;speclist;" .. specs .. ";1;false]"
		.. "list[current_player;main;1.15,4.1;8,4;0]"

	return formspec
end

function equip_exam:show_formspec(pos, player)
	local playername = player:get_player_name()
	if not playername or not player:is_player() then return end

	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local contents = inv:get_list("input")[1]

	core.show_formspec(playername, equip_exam.formspec_name, equip_exam:get_formspec(contents:get_name(), inv:is_empty("input")))
end
