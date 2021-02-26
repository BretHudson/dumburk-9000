if (keyboard_check_pressed(vk_space)) {
	do_state();
	next_state();
}

if (keyboard_check_pressed(vk_escape))
	game_end();