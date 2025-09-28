/// @description Scroll
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID);

// Calculate offset from view center
var ox = x - (vx + CAMERA_WIDTH * 0.5);
var oy = y - (vy + CAMERA_HEIGHT * 0.5);

// Apply panning offsets
if (x_offset != 0 or y_offset != 0)
{
	var sine = dsin(gravity_direction);
	var cosine = dcos(gravity_direction);
	ox += cosine * x_offset + sine * y_offset;
	oy += -sine * x_offset + cosine * y_offset;
}

// Confine to borders
ox = max(abs(ox) - 8, 0) * sign(ox);
if (not on_ground) oy = max(abs(oy) - 32, 0) * sign(oy);

// Limit movement speed
var x_speed_cap = 16 * (alarm[0] == -1);
var y_speed_cap = min(6 + abs(y - yprevious), 16);
if (abs(ox) > x_speed_cap) ox = x_speed_cap * sign(ox);
if (abs(oy) > y_speed_cap) oy = y_speed_cap * sign(oy);

// Move the view
if (ox != 0 or oy != 0)
{
	ox = clamp(vx + ox, bound_left, bound_right - CAMERA_WIDTH);
	oy = clamp(vy + oy, bound_top, bound_bottom - CAMERA_HEIGHT);
	camera_set_view_pos(CAMERA_ID, ox, oy);
}