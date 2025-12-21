/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	var index = inst.result;
	
	// Abort if not intersecting the ring
	if (collision_layer == index or collision_point(x div 1, y div 1, inst, false, false) == noone)
	{
		exit;
	}
	
	// Switch
	if (index > -1)
	{
		collision_layer = index;
		solid_entities[1] = ctrlZone.tilemaps[index + 1];
	}
	else if (on_ground)
	{
		collision_layer = sign(x - xprevious);
		solid_entities[1] = ctrlZone.tilemaps[collision_layer + 1];
	}
};