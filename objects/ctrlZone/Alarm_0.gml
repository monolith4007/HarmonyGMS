/// @description Cull
instance_deactivate_object(objZoneObject);

// Activate instances inside the view
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID);
instance_activate_region(vx - CAMERA_PADDING, vy - CAMERA_PADDING, CAMERA_WIDTH + CAMERA_PADDING * 2, CAMERA_HEIGHT + CAMERA_PADDING * 2, true);

// Activate instances around the player
with (objPlayer)
{
	if (not instance_in_view())
	{
		instance_activate_region(x - CAMERA_PADDING, y - CAMERA_PADDING, CAMERA_PADDING * 2, CAMERA_PADDING * 2, true);
	}
}

// Repeat
alarm[0] = 3;