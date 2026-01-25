/// @function player_move_on_ground()
/// @description Updates the player's position on the ground and checks for collisions.
function player_move_on_ground()
{
	// Ride moving platforms
	with (instance_place(x div 1 + dsin(mask_direction), y div 1 + dcos(mask_direction), objSolid))
	{
		var dx = x - xprevious;
		var dy = y - yprevious;
		if (dx != 0) other.x += dx;
		if (dy != 0) other.y += dy;
	}
	
	/* AUTHOR NOTE: using `instance_place` here is cheeky as the player's sprite mask is used
	to check for collision instead of their virtual mask.
	However, unless the player's virtual mask is wider than their sprite's, this is not an issue. */
	
	// Calculate the number of steps for collision checking
	var total_steps = 1 + abs(x_speed) div x_radius;
	var step = x_speed / total_steps;
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += dcos(direction) * step;
		y -= dsin(direction) * step;
		
		// Die if out of bounds
		if (not player_keep_in_bounds()) return player_perform(player_is_dead);
		
		// Detect instances and tilemaps
		player_get_collisions();
		
		// Handle wall collision
		var tile_data = player_beam_collision(solid_colliders);
		if (tile_data != noone and sign(x_speed) == player_eject_wall(tile_data))
		{
			x_speed = 0;
		}
		
		// Handle floor collision
		//tile_data = player_find_floor(y_radius + (ground_snap ? y_tile_reach : 1));
		tile_data = player_find_floor(y_radius + min(2 + abs(x_speed) div 1, y_tile_reach));
		if (tile_data != undefined)
		{
			player_ground(tile_data);
			player_rotate_mask();
		}
		else on_ground = false;
		
		// Exit loop if stopped or airborne
		if (x_speed == 0 or not on_ground) break;
	}
}

/// @function player_move_in_air()
/// @description Updates the player's position in the air and checks for collisions.
function player_move_in_air()
{
	// Calculate the number of steps for collision checking
	var total_steps = 1 + abs(x_speed) div x_radius + abs(y_speed) div y_radius;
	var x_step = x_speed / total_steps;
	var y_step = y_speed / total_steps;
	
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += cosine * x_step + sine * y_step;
		y += -sine * x_step + cosine * y_step;
		
		// Die if out of bounds
		if (not player_keep_in_bounds()) return player_perform(player_is_dead);
		
		// Detect instances and tilemaps
		player_get_collisions();
		
		// Handle wall collision
		var tile_data = player_beam_collision(solid_colliders);
		if (tile_data != noone and sign(x_speed) == player_eject_wall(tile_data))
		{
			x_speed = 0;
		}
		
		// Handle floor collision
		if (y_speed >= 0)
		{
			tile_data = player_find_floor(y_radius);
			if (tile_data != undefined)
			{
				landed = true;
				player_ground(tile_data);
				player_rotate_mask();
			}
		}
		else
		{
			// Handle ceiling collision
			tile_data = player_find_ceiling(y_radius);
			if (tile_data != undefined)
			{
				// Flip mask and land on the ceiling
				mask_direction = (mask_direction + 180) mod 360;
				landed = true;
				player_ground(tile_data);
				
				// Abort if rising slowly or the ceiling is too shallow
				if (y_speed > -4 or (local_direction >= 135 and local_direction <= 225))
				{
					// Slide against it
					sine = dsin(local_direction);
					cosine = dcos(local_direction);
					var g_speed = cosine * x_speed - sine * y_speed;
					x_speed = cosine * g_speed;
					y_speed = -sine * g_speed;
					
					// Revert mask rotation and exit loop
					mask_direction = gravity_direction;
					landed = false;
					break;
				}
			}
		}
		
		// Land
		if (landed)
		{
			// Calculate landing speed
			if (abs(x_speed) <= abs(y_speed) and local_direction >= 22.5 and local_direction <= 337.5)
			{
				x_speed = -y_speed * sign(dsin(local_direction));
				if (local_direction < 45 or local_direction > 315) x_speed *= 0.5;
			}
			
			// Stop falling and exit loop
			y_speed = 0;
			landed = false;
			on_ground = true;
			objCamera.on_ground = true;
			rolling = false;
			if (badnik_chain > 0 and invincibility_time == 0) badnik_chain = 0;
			break;
		}
	}
}