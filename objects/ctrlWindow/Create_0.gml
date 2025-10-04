/// @description Initialize
scale = 1;

// Resize
window_set_size(CAMERA_WIDTH, CAMERA_HEIGHT);
surface_resize(application_surface, CAMERA_WIDTH, CAMERA_HEIGHT);
display_set_gui_size(CAMERA_WIDTH, CAMERA_HEIGHT);
window_center();

/* AUTHOR NOTE: due to being created 1 frame after the start of the game,
the Room Start event does not run, so it's invoked here. */
event_perform(ev_other, ev_room_start);