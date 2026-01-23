/// @function player_is_falling(phase)
function player_is_falling(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			// Rise
			y_speed = -dsin(local_direction) * x_speed;
			x_speed *= dcos(local_direction);
			
			// Detach from ground
			player_ground(undefined);
			break;
		}
		case PHASE.STEP:
		{
			// Accelerate
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			if (input_sign != 0)
			{
				image_xscale = input_sign;
				if (abs(x_speed) < speed_cap or sign(x_speed) != input_sign)
				{
					x_speed += air_acceleration * input_sign;
					if (abs(x_speed) > speed_cap and sign(x_speed) == input_sign)
					{
						x_speed = speed_cap * input_sign;
					}
				}
			}
			
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground) return player_perform(x_speed != 0 ? player_is_running : player_is_standing);
			
			// Apply air resistance
			if (y_speed < 0 and y_speed > -4 and abs(x_speed) > AIR_DRAG_THRESHOLD)
			{
				x_speed *= AIR_DRAG;
			}
			
			// Fall
			if (y_speed < gravity_cap)
			{
				y_speed = min(y_speed + gravity_force, gravity_cap);
			}
			
			// Straighten
			if (image_angle != mask_direction)
			{
				var diff = angle_difference(mask_direction, image_angle);
				image_angle += min(2.8125, abs(diff)) * sign(diff);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_jumping(phase)
function player_is_jumping(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			// Set flags
			rolling = true;
			jump_action = true;
			
			// Leap
			var sine = dsin(local_direction);
			var cosine = dcos(local_direction);
			y_speed = -sine * x_speed - cosine * jump_height;
			x_speed = cosine * x_speed - sine * jump_height;
			
			// Detach from ground
			player_ground(undefined);
			
			// Animate
			player_animate("roll");
			timeline_speed = 1 / max(5 - abs(x_speed) div 1, 1);
			image_angle = gravity_direction;
			
			// Sound
			sound_play(sfxJump);
			break;
		}
		case PHASE.STEP:
		{
			// Accelerate
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			if (input_sign != 0)
			{
				image_xscale = input_sign;
				if (abs(x_speed) < speed_cap or sign(x_speed) != input_sign)
				{
					x_speed += air_acceleration * input_sign;
					if (abs(x_speed) > speed_cap and sign(x_speed) == input_sign)
					{
						x_speed = speed_cap * input_sign;
					}
				}
			}
			
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground) return player_perform(x_speed != 0 ? player_is_running : player_is_standing);
			
			// Lower height
			if (y_speed < -jump_release and not input_check(INPUT.ACTION))
			{
				y_speed = -jump_release;
			}
			
			// Apply air resistance
			if (y_speed < 0 and y_speed > -4 and abs(x_speed) > AIR_DRAG_THRESHOLD)
			{
				x_speed *= AIR_DRAG;
			}
			
			// Fall
			if (y_speed < gravity_cap)
			{
				y_speed = min(y_speed + gravity_force, gravity_cap);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_hurt(phase)
function player_is_hurt(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			player_ground(undefined);
			
			// Animate
			player_animate("hurt");
			timeline_speed = 1;
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground)
			{
				x_speed = 0;
				return player_perform(player_is_standing);
			}
			
			// Fall
			if (y_speed < gravity_cap)
			{
				y_speed = min(y_speed + recoil_gravity, gravity_cap);
			}
			break;
		}
		case PHASE.EXIT:
		{
			recovery_time = 120;
			break;
		}
	}
}

/// @function player_is_dead(phase)
function player_is_dead(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			y_speed = -7;
			ctrlZone.time_enabled = false;
			instance_destroy(objCamera);
			sound_play(sfxDeath);
			
			// Animate
			player_animate("dead");
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Move
			x += dsin(image_angle) * y_speed;
			y += dcos(image_angle) * y_speed;
			y_speed += gravity_force;
			
			// Restart (TODO: add fading and game over)
			if (y_speed > 3 and not instance_in_view())
			{
				//--lives;
				call_later(1, time_source_units_seconds, room_restart);
				instance_destroy();
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}