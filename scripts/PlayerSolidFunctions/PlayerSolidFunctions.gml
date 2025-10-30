/// @function player_get_wall()
/// @description Finds the first solid intersecting the sides of the player's virtual mask.
/// @returns {Id.TileMapElement|Id.Instance}
function player_get_wall()
{
	for (var n = array_length(tilemaps) - 1; n > -1; --n)
	{
		var inst = tilemaps[n];
		if (player_ray_collision(inst)) return inst;
	}
	
	for (n = ds_list_size(solid_objects) - 1; n > -1; --n)
	{
		inst = solid_objects[| n];
		if (player_ray_collision(inst)) return inst;
	}
	
	return noone;
}

/// @function player_get_floor(height)
/// @description Finds the first solid intersecting the lower half of the player's virtual mask.
/// @param {Real} height Distance in pixels to extend the mask downward.
/// @returns {Array} The instance or tilemap element found and the height at which it was found, or noone and undefined on failure.
function player_get_floor(height)
{
	for (var oy = 0; oy <= height; ++oy)
	{
		for (var n = array_length(tilemaps) - 1; n > -1; --n)
		{
			var inst = tilemaps[n];
			if (player_ray_collision(inst, x_radius, oy)) return [inst, oy];
		}
		
		for (n = ds_list_size(solid_objects) - 1; n > -1; --n)
		{
			inst = solid_objects[| n];
			if (player_ray_collision(inst, x_radius, oy)) return [inst, oy];
		}
	}
	
	return [noone, undefined];
}

/// @function player_get_ceiling(height)
/// @description Finds the first solid intersecting the upper half of the player's virtual mask.
/// @param {Real} height Distance in pixels to extend the mask upward.
/// @returns {Array} The instance or tilemap element found and the height at which it was found, or noone and undefined on failure.
function player_get_ceiling(height)
{
	for (var oy = 0; oy <= height; ++oy)
	{
		for (var n = array_length(tilemaps) - 1; n > -1; --n)
		{
			var inst = tilemaps[n];
			if (player_ray_collision(inst, x_radius, -oy) and inst != semisolid_tilemap)
			{
				return [inst, oy];
			}
		}
		
		for (n = ds_list_size(solid_objects) - 1; n > -1; --n)
		{
			inst = solid_objects[| n];
			if (player_ray_collision(inst, x_radius, -oy) and not inst.semisolid) return [inst, oy];
		}
	}
	
	return [noone, undefined];
}