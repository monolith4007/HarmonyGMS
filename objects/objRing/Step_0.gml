/// @description Move / Animate
if (image_speed == 0)
{
	image_index = ctrlWindow.image_index div 8;
	exit;
}

if (not instance_in_view( , CAMERA_PADDING * 0.5))
{
	instance_destroy();
	exit;
}

/* AUTHOR NOTE: the variables below are initialized in the `player_drop_rings` method. */

// Move horizontally
var ox = cosine * x_speed;
var oy = sine * x_speed;
x += ox;
y -= oy;

// Bounce
var inst = instance_place(x, y, tilemaps);
if (inst != noone and not place_meeting(xprevious, yprevious, inst))
{
	repeat (sprite_width)
	{
		if (place_meeting(x, y, inst))
		{
			x -= sign(ox);
			y += sign(oy);
		}
		else
		{
			x_speed *= -0.25;
			break;
		}
	}
}

// Move vertically
ox = sine * y_speed;
oy = cosine * y_speed;
x += ox;
y += oy;

// Bounce
inst = instance_place(x, y, tilemaps);
if (inst != noone and not place_meeting(xprevious, yprevious, inst))
{
	repeat (sprite_height)
	{
		if (place_meeting(x, y, inst))
		{
			x -= sign(ox);
			y -= sign(oy);
		}
		else
		{
			y_speed *= -0.75;
			break;
		}
	}
}

// Fall
y_speed += gravity_force;

// Animate
image_speed -= 0.002;
if (alarm[0] < 64) visible ^= 1;