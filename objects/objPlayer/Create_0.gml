/// @description Initialize
image_speed = 0;

enum PHASE
{
	ENTER, STEP, EXIT
}

// State machine
state = player_is_ready;
state_changed = false;

rolling = false;
jump_action = false;

spindash_charge = 0;

// Timers
control_lock_time = 0;
superspeed_time = 0;
camera_look_time = 0;

slide_duration = 30;

// Physics
x_speed = 0;
y_speed = 0;

player_refresh_physics();

slide_threshold = 2.5;

air_drag_threshold = 0.125;
air_drag = 0.96875;

// Collision detection
x_radius = 8;
x_wall_radius = 10;

y_radius = 15;
y_tile_reach = 16;

on_ground = true;
ground_id = noone;

landed = false;
ground_snap = true;

direction = 0;
gravity_direction = 0;
local_direction = 0;
mask_direction = 0;

collision_layer = 1;

cliff_sign = 0;

solid_objects = ds_list_create();

// Animations
animations =
{
	idle: animSonicIdle,
	walk: animSonicWalk,
	run: animSonicRun,
	roll: animSonicRoll,
	look: animSonicLook,
	crouch: animSonicCrouch,
	spindash: animSonicSpindash,
	teeter: animSonicTeeter,
	brake: animSonicBrake
};

// Misc.
instance_create_layer(x, y, layer, objCamera, { gravity_direction });

/// @method player_perform(action)
/// @description Sets the given function as the player's current state.
/// @param {Function} action State function to set.
player_perform = function(action)
{
	state(PHASE.EXIT);
	state = action;
	state_changed = true;
	state(PHASE.ENTER);
}

/// @method player_rotate_mask()
/// @description Rotates the player's virtual mask, if applicable.
player_rotate_mask = function()
{
	static rotation_lock_time = 0;
	if (rotation_lock_time > 0) then --rotation_lock_time;
	
	var new_rotation = (round(direction / 90) mod 4) * 90;
	if (mask_direction != new_rotation and (landed or rotation_lock_time == 0))
	{
		mask_direction = new_rotation;
		if (not landed) rotation_lock_time = max(16 - abs(x_speed * 2) div 1, 0);
	}
}

/// @method player_resist_slope(force)
/// @description Applies slope friction to the player's horizontal speed, if appropriate.
/// @param {Real} force Friction value to use.
player_resist_slope = function(force)
{
	// Abort if...
	if (x_speed == 0 and control_lock_time == 0) exit; // Not moving
	if (local_direction < 22.5 or local_direction > 337.5) exit; // Moving along a shallow slope
	if (local_direction >= 135 and local_direction <= 225) exit; // Attached to a ceiling
	
	// Apply
	x_speed -= dsin(local_direction) * force;
}

/// @method player_animate(name)
/// @description Sets the player's current animation to the given string, and their timeline to that which matches it.
/// @param {String} name Animation to set.
player_animate = function(name)
{
	animation_index = name;
	timeline_index = animations[$ name];
	timeline_position = 0;
}

/// @method player_gain_rings(num)
/// @description Increases the player's ring count by the given amount.
/// @param {Real} num Amount of rings to give.
player_gain_rings = function(num)
{
	global.rings = min(global.rings + num, 999);
	sound_play(sfxRing);
	
	// Gain lives
	static ring_life_threshold = 100;
	if (global.rings >= ring_life_threshold)
	{
		var change = global.rings div 100;
		player_gain_lives(change);
		ring_life_threshold += change * 100;
	}
}

/// @method player_gain_lives(num)
/// @description Increases the player's life count by the given amount.
/// @param {Real} num Amount of lives to give.
player_gain_lives = function(num)
{
	lives = min(lives + num, 99);
	music_overlay(bgmLife);
}