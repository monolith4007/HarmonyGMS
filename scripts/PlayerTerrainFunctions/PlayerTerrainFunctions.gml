/// @function player_find_wall()
/// @description Finds the first solid intersecting the sides of the player's virtual mask.
/// @returns {Id.TileMapElement|Id.Instance}
function player_find_wall()
{
	var n = array_find_index(solid_entities, function (inst)
	{
		return player_beam_collision(inst);
	});
	
	return (n != -1 ? solid_entities[n] : noone);
}

/// @function player_find_floor(radius)
/// @description Finds the minimum distance between the player and the first solid intersecting the lower half of their virtual mask.
/// @param {Real} radius Distance in pixels to extend the mask downward.
/// @returns {Real|Undefined}
function player_find_floor(radius)
{
	for (var oy = 0; oy <= radius; ++oy)
	{
		if (player_beam_collision(solid_entities, x_radius, oy))
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
	var total = array_length(solid_entities);
	for (var oy = 0; oy <= radius; ++oy)
	{
		for (var n = 0; n < total; ++n)
		{
			var inst = solid_entities[n];
			
			// Skip the solid if passing through it
			if (inst == semisolid_tilemap or (instance_exists(inst) and inst.semisolid) or not player_beam_collision(inst, x_radius, -oy))
			{
				continue;
			}
			
			return oy;
		}
	}
	
	return undefined;
}