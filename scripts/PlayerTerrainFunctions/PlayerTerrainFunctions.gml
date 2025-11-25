/// @function player_find_wall()
/// @description Finds the first solid intersecting the sides of the player's virtual mask.
/// @returns {Id.TileMapElement|Id.Instance}
function player_find_wall()
{
	var total_solids = array_concat(tilemaps, solid_objects);
	for (var n = array_length(total_solids) - 1; n > -1; --n)
	{
		var inst = total_solids[n];
		if (player_beam_collision(inst)) return inst;
	}
	
	return noone;
}

/// @function player_find_floor(radius)
/// @description Finds the minimum distance between the player and the first solid intersecting the lower half of their virtual mask.
/// @param {Real} radius Distance in pixels to extend the mask downward.
/// @returns {Real|Undefined}
function player_find_floor(radius)
{
	var total_solids = array_concat(tilemaps, solid_objects);
	for (var oy = 0; oy <= radius; ++oy)
	{
		if (player_beam_collision(total_solids, x_radius, oy))
		{
			return oy;
		}
	}
	
	return undefined;
}

/* TODO: since GameMaker's collision functions accept an array of entities to check against for collision,
think about refactoring the player's collision functions to directly return the entity id; this would condense `player_find_wall`
to one line of code. */

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
			if (player_beam_collision(inst, x_radius, -oy) and inst != semisolid_tilemap)
			{
				return oy;
			}
		}
		
		for (n = array_length(solid_objects) - 1; n > -1; --n)
		{
			inst = solid_objects[n];
			if (player_beam_collision(inst, x_radius, -oy) and not inst.semisolid)
			{
				return oy;
			}
		}
	}
	
	return undefined;
}