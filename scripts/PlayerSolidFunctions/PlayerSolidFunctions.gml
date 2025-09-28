/// @function player_get_wall()
/// @description Finds the first solid intersecting the sides of the player's virtual mask.
/// @returns {Id.Instance}
function player_get_wall()
{
	for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
	{
		var inst = solid_objects[| n];
		if (player_arms_in_object(inst)) return inst;
	}
	return noone;
}

/// @function player_get_floor(height)
/// @description Finds the first solid intersecting the lower half of the player's virtual mask.
/// @param {Real} height Distance in pixels to extend the mask downward.
/// @returns {Id.Instance}
function player_get_floor(height)
{
	for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
	{
		var inst = solid_objects[| n];
		if (player_body_in_object(inst, height)) return inst;
	}
	return noone;
}

/// @function player_get_ceiling(height)
/// @description Finds the first solid intersecting the upper half of the player's virtual mask.
/// @param {Real} height Distance in pixels to extend the mask upward.
/// @returns {Id.Instance}
function player_get_ceiling(height)
{
	for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
	{
		var inst = solid_objects[| n];
		if (player_body_in_object(inst, -height) and not inst.semisolid) return inst;
	}
	return noone;
}