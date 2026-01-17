/// @description Scale
if (++scale != 4)
{
	if (scale == 1) window_set_fullscreen(false);
	window_set_size(CAMERA_WIDTH * scale, CAMERA_HEIGHT * scale);
	surface_resize(application_surface, CAMERA_WIDTH * scale, CAMERA_HEIGHT * scale);
	window_center();
}
else
{
	scale = 0;
	window_set_fullscreen(true);
	surface_resize(application_surface, display_get_width(), display_get_height());
}