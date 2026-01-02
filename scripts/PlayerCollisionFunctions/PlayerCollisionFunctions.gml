/// @function player_collision(obj)
/// @description Checks if the given entity's mask intersects the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement} obj Object, instance or tilemap to check.
/// @returns {Bool}
function player_collision(obj)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	return (mask_direction mod 180 == 0 ?
		collision_rectangle(x_int - x_radius, y_int - y_radius, x_int + x_radius, y_int + y_radius, obj, true, false) != noone :
		collision_rectangle(x_int - y_radius, y_int - x_radius, x_int + y_radius, y_int + x_radius, obj, true, false) != noone);
}

/// @function player_part_collision(obj, ylen)
/// @description Checks if the given entity's mask intersects a vertical portion of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement} obj Object, instance or tilemap to check.
/// @param {Real} ylen Distance in pixels to extend the player's mask vertically.
/// @returns {Bool}
function player_part_collision(obj, ylen)
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

/// @function player_ray_collision(obj, xoff, ylen)
/// @description Checks if the given entity's mask intersects a line from the player's position.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement} obj Object, instance or tilemap to check.
/// @param {Real} xoff Distance in pixels to offset the line horizontally.
/// @param {Real} ylen Distance in pixels to extend the line downward.
/// @returns {Bool}
function player_ray_collision(obj, xoff, ylen)
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

/// @function player_beam_collision(obj, [xrad], [yoff])
/// @description Checks if the given entity's mask intersects a line from the player's position.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement} obj Object, instance or tilemap to check.
/// @param {Real} [xrad] Distance in pixels to extend the line horizontally on both ends (optional, default is the player's wall radius).
/// @param {Real} [yoff] Distance in pixels to offset the line vertically (optional, default is 0).
/// @returns {Asset.GMObject|Id.Instance|Id.TileMapElement}
function player_beam_collision(obj, xrad = x_wall_radius, yoff = 0)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int - cosine * xrad + sine * yoff;
	var y1 = y_int + sine * xrad + cosine * yoff;
	var x2 = x_int + cosine * xrad + sine * yoff;
	var y2 = y_int - sine * xrad + cosine * yoff;
	
	return collision_line(x1, y1, x2, y2, obj, true, false);
}