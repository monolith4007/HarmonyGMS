/// @description Initialize
image_speed = 0;
reaction = function(inst)
{
	// Abort if not intersecting the ring
	if (not player_in_object(inst)) exit;
	
	// TODO: expand this by adding lives
	++global.rings;
	particle_spawn("ring_sparkle", inst.x, inst.y);
	sound_play(sfxRing);
	instance_destroy(inst);
}