/// @description Initialize
image_speed = 0;

// State
state = 0;
previous_state = 0;

// Keyboard codes
keycodes = [vk_up, vk_down, vk_left, vk_right, ord("Z")];

/* AUTHOR NOTE: the index of each keycode and gamepad button MUST match its respective `INPUT` enum entry. */

// Gamepad data
gp_device = -1;
buttons = -1;
deadzone = 0.5;