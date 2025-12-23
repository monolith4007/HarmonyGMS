/// @function player_find_floor(height)
/// @description Finds the minimum distance between the player and the first solid intersecting the lower half of their virtual mask.
/// @param {Real} height Distance in pixels to extend the mask downward.
/// @returns {Real|Undefined}
function player_find_floor(height)
{
	for (var oy = 0; oy <= height; ++oy)
	{
		if (player_beam_collision(solid_entities, x_radius, oy) != noone)
		{
			return oy;
		}
	}
	
	return undefined;
}

/// @function player_find_ceiling(height)
/// @description Finds the minimum distance between the player and the first solid intersecting the upper half of their virtual mask.
/// @param {Real} height Distance in pixels to extend the mask upward.
/// @returns {Real|Undefined}
function player_find_ceiling(height)
{
	for (var oy = 0; oy <= height; ++oy)
	{
		var inst = player_beam_collision(solid_entities, x_radius, -oy);
		
		// Skip the solid if passing through it
		if (inst == noone or inst == semisolid_tilemap or (instance_exists(inst) and inst.semisolid))
		{
			continue;
		}
		
		return oy;
	}
	
	return undefined;
}

/* AUTHOR NOTE:
(1) Wall collisions are checked by calling `player_beam_collision(solid_entities)`.
(2) If you simply wanted to check for the presence of a floor or ceiling, you can pass the `solid_entities` array to the `player_part_collision` function alongside your desired height. */