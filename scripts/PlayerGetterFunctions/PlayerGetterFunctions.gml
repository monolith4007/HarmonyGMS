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
	var point_in_solid = function(px, py)
	{
		for (var n = ds_list_size(solid_objects) - 1; n > -1; --n)
		{
			if (collision_point(px, py, solid_objects[| n], true, false) != noone)
			{
				return true;
			}
		}
		return false;
	}
	
	// Setup angle sensors
	var sensor_x = [ox, ox];
	var sensor_y = [oy, oy];
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
	var reps = y_tile_reach * 2;
	for (var n = 0; n < 2; ++n)
	{
		repeat (reps)
		{
			if (not point_in_solid(sensor_x[n], sensor_y[n]))
			{
				sensor_x[n] += sine;
				sensor_y[n] += cosine;
			}
			else break;
		}
		repeat (reps)
		{
			if (point_in_solid(sensor_x[n] - sine, sensor_y[n] - cosine))
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

/// @function player_register_zone_objects()
/// @description Finds any instances intersecting a minimum bounding rectangle centered on the player, executes their reaction, and registers their solidity.
function player_register_zone_objects()
{
	// Delist solids
	ds_list_clear(solid_objects);
	
	// Setup bounding rectangle
	var x_int = x div 1;
	var y_int = y div 1;
	var xrad = x_wall_radius;
	var yrad = y_tile_reach * 2 + y_radius + 1;
	
	// Detect instances intersecting the rectangle
	var zone_objects = ds_list_create();
	var total_objects = (mask_direction mod 180 != 0 ?
		collision_rectangle_list(x_int - yrad, y_int - xrad, x_int + yrad, y_int + xrad, objZoneObject, true, false, zone_objects, false) :
		collision_rectangle_list(x_int - xrad, y_int - yrad, x_int + xrad, y_int + yrad, objZoneObject, true, false, zone_objects, false));
	
	// Execute the reaction of all instances
	for (var n = 0; n < total_objects; ++n)
	{
		var inst = zone_objects[| n];
		script_execute(inst.reaction, inst);
		
		// Register solid instances; skip the current instance if...
		if (not (instance_exists(inst) and object_is_ancestor(inst.object_index, objSolid))) continue; // It has been destroyed after its reaction, or is not solid
		if (inst.semisolid and player_arms_in_object(inst)) continue; // Passing through
		if (not (collision_layer & inst.collision_layer)) continue; // On mismatching collision layers
		
		ds_list_add(solid_objects, inst);
	}
	ds_list_destroy(zone_objects);
}