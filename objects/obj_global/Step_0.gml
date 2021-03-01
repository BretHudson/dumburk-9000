if (live_call()) return live_result;

if (advanceTimer > 0) {
	--advanceTimer;
}

if (keyboard_check_pressed(vk_enter)) {
	execute_action();
}

function choose_upgrade() {
	var num = array_length_1d(upgrades) + 1;
	
	if (advanceTimer == 0) {
		if (keyboard_check(vk_up)) {
			--cursorIndex;
		}
		
		if (keyboard_check(vk_down)) {
			++cursorIndex;
		}
	}
	
	cursorIndex = (cursorIndex + num) % num;
	
	for (var i = 0; i < num; ++i) {
		var selected = i == cursorIndex;
		var index = selected ? LOG_COLOR.OPTION_SELECTED : LOG_COLOR.OPTION_DESELECTED;
		var prefix = selected ? "> " : "  ";
		var actionIndex = ds_list_size(actionLog) - num + i;
		var log = actionLog[| actionIndex];
		if (i < array_length_1d(upgrades)) {
			if (upgrades[i].nextCost > loot) {
				index = selected ? LOG_COLOR.ERROR : LOG_COLOR.FAILED;
			} else if (upgrades[i].maxedOut) {
				index = LOG_COLOR.DISABLED;
			}
		}
		log[@0] = logColorTable[index];
		log[@1] = string_insert(prefix, string_delete(log[1], 1, 2), 1);
	}
}

switch (gameState) {
	case GAME_STATE.UPGRADE: {
		switch (currentAction) {
			case ACTION.CHOOSE_UPGRADE: {
				choose_upgrade();
			} break;
		}
	} break;
}

if ((advanceTimer == 0) && (keyboard_check(vk_space))) {
	execute_action();
	++cursorIndex;
}

var keys = [
	vk_space,
	vk_up,
	vk_down,
];

for (var i = 0; i < array_length_1d(keys); ++i) {
	if (advanceTimer == 0) {
		if (keyboard_check(keys[i])) {
			advanceTimer = advanceTimeout;
			break;
		}
	}
	
	if (keyboard_check_released(keys[i])) {
		advanceTimer = 0;
		break;
	}
}

if (keyboard_check_pressed(vk_escape))
	game_end();