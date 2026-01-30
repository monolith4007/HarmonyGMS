/// @description Land
if (vspeed > 0 and place_meeting(x, y + vspeed + 2, tilemap))
{
	while (not place_meeting(x, y + 2, tilemap))
	{
		++y;
	}
	vspeed = 0;
	gravity = 0;
}

/* AUTHOR NOTE:
> Ejection is not used, as you can actually see the monitor rise up from the floor.
> Tilemap collisions do not respect the Collision Compatibility Mode, so since the monitor's `bbox_bottom` is 1 pixel
smaller than its sprite height, the monitor ends up being 1 pixel deep into the floor; to address this, 2 pixels are checked downwards. */