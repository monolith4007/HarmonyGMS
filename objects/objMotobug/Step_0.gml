/// @description Move
var wall_offset = 2;

// Horizontal
if (place_meeting(x + hspeed, y - wall_offset, tilemap))
{
	image_speed = 0;
	hspeed = 0;
	alarm[0] = room_speed;
}

// Vertical
if (place_meeting(x, y + wall_offset, tilemap))
{
	if (place_meeting(x, y, tilemap))
	{
		--y;
	}
	else if (not place_meeting(x, y + 1, tilemap))
	{
		++y;
	}
}

// Vent
if (hspeed != 0 and x mod 16 == 0) //ctrlWindow.image_index mod 16 == 0)
{
	particle_spawn("exhaust", x - 20 * image_xscale, y);
}