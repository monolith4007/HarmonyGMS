/// @description Time
if (time_enabled and ++stage_time == time_limit)
{
	time_over = true;
	time_enabled = false;
	// TODO: kill player
}