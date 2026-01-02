/// @function player_is_ready(phase)
function player_is_ready(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			break;
		}
		case PHASE.STEP:
		{
			timeline_running = true;
			player_perform(player_is_standing);
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_standing(phase)
function player_is_standing(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = false;
			
			// Check if standing on a cliff
			cliff_sign = 0;
			var height = y_radius + y_tile_reach;
			if (not player_ray_collision(solid_entities, 0, height))
			{
				cliff_sign = player_ray_collision(solid_entities, -x_radius, height) -
					player_ray_collision(solid_entities, x_radius, height);
			}
			
			// Animate
			player_animate(cliff_sign != 0 ? "teeter" : "idle");
			timeline_speed = 1;
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if (input_check(INPUT.LEFT) or input_check(INPUT.RIGHT) or x_speed != 0)
			{
				return player_perform(player_is_running);
			}
			
			// Look / crouch
			if (cliff_sign == 0)
			{
				if (input_check(INPUT.UP)) return player_perform(player_is_looking);
				if (input_check(INPUT.DOWN)) return player_perform(player_is_crouching);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_running(phase)
function player_is_running(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = false;
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Handle ground motion
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			var can_brake = (animation == "brake");
			
			if (control_lock_time == 0)
			{
				if (input_sign != 0)
				{
					// If moving in the opposite direction...
					if (x_speed != 0 and sign(x_speed) != input_sign)
					{
						// Decelerate and reverse direction
						can_brake = true;
						x_speed += deceleration * input_sign;
						if (sign(x_speed) == input_sign) x_speed = deceleration * input_sign;
					}
					else
					{
						// Accelerate
						can_brake = false;
						image_xscale = input_sign;
						if (abs(x_speed) < speed_cap)
						{
							x_speed = min(abs(x_speed) + acceleration, speed_cap) * input_sign;
						}
					}
				}
				else
				{
					// Friction
					x_speed -= min(abs(x_speed), acceleration) * sign(x_speed);
					
					/* AUTHOR NOTE: the values for friction and acceleration are the same in the 16-bit Genesis games. */
				}
			}
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground) return player_perform(player_is_falling);
			
			// Slide down steep slopes
			if (abs(x_speed) < slide_threshold)
			{
				if (local_direction >= 90 and local_direction <= 270)
				{
					return player_perform(player_is_falling);
				}
				else if (local_direction >= 45 and local_direction <= 315)
				{
					control_lock_time = slide_duration;
				}
			}
			
			// Apply slope friction
			player_resist_slope(0.125);
			
			// Roll
			var velocity = abs(x_speed);
			if (input_sign == 0 and velocity >= 1.03125 and input_check(INPUT.DOWN))
			{
				sound_play(sfxRoll);
				return player_perform(player_is_rolling);
			}
			
			// Stand
			if (x_speed == 0 and input_sign == 0) return player_perform(player_is_standing);
			
			// Brake
			if (can_brake and mask_direction == gravity_direction and velocity >= 4 and animation != "brake")
			{
				player_animate("brake");
				timeline_speed = 1;
				image_angle = gravity_direction;
				image_xscale = -input_sign;
				sound_play(sfxBrake);
			}
			
			// Animate
			if (can_brake and animation == "brake" and mask_direction == gravity_direction and timeline_position < timeline_max_moment(timeline_index))
			{
				if (timeline_position mod 4 == 0)
				{
					// Kick up dust
					var offset = y_radius - 6;
					var ox = x + dsin(direction) * offset;
					var oy = y + dcos(direction) * offset;
					particle_spawn("brake_dust", ox, oy);
				}
			}
			else
			{
				var new_anim = (velocity < 6 ? "walk" : "run");
				if (animation != new_anim) player_animate(new_anim);
				timeline_speed = 1 / max(8 - velocity div 1, 1);
				image_angle = direction;
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_looking(phase)
function player_is_looking(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			camera_look_time = 120;
			player_animate("look");
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if (x_speed != 0) return player_perform(player_is_running);
			
			// Stand
			if (not input_check(INPUT.UP)) return player_perform(player_is_standing);
			
			// Ascend camera
			if (camera_look_time > 0)
			{
				--camera_look_time;
			}
			else with (objCamera)
			{
				if (y_offset > -104) y_offset -= 2;
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_crouching(phase)
function player_is_crouching(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			camera_look_time = 120;
			player_animate("crouch");
			break;
		}
		case PHASE.STEP:
		{
			// Spindash
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_spindashing);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if (x_speed != 0) return player_perform(player_is_running);
			
			// Stand
			if (not input_check(INPUT.DOWN)) return player_perform(player_is_standing);
			
			// Descend camera
			if (camera_look_time > 0)
			{
				--camera_look_time;
			}
			else with (objCamera)
			{
				if (y_offset < 88) y_offset += 2;
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_rolling(phase)
function player_is_rolling(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = true;
			player_animate("roll");
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Decelerate
			if (control_lock_time == 0)
			{
				var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
				if (input_sign != 0)
				{
					if (sign(x_speed) != input_sign)
					{
						x_speed += roll_deceleration * input_sign;
						if (sign(x_speed) == input_sign) x_speed = roll_deceleration * input_sign;
					}
					else image_xscale = input_sign;
				}
				
				// Friction
				x_speed -= min(abs(x_speed), roll_friction) * sign(x_speed);
			}
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground) return player_perform(player_is_falling);
			
			// Slide down steep slopes
			if (abs(x_speed) < slide_threshold)
			{
				if (local_direction >= 90 and local_direction <= 270)
				{
					return player_perform(player_is_falling);
				}
				else if (local_direction >= 45 and local_direction <= 315)
				{
					control_lock_time = slide_duration;
				}
			}
			
			// Apply slope friction
			var friction_uphill = 0.078125;
			var friction_downhill = 0.3125;
			var slope_friction = (sign(x_speed) == sign(dsin(local_direction)) ? friction_uphill : friction_downhill);
			player_resist_slope(slope_friction);
			
			// Unroll
			if (abs(x_speed) < 0.5) return player_perform(player_is_running);
			
			// Animate
			timeline_speed = 1 / max(5 - abs(x_speed) div 1, 1);
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

/// @function player_is_spindashing(phase)
function player_is_spindashing(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = true;
			spindash_charge = 0;
			player_animate("spindash");
			sound_play(sfxSpinRev);
			break;
		}
		case PHASE.STEP:
		{
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_rolling);
			}
			
			// Roll
			if (not input_check(INPUT.DOWN))
			{
				x_speed = image_xscale * (8 + spindash_charge div 2);
				objCamera.alarm[0] = 16;
				audio_stop_sound(sfxSpinRev);
				sound_play(sfxSpinDash);
				return player_perform(player_is_rolling);
			}
			
			// Charge / atrophy
			if (input_check_pressed(INPUT.ACTION))
			{
				spindash_charge = min(spindash_charge + 2, 8);
				
				// Sound
				var rev_sound = sound_play(sfxSpinRev);
				audio_sound_pitch(rev_sound, 1 + spindash_charge * 0.0625);
			}
			else spindash_charge *= 0.96875;
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}