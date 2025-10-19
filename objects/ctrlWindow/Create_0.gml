/// @description Initialize
scale = 0;

// Resize
event_perform(ev_keypress, vk_f4);
display_set_gui_size(CAMERA_WIDTH, CAMERA_HEIGHT);

/* AUTHOR NOTE: due to being created 1 frame after the start of the game,
the Room Start event does not run, so it's invoked here. */
event_perform(ev_other, ev_room_start);