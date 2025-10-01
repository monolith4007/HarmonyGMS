/// @function player_eject_wall(inst)
/// @description Moves the sides of the player's virtual mask out of collision with the given solid.
/// @param {Id.Instance} inst Instance to eject from.
/// @returns {Real|Undefined} Sign of the wall from the player, or undefined on failure to relocate.
function player_eject_wall(inst)
{
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	for (var ox = 0; ox < x_wall_radius; ++ox)
	{
		// Left of the wall
		if (player_leg_in_object(inst, ox + 1, 0))
		{
			x -= cosine * (x_wall_radius - ox);
			y += sine * (x_wall_radius - ox);
			return 1;
		}
		else if (player_leg_in_object(inst, -(ox + 1), 0)) // Right of the wall
		{
			x += cosine * (x_wall_radius - ox);
			y -= sine * (x_wall_radius - ox);
			return -1;
		}
	}
	return undefined;
}

/// @function player_resolve_angle()
/// @description Determines the player's angle values.
function player_resolve_angle()
{
	var mask_edge = 0;
	var ramp_edge = 0;
	
	// Find which of the player's vertical sensors are grounded
	for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
	{
		var inst = solid_objects[| n];
		
		// Check directly below
		if (player_leg_in_object(inst, -x_radius, y_radius + 1)) mask_edge |= 1;
		if (player_leg_in_object(inst, x_radius, y_radius + 1)) mask_edge |= 2;
		
		// Check for ramp edges
		if (not landed)
		{
			if (player_leg_in_object(inst, -x_radius, y_radius + y_tile_reach)) ramp_edge |= 1;
			if (player_leg_in_object(inst, x_radius, y_radius + y_tile_reach)) ramp_edge |= 2;
		}
	}
	
	// Setup offset point from which the normal should be calculated
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	// Check for steep angle ranges at ramp edges
	ground_snap = true;
	if (ramp_edge != 0 and ramp_edge != 3)
	{
		if (ramp_edge == 2)
		{
			var ox = x_int - cosine * x_radius + sine * y_radius + sine;
			var oy = y_int + sine * x_radius + cosine * y_radius + cosine;
			var rot = mask_direction + 90;
		}
		else
		{
			var ox = x_int + cosine * x_radius + sine * y_radius + sine;
			var oy = y_int - sine * x_radius + cosine * y_radius + cosine;
			var rot = mask_direction + 270;
		}
		
		// Calculate...
		var perp_dir = player_calc_ground_normal(ox, oy, rot); // The normal perpendicular to the ramp edge
		var diff = abs(angle_difference(perp_dir, direction)); // Difference between normal and current angle
		
		// If the difference is too steep, do not snap down to the ground, and abort angle calculation
		if (diff > 45 and diff < 90)
		{
			ground_snap = false;
			exit;
		}
	}
	
	// Calculate the ground normal
	if (mask_edge != 0)
	{
		var new_dir = mask_direction;
		if (mask_edge != 3)
		{
			if (mask_edge == 1)
			{
				var ox = x_int - cosine * x_radius + sine * y_radius;
				var oy = y_int + sine * x_radius + cosine * y_radius;
			}
			else
			{
				var ox = x_int + cosine * x_radius + sine * y_radius;
				var oy = y_int - sine * x_radius + cosine * y_radius;
			}
			new_dir = player_calc_ground_normal(ox, oy, mask_direction);
		}
		
		// Set new angle values
		direction = new_dir;
		local_direction = angle_wrap(direction - gravity_direction);
	}
}

/// @function player_ground(inst, [height])
/// @description Sets the given instance as the terrain the player is standing on. If noone is assigned, the player is rotated to their gravity direction.
/// @param {Id.Instance} inst Instance to set.
/// @param {Real} [height] Distance in pixels to align the player's virtual mask with the instance (optional if noone is assigned).
function player_ground(inst, height)
{
	ground_id = inst;
	on_ground = (inst != noone);
	
	if (not on_ground)
	{
		direction = gravity_direction;
		mask_direction = gravity_direction;
		objCamera.on_ground = false;
	}
	else
	{
		// Align to ground
		var offset = y_radius - height + 1;
		x -= dsin(mask_direction) * offset;
		y -= dcos(mask_direction) * offset;
		
		// Update angle values
		player_resolve_angle();
	}
}

/// @function player_refresh_physics()
/// @description Resets the player's physics variables back to their default values, applying any modifiers afterward.
function player_refresh_physics()
{
	// Speed values
	speed_cap = 6;
	acceleration = 0.046875;
	deceleration = 0.5;
	friction = 0.046875;
	air_acceleration = 0.09375;
	roll_deceleration = 0.125;
	roll_friction = 0.0234375;
	
	// Aerial values
	gravity_cap = 16;
	gravity_force = 0.21875;
	recoil_gravity = 0.1875;
	jump_height = 6.5;
	jump_release = 4;
	
	// Superspeed modification
	if (superspeed_time > 0)
	{
		speed_cap *= 2;
		acceleration *= 2;
		friction *= 2;
		air_acceleration *= 2;
		roll_friction *= 2;
	}
}

/// @function player_in_bounds()
/// @description Confines the player inside the camera boundary.
/// @returns {Bool} Whether the player has fallen below the boundary.
function player_in_bounds()
{
	// Check if already inside (early out)
	if (gravity_direction mod 180 != 0)
	{
		var x1 = x - y_radius;
		var y1 = y - x_radius;
		var x2 = x + y_radius;
		var y2 = y + x_radius;
	}
	else
	{
		var x1 = x - x_radius;
		var y1 = y - y_radius;
		var x2 = x + x_radius;
		var y2 = y + y_radius;
	}
	
	with (objCamera)
	{
		var left = bound_left;
		var top = bound_top;
		var right = bound_right;
		var bottom = bound_bottom;
	}
	
	if (rectangle_in_rectangle(x1, y1, x2, y2, left, top, right, bottom) == 1)
	{
		return true;
	}
	
	// Reposition
	if (gravity_direction mod 180 != 0)
	{
		if (y1 < top)
		{
			y = top + x_radius;
			x_speed = 0;
		}
		if (y2 > bottom)
		{
			y = bottom - x_radius;
			x_speed = 0;
		}
		if (gravity_direction == 90 and x1 > right)
		{
			x = right + y_radius;
			return false;
		}
		if (gravity_direction == 270 and x2 < left)
		{
			x = left - y_radius;
			return false;
		}
	}
	else
	{
		if (x1 < left)
		{
			x = left + x_radius;
			x_speed = 0;
		}
		if (x2 > right)
		{
			x = right - x_radius;
			x_speed = 0;
		}
		if (gravity_direction == 0 and y1 > bottom)
		{
			y = bottom + y_radius;
			return false;
		}
		if (gravity_direction == 180 and y2 < top)
		{
			y = top - y_radius;
			return false;
		}
	}
	return true;
}