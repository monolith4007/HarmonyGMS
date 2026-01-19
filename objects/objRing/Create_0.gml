/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	// Abort if recovering or not intersecting
	if (recovery_time > 90 or state == player_is_hurt or not player_collision(inst)) exit;
	
	// Collect
	player_gain_rings(1);
	with (inst)
	{
		particle_spawn("ring_sparkle", x, y);
		instance_destroy();
	}
};