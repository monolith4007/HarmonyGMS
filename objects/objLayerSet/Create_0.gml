/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	var index = inst.result;
	
	// Abort if not intersecting
	if (collision_layer == index or not player_collision(inst)) exit;
	
	// Switch
	if (index > -1)
	{
		collision_layer = index;
		solid_entities[1] = ctrlZone.tilemaps[index + 1];
	}
	else if (on_ground and x_speed != 0)
	{
		collision_layer = x_speed > 0;
		solid_entities[1] = ctrlZone.tilemaps[collision_layer + 1];
	}
};