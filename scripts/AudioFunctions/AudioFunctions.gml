/// @function sound_play(soundid)
/// @description Plays the given sound effect, stopping any existing instances of it beforehand.
/// @param {Asset.GMSound} soundid Sound asset to play.
/// @returns {Id.Sound}
function sound_play(soundid)
{
	audio_stop_sound(soundid);
	return audio_play_sound(soundid, 0, false, global.volume_sound);
}

/// @function music_overlay(soundid)
/// @description Plays the given music track as an overlay, muting the stream until it has finished playing.
/// @param {Asset.GMSound} soundid Sound asset to play.
function music_overlay(soundid)
{
	with (ctrlMusic)
	{
		// Stop existing overlay, otherwise mute stream
		if (overlay != -1) audio_stop_sound(overlay);
		else audio_sound_gain(stream, 0, 0);
		
		// Play overlay
		overlay = audio_play_sound(soundid, 2, false, global.volume_music);
		alarm[0] = audio_sound_length(soundid) * room_speed;
	}
}

/// @function music_enqueue(soundid, priority)
/// @description Adds the given music track to the queue, playing it if it has the highest priority.
/// @param {Asset.GMSound} soundid Sound asset to add.
/// @param {Real} priority Priority value to set.
function music_enqueue(soundid, priority)
{
	with (ctrlMusic)
	{
		if (ds_priority_find_priority(queue, soundid) == undefined)
		{
			ds_priority_add(queue, soundid, priority);
		}
		
		if (ds_priority_find_max(queue) == soundid)
		{
			play_music(soundid);
		}
	}
}

/// @function music_dequeue(soundid)
/// @description Removes the given music track from the queue. If it was streaming, the track below it is then played.
/// @param {Asset.GMSound} soundid Sound asset to remove.
function music_dequeue(soundid)
{
	with (ctrlMusic)
	{
		ds_priority_delete_value(queue, soundid);
		if (audio_is_playing(soundid)) play_music(ds_priority_find_max(queue));
	}
}