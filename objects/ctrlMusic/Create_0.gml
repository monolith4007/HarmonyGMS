/// @description Initialize
image_speed = 0;

queue = ds_priority_create();
music = -1;
overlay = -1;
looping_tracks = [bgmMadGear];

/// @method set_music_loop(soundid, loop_start, loop_end)
/// @description Sets the loop points of the given music track.
/// @param {Asset.GMSound} soundid Sound asset to set loop points for.
/// @param {Real} loop_start Start point of the loop in seconds.
/// @param {Real} loop_end End point of the loop in seconds.
var set_music_loop = function(soundid, loop_start, loop_end)
{
	audio_sound_loop_start(soundid, loop_start);
	audio_sound_loop_end(soundid, loop_end);
	array_push(looping_tracks, soundid);
}

// TODO: define loops points for music (if applicable)
// Looping tracks that don't have loop points should be added directly into the array

/// @method play_music(soundid)
/// @description Plays the given music track, muting it if an overlay is playing.
/// @param {Asset.GMSound} soundid Sound asset to play.
play_music = function(soundid)
{
	audio_stop_sound(music);
	music = audio_play_sound(soundid, 1, array_contains(looping_tracks, soundid), global.volume_music * (overlay == -1));
}