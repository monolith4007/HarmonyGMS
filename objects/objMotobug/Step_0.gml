/// @description Move
var wall_offset = 2;

// Horizontal
if (place_meeting(x + hspeed, y - wall_offset, tilemaps))
{
	image_speed = 0;
	hspeed = 0;
	alarm[0] = room_speed;
}

// Vertical
if (place_meeting(x, y + wall_offset, tilemaps))
{
	if (place_meeting(x, y, tilemaps))
	{
		--y;
	}
	else if (not place_meeting(x, y + 1, tilemaps))
	{
		++y;
	}
}

// Vent
if (hspeed != 0 and ctrlWindow.image_index mod 16 == 0)
{
	particle_spawn("exhaust", x - 20 * image_xscale, y);
}