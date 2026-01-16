/// @description Time
if (time_enabled and ++stage_time == time_limit)
{
	time_over = true;
	with (objPlayer) player_perform(player_is_dead);
}