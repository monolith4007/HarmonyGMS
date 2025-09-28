/// @description Register
previous_state = state;
state = 0;

// Keyboard input
array_foreach(keycodes, function(const, command)
{
	if (keyboard_check(const))
	{
		state |= 1 << command;
	}
});

// Gamepad input
if (gp_device != -1)
{
	// Buttons
	array_foreach(buttons, function(const, command)
	{
		if (gamepad_button_check(gp_device, const))
		{
			state |= 1 << command;
		}
	});
	
	// Left analog stick
	var haxis = gamepad_axis_value(gp_device, gp_axislh);
	var vaxis = gamepad_axis_value(gp_device, gp_axislv);
	
	if (abs(haxis) > deadzone)
	{
		state |= 1 << (haxis < 0 ? INPUT.LEFT : INPUT.RIGHT);
	}
	if (abs(vaxis) > deadzone)
	{
		state |= 1 << (vaxis < 0 ? INPUT.UP : INPUT.DOWN);
	}
}