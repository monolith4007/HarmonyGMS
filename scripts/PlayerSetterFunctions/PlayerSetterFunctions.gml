/// @function player_eject_wall(inst)
/// @description Moves the player's virtual mask out of collision with the given wall.
/// @param {Id.Instance|Id.TileMapElement} inst Instance or tilemap to eject from.
/// @returns {Real|Undefined} Sign of the wall from the player, or undefined on failure to reposition.
function player_eject_wall(inst)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	if (collision_point(x_int, y_int, inst, true, false) == noone)
	{
		for (var ox = x_wall_radius - 1; ox > -1; --ox)
		{
			if (player_beam_collision(inst, ox) == noone)
			{
				if (collision_point(x_int + cosine * (ox + 1), y_int - sine * (ox + 1), inst, true, false) != noone)
				{
					x -= cosine * (x_wall_radius - ox);
					y += sine * (x_wall_radius - ox);
					return 1;
				}
				else if (collision_point(x_int - cosine * (ox + 1), y_int + sine * (ox + 1), inst, true, false) != noone)
				{
					x += cosine * (x_wall_radius - ox);
					y -= sine * (x_wall_radius - ox);
					return -1;
				}
			}
		}
	}
	else for (var ox = 1; ox <= x_wall_radius; ++ox)
	{
		if (collision_point(x_int + cosine * ox, y_int - sine * ox, inst, true, false) == noone)
		{
			x += cosine * (x_wall_radius + ox);
			y -= sine * (x_wall_radius + ox);
			return -1;
		}
		else if (collision_point(x_int - cosine * ox, y_int + sine * ox, inst, true, false) == noone)
		{
			x -= cosine * (x_wall_radius + ox);
			y += sine * (x_wall_radius + ox);
			return 1;
		}
	}
	
	return undefined;
}

/// @function player_ground(height)
/// @description Aligns the player to the ground using the given height and updates their angle values.
/// If undefined is passed instead, the player is detached from the ground.
/// @param {Real|Undefined} height Amount in pixels to reposition the player, if applicable.
function player_ground(height)
{
	if (height != undefined)
	{
		var offset = y_radius - height + 1;
		x -= dsin(mask_direction) * offset;
		y -= dcos(mask_direction) * offset;
		
		player_detect_angle();
	}
	else
	{
		on_ground = false;
		objCamera.on_ground = false;
		mask_direction = gravity_direction;
	}
}

/// @function player_detect_angle()
/// @description Sets the player's angle values.
function player_detect_angle()
{
	// Check for ground collision using all vertical sensors
	//ground_snap = true;
	var edge = 0;
	if (player_ray_collision(solid_colliders, -x_radius, y_radius + 1)) edge |= 1;
	if (player_ray_collision(solid_colliders, x_radius, y_radius + 1)) edge |= 2;
	if (player_ray_collision(solid_colliders, 0, y_radius + 1)) edge |= 4;
	
	// Abort on no collision
	if (edge == 0) exit;
	
	// Set new angle values
	if (edge & (edge - 1) != 0) // Check if at least two sensors are grounded (non-power of 2 calculation)
	{
		direction = mask_direction;
	}
	else
	{
		// Setup offset point
		var sine = dsin(mask_direction);
		var cosine = dcos(mask_direction);
		var ox = x div 1 + sine * y_radius;
		var oy = y div 1 + cosine * y_radius;
		
		// Check for steep angle ranges at ramp edges
		/*if (not (landed or player_ray_collision(solid_colliders, 0, y_radius + y_tile_reach)) and
			(player_ray_collision(solid_colliders, -x_radius, y_radius + y_tile_reach) xor
			player_ray_collision(solid_colliders, x_radius, y_radius + y_tile_reach)))
		{
			// Calculate...
			var perp_dir = player_calc_tile_normal(ox + sine, oy + cosine, mask_direction + (edge == 2 ? 90 : 270)); // The normal of the ramp edge
			var diff = abs(angle_difference(perp_dir, direction)); // Difference between normal and current angle
			
			// If the difference is too steep, do not snap down to the ground, and abort
			if (diff > 45 and diff < 90)
			{
				ground_snap = false;
				exit;
			}
		}*/
		
		// Reposition offset point, if applicable
		if (edge == 1)
		{
			ox -= cosine * x_radius;
			oy += sine * x_radius;
		}
		else if (edge == 2)
		{
			ox += cosine * x_radius;
			oy -= sine * x_radius;
		}
		direction = player_calc_tile_normal(ox, oy, mask_direction);
	}
	local_direction = angle_wrap(direction - gravity_direction);
}

/// @function player_keep_in_bounds()
/// @description Confines the player inside the camera boundary.
/// @returns {Bool} Whether the player is inside the boundary or has fallen below it.
function player_keep_in_bounds()
{
	// Check if already inside (early out)
	var vertical = gravity_direction mod 180 == 0;
	if (vertical)
	{
		var x1 = x - x_radius;
		var y1 = y - y_radius;
		var x2 = x + x_radius;
		var y2 = y + y_radius;
	}
	else
	{
		var x1 = x - y_radius;
		var y1 = y - x_radius;
		var x2 = x + y_radius;
		var y2 = y + x_radius;
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
	if (vertical)
	{
		if (x1 < left)
		{
			x = left + x_radius;
			x_speed = 0;
		}
		else if (x2 > right)
		{
			x = right - x_radius;
			x_speed = 0;
		}
		
		if (y1 > bottom and gravity_direction == 0)
		{
			y = bottom + y_radius;
			return false;
		}
		else if (y2 < top and gravity_direction == 180)
		{
			y = top - y_radius;
			return false;
		}
	}
	else
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
		
		if (x1 > right and gravity_direction == 90)
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
	
	return true;
}

/// @function player_refresh_physics()
/// @description Resets the player's physics variables back to their default values, applying any modifiers afterward.
function player_refresh_physics()
{
	// Speed values
	speed_cap = 6;
	acceleration = 0.046875;
	deceleration = 0.5;
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
		air_acceleration *= 2;
		roll_friction *= 2;
	}
}