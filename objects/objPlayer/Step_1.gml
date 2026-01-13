/// @description Count
if (control_lock_time > 0 and on_ground)
{
	--control_lock_time;
}

if (recovery_time > 0 and --recovery_time mod 4 == 0)
{
	image_alpha ^= 1;
}

if (superspeed_time > 0 and --superspeed_time == 0)
{
	player_refresh_physics();
}

if (invincibility_time > 0 and --invincibility_time == 0)
{
	// TODO: add invincibility sparkles & BGM, and remove them here
	
	if (badnik_chain > 0 and not rolling) badnik_chain = 0;
}