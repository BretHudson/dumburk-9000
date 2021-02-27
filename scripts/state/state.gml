enum GAME_STATE {
	DAY,
	UPGRADE,
	NIGHT,
	REVIEW,
	NUM
}

function ds_list_pop(dslist_id) {
	var lastIndex = ds_list_size(dslist_id) - 1;
	var result = ds_list_find_value(dslist_id, lastIndex);
	ds_list_delete(dslist_id, lastIndex);
	return result;
}

function stash_action_log(length) {
	length = min(length, ds_list_size(actionLog));
	
	for (var i = 0; i < length; ++i)
		ds_list_add(actionLogStash, ds_list_pop(actionLog));
}

function stash_pop_action_log() {
	var count = ds_list_size(actionLogStash);
	for (var i = 0; i < count; ++i)
		ds_list_add(actionLog, ds_list_pop(actionLogStash));
}

function stash_clear_action_log() {
	ds_list_clear(actionLogStash);
}

function add_to_action_log(actionColorIndex, str) {
	var actionColor = logColorTable[actionColorIndex];
	ds_list_add(actionLog, [actionColor, str]);
}

function execute_action() {
	var i = currentAction.value;
	if ((i <= ACTION.NONE) || (i >= ACTION.NUM)) {
		show_message("execute_action(): ???");
		return;
	}
	
	actionTable[i]();
}

function create_upgrade(index, title, costs) {
	var _singleUpgrade = array_length_1d(costs) == 1;
	var initialLevel = _singleUpgrade ? 0 : 1;
	return {
		index: index,
		title: title,
		costs: costs,
		singleUpgrade: _singleUpgrade,
		level: initialLevel,
		maxedOut: false,
		nextCost: costs[initialLevel],
	};
}

function get_upgrade_level(index) {
	return upgrades[index].level;
}

function perform_upgrade(index) {
	var upgrade = upgrades[index];
	
	// Purchase
	var prevLoot = loot;
	loot -= upgrade.nextCost;
	
	// Then upgrade the... upgrade
	++upgrade.level;
	upgrade.maxedOut = (upgrade.level == array_length_1d(upgrade.costs));
	upgrade.nextCost = upgrade.maxedOut ? 0 : upgrade.costs[upgrade.level];
	
	stash_action_log(array_length_1d(upgrades) + 2);
	
	// Show logs
	add_to_action_log(LOG_COLOR.PURCHASE, "Bought " + upgrade.title + " upgrade [" + string(upgrade.level) + " -> " + string(upgrade.level + 1) + "]");
	log_increase("Loot", prevLoot, loot);
	
	stash_pop_action_log();
}

function log_increase(str, prev, next) {
	var increase = next - prev;
	var signStr = (increase < 0) ? "" : "+";
	add_to_action_log(LOG_COLOR.INCREASE, str + " " + signStr + string(increase) + " [" + string(prev) + " -> " + string(next) + "]");
}

function _begin_state() {
	//ds_list_empty(currentAction.arguments);
	
	switch (gameState) {
		case GAME_STATE.DAY: {
			currentAction.value = ACTION.DO_STATE_DAY;
			execute_action();
		} break;
				
		case GAME_STATE.UPGRADE: {
			cursorIndex = 0;
			
			//ds_list_add(currentAction.arguments, 0);
			
			add_to_action_log(LOG_COLOR.DEFAULT, "Choose upgrade: ");
			for (var i = 0; i < array_length_1d(upgrades); ++i) {
				var upgrade = upgrades[i];
				add_to_action_log(LOG_COLOR.OPTION_DESELECTED, "> " + upgrade.title);
			}
			add_to_action_log(LOG_COLOR.OPTION_DESELECTED, "> None");
			
			currentAction.value = ACTION.CHOOSE_UPGRADE;
		} break;
				
		case GAME_STATE.NIGHT: {
			currentAction.value = ACTION.DO_STATE_NIGHT;
			execute_action();
		} break;
				
		case GAME_STATE.REVIEW: {
			currentAction.value = ACTION.DO_STATE_REVIEW;
			execute_action();
		} break;
	}
}

function _do_state_day() {
	var oldLoot = loot;
	loot += 20 + irandom(partySize) * 10;
	
	log_increase("Loot", oldLoot, loot);
	
	currentAction.value = ACTION.END_STATE;
}

function choose_upgrade() {
	currentAction.value = ACTION.DO_STATE_UPGRADE;
	execute_action();
}

function _do_state_upgrade() {
	var numUpgrades = array_length_1d(upgrades);
	if (cursorIndex == numUpgrades) {
		stash_action_log(numUpgrades + 2);
		stash_clear_action_log();
		
		if (upgradesPurchased == 0)
			add_to_action_log(LOG_COLOR.DEFAULT, "No upgrades purchased");
		else if (upgradesPurchased == 1)
			add_to_action_log(LOG_COLOR.DEFAULT, "1 upgrade purchased");
		else
			add_to_action_log(LOG_COLOR.DEFAULT, upgradesPurchased + " upgrades purchased");
		upgradesPurchased = 0;
		
		currentAction.value = ACTION.END_STATE;
		return;
	}
	
	var upgrade = upgrades[cursorIndex];
	if (upgrade.maxedOut) {
		currentAction.value = ACTION.CHOOSE_UPGRADE;
		return; // NOTE(bret): Do nothing
	}
	
	if (upgrade.nextCost <= loot) {
		++upgradesPurchased;
		perform_upgrade(upgrade.index);
		currentAction.value = ACTION.CHOOSE_UPGRADE;
		//currentAction.value = ACTION.END_STATE;
		return;
	}
	
	// Cannot afford
	currentAction.value = ACTION.CHOOSE_UPGRADE;
}

function _do_state_night() {
	var oldPartySize = partySize;
	partySize = approach(partySize, get_ship_capacity(), 1 + irandom(4));
	
	if (oldPartySize == partySize)
		add_to_action_log(LOG_COLOR.FAILED, "Party +0 (No space for new members)");
	else
		log_increase("Party", oldPartySize, partySize);
	
	currentAction.value = ACTION.END_STATE;
}

function _do_state_review() {
	add_to_action_log(LOG_COLOR.DEFAULT, "Wow, you're doing well!");
	
	currentAction.value = ACTION.END_STATE;
}

function _next_state() {
	gameState = (gameState + 1) % GAME_STATE.NUM;
	if (gameState == 0) {
		++day;
	}
	add_to_action_log(LOG_COLOR.DEFAULT, "");
	add_to_action_log(LOG_COLOR.CHANGE_STATE, "> Switched state to [" + gameStateToStr(gameState) + "]");
	
	currentAction.value = ACTION.BEGIN_STATE;
}

function gameStateToStr(gameState) {
	switch (gameState) {
		case GAME_STATE.DAY:
			return "DAY";
		case GAME_STATE.UPGRADE:
			return "UPGRADE";
		case GAME_STATE.NIGHT:
			return "NIGHT";
		case GAME_STATE.REVIEW:
			return "REVIEW";
		default:
			return "???";
	}
}

function get_ship_capacity() {
	return power(10, get_upgrade_level(UPGRADE.SHIP));
}