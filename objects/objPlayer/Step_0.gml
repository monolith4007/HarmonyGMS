/// @description Behave
state(PHASE.STEP);
if (state_changed) state_changed = false;

// Direct camera
with (objCamera)
{
	x = other.x div 1;
	y = other.y div 1;
	
	// Center
	if (y_offset != 0)
	{
		var action = other.state;
		if ((action != player_is_looking and action != player_is_crouching) or other.camera_look_time > 0)
		{
			y_offset -= 2 * sign(y_offset);
		}
	}
}