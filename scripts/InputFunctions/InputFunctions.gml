/// @function input_check(command)
/// @description Checks if the given command was registered this frame.
/// @param {Enum.INPUT} command Input command constant.
/// @returns {Bool}
function input_check(command)
{
	with (ctrlInput)
	{
		var bit = 1 << command;
		return (state & bit) != 0;
	}
}

/// @function input_check_pressed(command)
/// @description Checks if the given command was registered this frame and not last frame.
/// @param {Enum.INPUT} command Input command constant.
/// @returns {Bool}
function input_check_pressed(command)
{
	with (ctrlInput)
	{
		var bit = 1 << command;
		return (state & bit) != 0 and (previous_state & bit) == 0;
	}
}

/// @function input_check_released(command)
/// @description Checks if the given command was registered last frame and not this frame.
/// @param {Enum.INPUT} command Input command constant.
/// @returns {Bool}
function input_check_released(command)
{
	with (ctrlInput)
	{
		var bit = 1 << command;
		return (previous_state & bit) != 0 and (state & bit) == 0;
	}
}