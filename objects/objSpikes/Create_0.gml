/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	// Get orientation relative to mask direction
	var rotation_offset = angle_wrap(inst.image_angle - mask_direction);
	var react = false;
	
	/* AUTHOR NOTE: it is assumed the `image_angle` will always be a multiple of 90. */
	
	// Take damage if touching the pointy side
	if (player_beam_collision(inst) != noone)
	{
		//if ((rotation_offset == 90 and x_speed > 0) or (rotation_offset == 270 and x_speed < 0))
		if (sign(x_speed) == dsin(rotation_offset))
		{
			react = true;
		}
	}
	else if (player_part_collision(inst, y_radius + on_ground))
	{
		if (rotation_offset == 0 and y_speed >= 0)
		{
			react = true;
		}
	}
	else if (player_part_collision(inst, -y_radius) and rotation_offset == 180 and y_speed < 0)
	{
		react = true;
	}
	
	if (react) player_damage(inst);
};