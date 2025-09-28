/// @function player_in_object(obj)
/// @description Checks if the given instance's mask intersects the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance} obj Object or instance to check.
/// @returns {Bool}
function player_in_object(obj)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	return (mask_direction mod 180 != 0 ?
		collision_rectangle(x_int - y_radius, y_int - x_radius, x_int + y_radius, y_int + x_radius, obj, true, false) != noone :
		collision_rectangle(x_int - x_radius, y_int - y_radius, x_int + x_radius, y_int + y_radius, obj, true, false) != noone);
}

/// @function player_arms_in_object(obj)
/// @description Checks if the given instance's mask intersects the sides of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance} obj Object or instance to check.
/// @returns {Bool}
function player_arms_in_object(obj)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	return (mask_direction mod 180 != 0 ?
		collision_line(x_int, y_int - x_wall_radius, x_int, y_int + x_wall_radius, obj, true, false) != noone :
		collision_line(x_int - x_wall_radius, y_int, x_int + x_wall_radius, y_int, obj, true, false) != noone);
}

/// @function player_body_in_object(obj, ylen)
/// @description Checks if the given instance's mask intersects the upper or lower half of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance} obj Object or instance to check.
/// @param {Real} ylen Distance in pixels to extend the player's mask vertically.
/// @returns {Bool}
function player_body_in_object(obj, ylen)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int - cosine * x_radius;
	var y1 = y_int + sine * x_radius;
	var x2 = x_int + cosine * x_radius + sine * ylen;
	var y2 = y_int - sine * x_radius + cosine * ylen;
	
	return collision_rectangle(x1, y1, x2, y2, obj, true, false) != noone;
}

/// @function player_leg_in_object(obj, xoff, ylen)
/// @description Checks if the given instance's mask intersects a line from the player's position.
/// @param {Asset.GMObject|Id.Instance} obj Object or instance to check.
/// @param {Real} xoff Distance in pixels to offset the line horizontally.
/// @param {Real} ylen Distance in pixels to extend the line downward.
/// @returns {Bool}
function player_leg_in_object(obj, xoff, ylen)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int + cosine * xoff;
	var y1 = y_int - sine * xoff;
	var x2 = x_int + cosine * xoff + sine * ylen;
	var y2 = y_int - sine * xoff + cosine * ylen;
	
	return collision_line(x1, y1, x2, y2, obj, true, false) != noone;
}