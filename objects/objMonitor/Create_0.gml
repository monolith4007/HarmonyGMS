/// @description Initialize
image_speed = 0;
tilemap = ctrlZone.tilemaps[0];
reaction = function (inst)
{
	//if (collision_point(x div 1, y div 1, inst, false, false) != noone) return player_perform(player_is_dead);
	if (not rolling) exit;
	
	// Knock down monitor / rebound
	if (y_speed < 0)
	{
		if (player_part_collision(inst, -y_radius))
		{
			with (inst)
			{
				vspeed = -2;
				gravity = 0.21875;
			}
		}
	}
	else if (player_part_collision(inst, y_radius) or player_beam_collision(inst) != noone)
	{
		sound_play(sfxDestroy);
		y_speed *= -1;
		
		// Disable monitor solidity and reaction
		with (inst)
		{
			semisolid = undefined;
			reaction = function () {};
			sprite_index = sprMonitorBroken;
			particle_spawn("explosion", x, y);
			
			// Fall if not on the ground
			if (not place_meeting(x, y + 2, tilemap)) gravity = 0.21875;
			
			// Create icon
			instance_create_layer(x, y - 5, layer, objMonitorIcon,
			{
				image_speed: 0,
				image_index: icon,
				vspeed: -3,
				gravity: 0.09375,
				alarm: 32,
				owner: other.id
			});
			
			/* AUTHOR NOTE: specifying an array index is not allowed inside structs,
			however, `alarm` defaults to `alarm[0]`. */
		}
	}
};