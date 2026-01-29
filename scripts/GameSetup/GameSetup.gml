// Constants
#macro CAMERA_ID view_camera[0]
#macro CAMERA_PADDING 64
#macro CAMERA_WIDTH 400
#macro CAMERA_HEIGHT 224

#macro SLIDE_THRESHOLD 2.5
#macro SLIDE_DURATION 30
#macro AIR_DRAG_THRESHOLD 0.125
#macro AIR_DRAG 0.96875
#macro LOOK_DELAY 120

enum INPUT
{
	UP, DOWN, LEFT, RIGHT, ACTION
}

enum PHASE
{
	ENTER, STEP, EXIT
}

enum ICON
{
	RING, SNEAKER, INVINCIBILITY, ROBOTNIK, SUPER, LIGHTNING, FIRE, BUBBLE, LIFE
}

// Misc.
show_debug_overlay(true);
surface_depth_disable(true);
audio_channel_num(12);
randomize();

// Volumes
volume_sound = 1;
volume_music = 1;

// Player values
score = 0;
lives = 3;
rings = 0;

// Fonts
font_hud = font_add_sprite(sprFontHUD, ord("0"), false, 1);
font_lives = font_add_sprite(sprFontLives, ord("0"), false, 0);

// Setup particles
sprite_particles = {};
with (sprite_particles)
{
	system = part_system_create();
	
	ring_sparkle = part_type_create();
	part_type_life(ring_sparkle, 24, 24);
	part_type_sprite(ring_sparkle, sprRingSparkle, true, true, false);
	
	brake_dust = part_type_create();
	part_type_life(brake_dust, 16, 16);
	part_type_sprite(brake_dust, sprBrakeDust, true, true, false);
	
	explosion = part_type_create();
	part_type_life(explosion, 30, 30);
	part_type_sprite(explosion, sprExplosion, true, true, false);
	
	exhaust = part_type_create();
	part_type_life(exhaust, 16, 16);
	part_type_sprite(exhaust, sprExhaust, true, true, false);
	
	points = part_type_create();
	part_type_life(points, 32, 32);
	part_type_sprite(points, sprPoints, false, false, false);
	part_type_direction(points, 90, 90, 0, 0);
	part_type_gravity(points, 0.09375, 270);
	part_type_speed(points, 3, 3, 0, 0);
}

// Start the game!
call_later(1, time_source_units_frames, room_goto_next);

/* AUTHOR NOTE: `room_goto_next` executes at the end of the function/event it was called in,
meaning calling it here would result in the global controllers not being created.
Thus, it is instead called 1 frame later.

Note, however, this means the initialization room will be shown for that 1 frame.
Calling `room_goto_next` in the room's Creation Code does not address this, either. */