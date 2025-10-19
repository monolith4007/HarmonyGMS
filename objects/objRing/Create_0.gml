/// @description Initialize
image_speed = 0;
reaction = function (inst)
{
	// Abort if not intersecting the ring
	if (not player_in_object(inst)) exit;
	
	// Collect
	player_gain_rings(1);
	with (inst)
	{
		particle_spawn("ring_sparkle", x, y);
		instance_destroy();
	}
};