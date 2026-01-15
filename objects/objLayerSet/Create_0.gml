/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	// Abort if not inside the instance
	if (collision_circle(x div 1, y div 1, 1, inst, false, false) == noone) exit;
	
	// Switch
	collision_layer = sign(inst.image_xscale) == sign(x - xprevious);
	solid_colliders[1] = ctrlZone.tilemaps[collision_layer + 1];
};

/* AUTHOR NOTE: tilemap validation is not performed as it is assumed this object will not be placed
in rooms that lack the "CollisionPlane0" and "CollisionPlane1" layers. */