/// @description Reward / Destroy
if (gravity == 0)
{
	instance_destroy();
	exit;
}

vspeed = 0;
gravity = 0;
alarm[0] = 32;

/* AUTHOR NOTE: `owner` is initialized in the player-monitor reaction. */

with (owner)
{
	switch (other.image_index)
	{
		case ICON.RING:
		{
			player_gain_rings(10);
			break;
		}
		case ICON.SNEAKER:
		{
			superspeed_time = 1200;
			player_refresh_physics();
			break;
		}
		case ICON.INVINCIBILITY:
		{
			invincibility_time = 1200;
			
			// TODO: create invincibility stars
			break;
		}
		case ICON.ROBOTNIK:
		{
			player_damage(self);
			break;
		}
		case ICON.LIFE:
		{
			player_gain_lives(1);
			break;
		}
	}
}