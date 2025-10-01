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
			/// @method get_cliff()
			/// @description Finds the direction of a cliff the player is standing on.
			var get_cliff = function()
			{
				// Initialize
				cliff_sign = 0;
				var edge = 0;
				var height = y_radius + y_tile_reach;
				
				for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
				{
					var inst = solid_objects[| n];
					
					// Check sensors
					if (player_leg_in_object(inst, 0, height)) exit; // Center collision means not on a cliff
					if (player_leg_in_object(inst, -x_radius, height)) edge |= 1; // Left
					if (player_leg_in_object(inst, x_radius, height)) edge |= 2; // Right
				}
				
				// Check if only one sensor is grounded
				if (edge != 3) cliff_sign = (edge == 1 ? 1 : -1);
			}
			
			rolling = false;
			get_cliff();
			
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
			if (control_lock_time == 0)
			{
				if (input_sign != 0)
				{
					// If moving in the opposite direction...
					if (x_speed != 0 and sign(x_speed) != input_sign)
					{
						// Decelerate and reverse direction
						x_speed += deceleration * input_sign;
						if (sign(x_speed) == input_sign) x_speed = deceleration * input_sign;
					}
					else
					{
						// Accelerate
						image_xscale = input_sign;
						if (abs(x_speed) < speed_cap)
						{
							x_speed += acceleration * input_sign;
							if (abs(x_speed) > speed_cap) x_speed = speed_cap * input_sign;
						}
					}
				}
				else
				{
					// Friction
					x_speed -= min(abs(x_speed), friction) * sign(x_speed);
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
			if (input_check(INPUT.DOWN) and input_sign == 0 and abs(x_speed) >= 1.03125)
			{
				sound_play(sfxRoll);
				return player_perform(player_is_rolling);
			}
			
			// Stand
			if (x_speed == 0 and input_sign == 0) return player_perform(player_is_standing);
			
			// Animate
			var velocity = abs(x_speed) div 1;
			var new_anim = (velocity < 6 ? "walk" : "run");
			if (animation_index != new_anim) player_animate(new_anim);
			timeline_speed = 1 / max(8 - velocity, 1);
			image_angle = direction;
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
				if (sign(x_speed) != input_sign)
				{
					x_speed += roll_deceleration * input_sign;
					if (sign(x_speed) == input_sign) x_speed = roll_deceleration * input_sign;
				}
				else image_xscale = input_sign;
				
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