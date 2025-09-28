/// @description Debug
draw_text(10, 10, $"State: {script_get_name(state)}");
draw_text(10, 28, $"Speed: {string_format(x_speed, 3, 2)} | {string_format(y_speed, 3, 2)}");
draw_text(10, 46, $"Direction: {string_format(direction, 3, 0)} | {string_format(local_direction, 3, 0)}");
draw_text(10, 64, $"Mask Direction: {mask_direction}");
draw_text(10, 82, $"Control Lock: {control_lock_time}");
draw_text(10, 100, $"Facing: {image_xscale}");
draw_text(10, 118, $"Spindash Charge: {spindash_charge}");
draw_text(10, 136, $"Rings: {global.rings}");