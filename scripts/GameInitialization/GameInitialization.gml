// Macros
#macro CAMERA_ID view_camera[0]
#macro CAMERA_PADDING 64
#macro CAMERA_WIDTH 400
#macro CAMERA_HEIGHT 224

// Misc.
surface_depth_disable(true);
randomize();
audio_channel_num(16);

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
}

// Create global controllers
call_later(1, time_source_units_frames, function ()
{
	instance_create_layer(0, 0, "Controllers", ctrlWindow);
	instance_create_layer(0, 0, "Controllers", ctrlInput);
	instance_create_layer(0, 0, "Controllers", ctrlMusic);
	
	music_enqueue(bgmMadGear, 0);
});

/* AUTHOR NOTE: this must be done one frame later as the first room will not have loaded yet.
Due to this, for testing purposes, the Mad Gear track is enqueued here. */