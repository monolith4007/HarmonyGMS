/// @function player_find_wall()
/// @description Finds the first solid intersecting the sides of the player's virtual mask.
/// @returns {Id.TileMapElement|Id.Instance}
function player_find_wall()
{
	for (var n = array_length(tilemaps) - 1; n > -1; --n)
	{
		var inst = tilemaps[n];
		if (player_ray_collision(inst)) return inst;
	}
	
	for (n = array_length(solid_objects) - 1; n > -1; --n)
	{
		inst = solid_objects[n];
		if (player_ray_collision(inst)) return inst;
	}
	
	return noone;
}

/// @function player_find_floor(radius)
/// @description Finds the minimum distance between the player and the first solid intersecting the lower half of their virtual mask.
/// @param {Real} radius Distance in pixels to extend the mask downward.
/// @returns {Real|Undefined}
function player_find_floor(radius)
{
	for (var oy = 0; oy <= radius; ++oy)
	{
		for (var n = array_length(tilemaps) - 1; n > -1; --n)
		{
			if (player_ray_collision(tilemaps[n], x_radius, oy)) return oy;
		}
		
		for (n = array_length(solid_objects) - 1; n > -1; --n)
		{
			if (player_ray_collision(solid_objects[n], x_radius, oy)) return oy;
		}
	}
	
	return undefined;
}

/// @function player_find_ceiling(radius)
/// @description Finds the minimum distance between the player and the first solid intersecting the upper half of their virtual mask.
/// @param {Real} radius Distance in pixels to extend the mask upward.
/// @returns {Real|Undefined}
function player_find_ceiling(radius)
{
	for (var oy = 0; oy <= radius; ++oy)
	{
		for (var n = array_length(tilemaps) - 1; n > -1; --n)
		{
			var inst = tilemaps[n];
			if (player_ray_collision(inst, x_radius, -oy) and inst != semisolid_tilemap) return oy;
		}
		
		for (n = array_length(solid_objects) - 1; n > -1; --n)
		{
			inst = solid_objects[n];
			if (player_ray_collision(inst, x_radius, -oy) and not inst.semisolid) return oy;
		}
	}
	
	return undefined;
}