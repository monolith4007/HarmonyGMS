/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	// Abort if not intersecting
	if (not player_collision(inst)) exit;
	
	// Take damage if not in an attacking state
	if (not (rolling or invincibility_time > 0))
	{
		return player_damage(inst);
	}
	
	// Rebound
	if (y_speed > 0 and not player_part_collision(inst, -y_radius))
	{
		y_speed *= -1;
	}
	else y_speed -= sign(y_speed);
	
	// Score
	var bonus = 100;
	var index = 1;
	
	if (++badnik_chain > 15)
	{
		bonus = 10000;
		index = 5;
	}
	else if (badnik_chain > 3)
	{
		bonus = 1000;
		index = 4;
	}
	else if (badnik_chain > 2)
	{
		bonus = 500;
		index = 3;
	}
	else if (badnik_chain > 1)
	{
		bonus = 200;
		index = 2;
	}
	
	player_gain_score(bonus);
	part_type_subimage(global.sprite_particles.points, index);
	with (inst)
	{
		particle_spawn("points", x, y);
		particle_spawn("explosion", x, y);
		instance_destroy();
	}
	
	sound_play(sfxDestroy);
};