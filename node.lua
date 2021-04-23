
local node_def = {
	drawtype = "normal",
	tiles = {
		"equip_exam_examiner_front.png",
		"equip_exam_examiner.png",
	},
	is_gound_content = false,
	stack_max = 1,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		equip_exam:show_formspec(player)
	end,
	on_construct = function(pos)
		local inv = core.get_meta(pos):get_inventory()
		inv:set_size('input', 1)
	end,
}

core.register_node("equip_exam:examiner", node_def)
