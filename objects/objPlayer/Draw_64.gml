/// @description Debug
draw_set_font(-1);
draw_set_halign(fa_right);

draw_text_transformed(CAMERA_WIDTH - 10, 10, $"State: {script_get_name(state)}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 25, $"Speed: {string_format(x_speed, 3, 2)} | {string_format(y_speed, 3, 2)}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 43, $"Direction: {string_format(direction, 3, 0)} | {string_format(local_direction, 3, 0)}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 61, $"Mask Direction: {mask_direction}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 79, $"Rotation Lock: {rotation_lock_time}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 97, $"Control Lock: {control_lock_time}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 115, $"Facing: {image_xscale}", 0.5, 0.5, 0);
draw_text_transformed(CAMERA_WIDTH - 10, 133, $"Rolling: {rolling}", 0.5, 0.5, 0);

draw_set_halign(fa_left);