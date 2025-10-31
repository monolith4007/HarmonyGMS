/// @function player_eject_wall(inst)
/// @description Moves the player's virtual mask out of collision with the given wall.
/// @param {Id.Instance|Id.TileMapElement} inst Instance or tilemap element to eject from.
/// @returns {Real|Undefined} Sign of the wall from the player, or undefined on failure to reposition.
function player_eject_wall(inst)
{
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	var inside = (collision_point(x div 1, y div 1, inst, true, false) != noone);
	
	for (var ox = 1; ox <= x_wall_radius; ++ox)
	{
		if (not inside)
		{
			// Left of the wall
			if (player_beam_collision(inst, ox, 0))
			{
				x -= cosine * (x_wall_radius - ox + 1);
				y += sine * (x_wall_radius - ox + 1);
				return 1;
			}
			else if (player_beam_collision(inst, -ox, 0)) // Right of the wall
			{
				x += cosine * (x_wall_radius - ox + 1);
				y -= sine * (x_wall_radius - ox + 1);
				return -1;
			}
		}
		else if (not player_beam_collision(inst, ox, 0)) // Right of the wall
		{
			x += cosine * (x_wall_radius + ox);
			y -= sine * (x_wall_radius + ox);
			return -1;
		}
		else if (not player_beam_collision(inst, -ox, 0)) // Left of the wall
		{
			x -= cosine * (x_wall_radius + ox);
			y += sine * (x_wall_radius + ox);
			return 1;
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
	for (var n = array_length(tilemaps) - 1, k = array_length(solid_objects) - 1; max(n, k) > -1; {--n; --k})
	{
		var inst = [(n > -1 ? tilemaps[n] : noone), (k > -1 ? solid_objects[k] : noone)];
		
		// Check directly below
		if (player_beam_collision(inst, -x_radius, y_radius + 1)) mask_edge |= 1;
		if (player_beam_collision(inst, x_radius, y_radius + 1)) mask_edge |= 2;
		
		// Check for ramp edges
		if (not landed)
		{
			if (player_beam_collision(inst, -x_radius, y_radius + y_tile_reach)) ramp_edge |= 1;
			if (player_beam_collision(inst, x_radius, y_radius + y_tile_reach)) ramp_edge |= 2;
			if (player_beam_collision(inst, 0, y_radius + y_tile_reach)) ramp_edge |= 4;
		}
	}
	
	// Setup offset point from which the normal should be calculated
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	var ox = x div 1 + sine * y_radius;
	var oy = y div 1 + cosine * y_radius;
	
	// Check for steep angle ranges at ramp edges
	ground_snap = true;
	if (ramp_edge == 1 or ramp_edge == 2)
	{
		// Calculate...
		var perp_dir = player_calc_ground_normal(ox + sine, oy + cosine, mask_direction + (ramp_edge == 2 ? 90 : 270)); // The normal of the ramp edge
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
			// Reposition offset point to the grounded side of the player's virtual mask
			if (mask_edge == 1)
			{
				ox -= cosine * x_radius;
				oy += sine * x_radius;
			}
			else
			{
				ox += cosine * x_radius;
				oy -= sine * x_radius;
			}
			new_dir = player_calc_ground_normal(ox, oy, mask_direction);
		}
		
		// Set new angle values
		direction = new_dir;
		local_direction = angle_wrap(direction - gravity_direction);
	}
}

/// @function player_ground(height)
/// @description Records the player as being on the ground, and repositions them by the given height if undefined is not passed.
/// Otherwise, the player falls and is rotated towards their gravity direction.
/// @param {Real|Undefined} height Amount in pixels to reposition the player, if applicable.
function player_ground(height)
{
	on_ground = (height != undefined);
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
/// @returns {Bool} Whether the player is inside the boundary or has fallen below it.
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
		else if (y2 > bottom)
		{
			y = bottom - x_radius;
			x_speed = 0;
		}
		else if (x1 > right and gravity_direction == 90)
		{
			x = right + y_radius;
			return false;
		}
		else if (x2 < left and gravity_direction == 270)
		{
			x = left - y_radius;
			return false;
		}
	}
	else if (x1 < left)
	{
		x = left + x_radius;
		x_speed = 0;
	}
	else if (x2 > right)
	{
		x = right - x_radius;
		x_speed = 0;
	}
	else if (y1 > bottom and gravity_direction == 0)
	{
		y = bottom + y_radius;
		return false;
	}
	else if (y2 < top and gravity_direction == 180)
	{
		y = top - y_radius;
		return false;
	}
	return true;
}