/// @description Initialize
image_speed = 0;

// State machine
state = player_is_ready;
state_changed = false;

rolling = false;
jump_action = false;

spindash_charge = 0;

badnik_chain = 0;

// Timers
rotation_lock_time = 0;
control_lock_time = 0;
recovery_time = 0;
superspeed_time = 0;
invincibility_time = 0;
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

landed = false;
on_ground = true;
//ground_snap = true;

direction = 0;
gravity_direction = 0;
local_direction = 0;
mask_direction = 0;

/* AUTHOR NOTE: "down" is treated as 0 degrees instead of 270. */

cliff_sign = 0;

collision_layer = 0;

// Copy the stage's tilemaps
solid_entities = variable_clone(ctrlZone.tilemaps, 0);
tilemap_count = array_length(solid_entities);

// Validate semisolid tilemap; if it exists, the tilemap count is even
semisolid_tilemap = -1;
if (tilemap_count & 1 == 0)
{
	semisolid_tilemap = array_last(solid_entities);
	--tilemap_count;
}

// Discard the "CollisionPlane1" layer tilemap, if it exists
if (tilemap_count == 3)
{
	array_delete(solid_entities, 2, 1);
	--tilemap_count;
}

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
	brake: animSonicBrake,
	hurt: animSonicHurt
};

// Misc.
instance_create_layer(x, y, layer, objCamera, { gravity_direction });

/// @method player_perform(action)
/// @description Sets the given function as the player's current state.
/// @param {Function} action State function to set.
player_perform = function (action)
{
	state(PHASE.EXIT);
	state = action;
	state_changed = true;
	state(PHASE.ENTER);
};

/// @method player_rotate_mask()
/// @description Rotates the player's virtual mask, if applicable.
player_rotate_mask = function ()
{
	if (rotation_lock_time > 0 and not landed)
	{
		--rotation_lock_time;
		exit;
	}
	
	var new_rotation = round(direction / 90) mod 4 * 90;
	if (mask_direction != new_rotation)
	{
		mask_direction = new_rotation;
		rotation_lock_time = (not landed) * max(16 - abs(x_speed * 2) div 1, 0);
	}
};

/// @method player_resist_slope(force)
/// @description Applies slope friction to the player's horizontal speed, if appropriate.
/// @param {Real} force Friction value to use.
player_resist_slope = function (force)
{
	// Abort if...
	if (x_speed == 0 and control_lock_time == 0) exit; // Not moving
	if (local_direction < 22.5 or local_direction > 337.5) exit; // Moving along a shallow slope
	if (local_direction >= 135 and local_direction <= 225) exit; // Attached to a ceiling
	
	// Apply
	x_speed -= dsin(local_direction) * force;
};

/// @method player_animate(name)
/// @description Sets the player's current animation to the given string, and their timeline to that which matches it.
/// @param {String} name Animation to set.
player_animate = function (name)
{
	animation = name;
	timeline_index = animations[$ name];
	timeline_position = 0;
};

/// @method player_gain_rings(num)
/// @description Increases the player's ring count by the given amount.
/// @param {Real} num Amount of rings to give.
player_gain_rings = function (num)
{
	global.rings = min(global.rings + num, 999);
	sound_play(sfxRing);
	
	// Gain lives
	static ring_life_threshold = 99;
	if (global.rings > ring_life_threshold)
	{
		var change = global.rings div 100;
		player_gain_lives(change - ring_life_threshold div 100);
		ring_life_threshold = change * 100 + 99;
	}
};

/// @method player_gain_lives(num)
/// @description Increases the player's life count by the given amount.
/// @param {Real} num Amount of lives to give.
player_gain_lives = function (num)
{
	lives = min(lives + num, 99);
	music_overlay(bgmLife);
};

/// @method player_damage(inst)
/// @description Evaluates the player's condition after taking a hit.
/// @param {Id.Instance} inst Instance to recoil from.
player_damage = function (inst)
{
	// Abort if already invulnerable in any way
	if (recovery_time > 0 or invincibility_time > 0 or state == player_is_hurt) exit;
	
	if (global.rings > 0)
	{
		player_perform(player_is_hurt);
		
		// Recoil
		x_speed = 2 * (gravity_direction mod 180 == 0 ?
			sign(x - inst.x) * dcos(gravity_direction) :
			sign(inst.y - y) * dsin(gravity_direction));
		
		if (x_speed == 0) x_speed = 2;
		y_speed = -4;
	}
	
	/* TODO:
	- Check for shields (once they've been added).
	- Add dropped rings, and toss them.
	- Add death state. */
};