/// @function player_move_on_ground()
/// @description Updates the player's position on the ground and checks for collisions.
function player_move_on_ground()
{
	// Ride moving platforms
	with (ground_id)
	{
		var dx = x - xprevious;
		var dy = y - yprevious;
		if (dx != 0) other.x += dx;
		if (dy != 0) other.y += dy;
	}
	
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
		player_register_zone_objects();
		
		// Handle wall collision
		var inst = player_get_wall();
		if (inst != noone and sign(x_speed) == player_eject_wall(inst))
		{
			x_speed = 0;
		}
		
		// Handle floor collision
		if (on_ground)
		{
			inst = player_get_floor(ground_snap ? y_radius + y_snap_height : y_radius + 1);
			if (inst != noone)
			{
				player_ground(inst);
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
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		var sine = dsin(direction);
		var cosine = dcos(direction);
		x += cosine * x_step + sine * y_step;
		y += -sine * x_step + cosine * y_step;
		player_in_bounds();
		
		// Register nearby instances
		player_register_zone_objects();
		
		// Handle wall collision
		var inst = player_get_wall();
		if (inst != noone and sign(x_speed) == player_eject_wall(inst))
		{
			x_speed = 0;
		}
		
		// Handle floor collision
		if (y_speed >= 0)
		{
			inst = player_get_floor(y_radius);
			if (inst != noone)
			{
				landed = true;
				player_ground(inst);
				player_rotate_mask();
			}
		}
		else
		{
			// Handle ceiling collision
			inst = player_get_ceiling(y_radius);
			if (inst != noone)
			{
				// Flip mask and land on the ceiling
				mask_direction = (mask_direction + 180) mod 360;
				landed = true;
				player_ground(inst);
				
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
					player_ground(noone);
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
	
	// Calculate the number of steps for collision checking
	/*var total_steps = 1 + (abs(x_speed) div x_radius);
	var step = x_speed / total_steps;
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += dcos(direction) * step;
		y -= dsin(direction) * step;
		player_in_bounds();
		
		// Register nearby instances
		player_register_zone_objects();
		
		// Handle wall collision
		var inst = player_get_wall();
		if (inst != noone and sign(x_speed) == player_eject_wall(inst))
		{
			x_speed = 0;
		}
	}
	
	// Calculate the number of steps for collision checking
	total_steps = 1 + (abs(y_speed) div y_radius);
	step = y_speed / total_steps;
	
	// Loop over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += dsin(direction) * step;
		y += dcos(direction) * step;
		player_in_bounds();
		
		// Register nearby instances
		player_register_zone_objects();
		
		// Handle ground collision
		if (y_speed >= 0)
		{
			inst = player_get_floor(y_radius);
			if (inst != noone)
			{
				landed = true;
				player_ground(inst);
				player_rotate_mask();
			}
		}
		else
		{
			// Handle ceiling collision
			inst = player_get_ceiling(y_radius);
			if (inst != noone)
			{
				// Flip mask and land on the ceiling
				mask_direction = (mask_direction + 180) mod 360;
				landed = true;
				player_ground(inst);
				
				// Abort if rising slowly or the ceiling is too shallow
				if (y_speed > -4 or (local_direction >= 135 and local_direction <= 225))
				{
					// Slide against it
					var sine = dsin(local_direction);
					var cosine = dcos(local_direction);
					var g_speed = (cosine * x_speed) - (sine * y_speed);
					x_speed = cosine * g_speed;
					y_speed = -sine * g_speed;
					
					// Detach and exit movement step
					landed = false;
					player_ground(noone);
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
		
		// Handle wall collision again
		inst = player_get_wall();
		if (inst != noone) player_eject_wall(inst);
	}*/
}