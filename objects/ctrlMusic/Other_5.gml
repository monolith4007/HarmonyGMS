/// @description Stop
audio_stop_all();
ds_priority_clear(queue);
if (overlay != -1)
{
	overlay = -1;
	alarm[0] = -1;
}