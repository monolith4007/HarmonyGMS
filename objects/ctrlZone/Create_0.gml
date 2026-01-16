/// @description Initialize
image_speed = 0;

// Timing
stage_time = 0;
time_limit = 36000;
time_over = false;
time_enabled = true;

//alarm[0] = 5;

// Identify stage and enqueue music
switch (room)
{
	case rmTest:
	{
		name = "DEMONSTRATION";
		act = 1;
		music_enqueue(bgmMadGear, 0);
		break;
	}
}

// Setup tilemaps; delist invalid ones
tilemaps =
[
	layer_tilemap_get_id("CollisionMain"),
	layer_tilemap_get_id("CollisionPlane0"),
	layer_tilemap_get_id("CollisionPlane1"),
	layer_tilemap_get_id("CollisionSemisolid")
];

if (tilemaps[3] == -1) array_pop(tilemaps);
if (tilemaps[1] == -1) array_delete(tilemaps, 1, 2);

// Create UI elements
instance_create_layer(0, 0, "Display", objHUD, { image_speed: 0 });