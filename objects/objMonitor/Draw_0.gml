/// @description Draw
if (sprite_index == sprMonitorBroken)
{
	draw_self();
	exit;
}

var count = ctrlWindow.image_index;
draw_sprite(sprite_index, count div 2, x, y);
if (count mod 6 > 1) draw_sprite(sprMonitorIcons, icon, x, y - 5);