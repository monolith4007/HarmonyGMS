/// @description Render
var time = ctrlZone.stage_time;
var flash = time mod 16 < 8;

// Lives
draw_sprite(sprLifeIcon, 0, 16, CAMERA_HEIGHT - 24);

// Main HUD
draw_sprite(sprHUD, 0, 16, 9);
if (time < 32400 or flash) // 32400 frames = 9 minutes
{
	draw_sprite(sprHUD, 1, 16, 25);
}
if (global.rings > 0 or flash)
{
	draw_sprite(sprHUD, 2, 16, 41);
}

// Lives text
draw_set_halign(fa_right);
draw_set_font(global.font_lives);
draw_text(64, CAMERA_HEIGHT - 15, lives);

// Score and rings text
draw_set_font(global.font_hud);
draw_text(112, 9, score);
draw_text(88, 41, global.rings);

// Timestamp
var minutes = time div 3600;
var seconds = (time div 60) mod 60;
var centiseconds = floor(time / 0.6) mod 100;

draw_set_halign(fa_left);
draw_text(56, 25, $"{minutes}:{seconds < 10 ? 0 : ""}{seconds}:{centiseconds < 10 ? 0 : ""}{centiseconds}");

/* AUTHOR NOTE: for obvious reasons, the divisions for the timestamp do not respect the game framerate. */