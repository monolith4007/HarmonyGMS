/// @function player_calc_ground_normal(x, y, rot)
/// @description Calculates the surface normal of the 16x16 solid chunk found at the given point.
/// @param {Real} x x-coordinate of the point.
/// @param {Real} y y-coordinate of the point.
/// @param {Real} rot Rotation of the point in multiples of 90 degrees.
/// @returns {Real}
function player_calc_ground_normal(ox, oy, rot)
{
	/// @method point_in_solid(px, py)
	/// @description Checks if any solids are intersecting the given point.
	/// @param {Real} px x-coordinate of the point.
	/// @param {Real} py y-coordinate of the point.
	/// @returns {Bool}
	static point_in_solid = function (px, py)
	{
		for (var n = array_length(tilemaps) - 1; n > -1; --n)
		{
			if (collision_point(px, py, tilemaps[n], true, false) != noone) return true;
		}
		
		for (n = array_length(solid_objects) - 1; n > -1; --n)
		{
			if (collision_point(px, py, solid_objects[n], true, false) != noone) return true;
		}
		
		return false;
	};
	
	// Setup angle sensors
	var sensor_x = array_create(2, ox);
	var sensor_y = array_create(2, oy);
	var sine = dsin(rot);
	var cosine = dcos(rot);
	
	if (rot mod 180 != 0)
	{
		var right = (rot == 90);
		sensor_y[right] = (oy div 16) * 16;
		sensor_y[not right] = sensor_y[right] + 15;
	}
	else
	{
		var up = (rot == 180);
		sensor_x[up] = (ox div 16) * 16;
		sensor_x[not up] = sensor_x[up] + 15;
	}
	
	// Extend / regress angle sensors
	for (var n = 0; n < 2; ++n)
	{
		repeat (y_tile_reach)
		{
			if (not point_in_solid(sensor_x[n], sensor_y[n]))
			{
				sensor_x[n] += sine;
				sensor_y[n] += cosine;
			}
			else if (point_in_solid(sensor_x[n] - sine, sensor_y[n] - cosine))
			{
				sensor_x[n] -= sine;
				sensor_y[n] -= cosine;
			}
			else break;
		}
	}
	
	// Calculate the direction between both angle sensors
	return point_direction(sensor_x[0], sensor_y[0], sensor_x[1], sensor_y[1]) div 1;
}

/// @function player_detect_entities()
/// @description Finds any instances intersecting a minimum bounding rectangle centered on the player, executes their reaction, and registers their solidity.
/// It also refreshes the player's local tilemaps by (de)listing the semisolid layer if applicable.
function player_detect_entities()
{
	// Delist solid zone objects
	array_resize(solid_objects, 0);
	
	// Setup bounding rectangle
	var x_int = x div 1;
	var y_int = y div 1;
	var xdia = x_wall_radius + 0.5;
	var ydia = y_tile_reach + y_radius + 0.5;
	
	/* AUTHOR NOTE: the size of the bounding rectangle must be coordinated with the distances used for collision checking.
	Wall collisions check for a distance of `x_wall_radius`, so this is the rectangle's width.
	Floor collisions check for a distance of `y_tile_reach + y_radius`, so this is the rectangle's height.
	The additional 0.5 pixels is there to address a quirk with GameMaker's collision functions where, with the exception of
	`collision_line` and `collision_point`, the colliding shapes must intersect by at least 0.5 pixels for a collision to be registered. */
	
	// Detect instances intersecting the rectangle
	var zone_objects = ds_list_create();
	var total_objects = (mask_direction mod 180 != 0 ?
		collision_rectangle_list(x_int - ydia, y_int - xdia, x_int + ydia, y_int + xdia, objZoneObject, true, false, zone_objects, false) :
		collision_rectangle_list(x_int - xdia, y_int - ydia, x_int + xdia, y_int + ydia, objZoneObject, true, false, zone_objects, false));
	
	// Execute the reaction of all instances
	for (var n = 0; n < total_objects; ++n)
	{
		var inst = zone_objects[| n];
		script_execute(inst.reaction, inst);
		
		// Register solid instances; skip the current instance if...
		if (not (instance_exists(inst) and object_is_ancestor(inst.object_index, objSolid))) continue; // It has been destroyed after its reaction, or is not solid
		if (inst.semisolid and player_ray_collision(inst)) continue; // Passing through
		
		array_push(solid_objects, inst);
	}
	ds_list_destroy(zone_objects);
	
	// Evaluate semisolid tilemap collision
	var valid = array_contains(tilemaps, semisolid_tilemap);
	if (not player_ray_collision(semisolid_tilemap))
	{
		if (not valid) array_push(tilemaps, semisolid_tilemap);
	}
	else if (valid) array_pop(tilemaps);
}