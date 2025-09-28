/// @description Detect gamepad
var event = async_load[? "event_type"];
var pad = async_load[? "pad_index"];

if (event == "gamepad discovered" and gp_device == -1)
{
	gp_device = pad;
	buttons = [gp_padu, gp_padd, gp_padl, gp_padr, gp_face1]; // See the author note in the Create event
}
else if (event == "gamepad lost" and gp_device == pad)
{
	gp_device = -1;
	buttons = -1;
}