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
		player_in_bounds(); // TODO: add death state and call it if this is false
		
		// Register nearby instances
		player_detect_entities();
		
		// Handle wall collision
		var tile_data = player_find_wall();
		if (tile_data != noone and sign(x_speed) == player_eject_wall(tile_data))
		{
			x_speed = 0;
		}
		
		// Handle floor collision
		if (on_ground)
		{
			tile_data = player_find_floor(ground_snap ? y_radius + y_tile_reach : y_radius + 1);
			if (tile_data != undefined)
			{
				player_ground(tile_data);
				player_rotate_mask();
			}
			else on_ground = false;
		}
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
	var sine = dsin(direction);
	var cosine = dcos(direction);
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += cosine * x_step + sine * y_step;
		y += -sine * x_step + cosine * y_step;
		player_in_bounds();
		
		// Register nearby instances
		player_detect_entities();
		
		// Handle wall collision
		var tile_data = player_find_wall();
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
					
					// Detach and exit loop
					landed = false;
					player_ground(undefined);
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
			objCamera.on_ground = true;
			break;
		}
	}
}