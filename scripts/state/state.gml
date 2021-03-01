// Game State
enum GAME_STATE {
	DAY,
	UPGRADE,
	NIGHT,
	REVIEW,
	NUM
}


// Upgrades
enum UPGRADE {
	// Multiple levels
	SHIP,
	DANCE_FLOOR,
	
	// Single upgrade
	TREE,
	
	NUM
}

function initUpgrades() {
	upgrades = [
		create_upgrade(UPGRADE.SHIP, "Ship", [0, 100, 250, 800, 1200]),
		create_upgrade(UPGRADE.DANCE_FLOOR, "Dance Floor", [0, 50, 150, 300]),
		create_upgrade(UPGRADE.TREE, "Tree", [20]),
	];
	
	// Validate I put them in the correct order
	for (var i = 0; i < array_length_1d(upgrades); ++i) {
		var upgrade = upgrades[i];
		if (upgrade.index != i) {
			show_message("obj_global: Upgrade index invalid");
		}
	}
}


// Log colors
enum LOG_COLOR {
	DEFAULT,
	DISABLED,
	ERROR,
	FAILED,
	
	CHANGE_STATE,
	
	OPTION_SELECTED,
	OPTION_DESELECTED,
	
	INCREASE,
	
	PURCHASE,
	
	NUM
}

function initLogColorTable() {
	logColorTable = [];
	logColorTable[LOG_COLOR.DEFAULT] = c_ltgray;
	logColorTable[LOG_COLOR.DISABLED] = c_dkgray;
	logColorTable[LOG_COLOR.ERROR] = c_red;
	logColorTable[LOG_COLOR.FAILED] = c_maroon;
	logColorTable[LOG_COLOR.CHANGE_STATE] = c_white;
	logColorTable[LOG_COLOR.OPTION_SELECTED] = c_white;
	logColorTable[LOG_COLOR.OPTION_DESELECTED] = c_ltgray;
	logColorTable[LOG_COLOR.INCREASE] = c_lime;
	logColorTable[LOG_COLOR.PURCHASE] = c_yellow;
}

// Actions
enum ACTION {
	NONE = -1,
	
	BEGIN_STATE,
	
	DO_STATE_DAY,
	
	CHOOSE_UPGRADE,
	DO_STATE_UPGRADE,
	
	DO_STATE_NIGHT,
	
	DO_STATE_REVIEW,
	
	END_STATE,
	
	NUM
}

function initActions() {
	actionTable = [];
	function addAction(action, func) {
		actionTable[action] = func;
	}
	
	actionTable[ACTION.BEGIN_STATE] = begin_state;
	
	actionTable[ACTION.DO_STATE_DAY] = do_state_day;
	
	actionTable[ACTION.CHOOSE_UPGRADE] = choose_upgrade;
	actionTable[ACTION.DO_STATE_UPGRADE] = do_state_upgrade;
	
	actionTable[ACTION.DO_STATE_NIGHT] = do_state_night;
	
	actionTable[ACTION.DO_STATE_REVIEW] = do_state_review;
	
	actionTable[ACTION.END_STATE] = next_state;
}

function init() {
	initUpgrades();
	initLogColorTable();
	initActions();
}


// DS List stuff
function ds_list_pop(dslist_id) {
	var lastIndex = ds_list_size(dslist_id) - 1;
	var result = dslist_id[| lastIndex];
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
	var i = currentAction;
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

function get_party_size_goal() {
	return 10000;
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

function begin_state() {
	switch (gameState) {
		case GAME_STATE.DAY: {
			currentAction = ACTION.DO_STATE_DAY;
			execute_action();
		} break;
				
		case GAME_STATE.UPGRADE: {
			cursorIndex = 0;
			
			add_to_action_log(LOG_COLOR.DEFAULT, "Choose upgrade: ");
			for (var i = 0; i < array_length_1d(upgrades); ++i) {
				var upgrade = upgrades[i];
				add_to_action_log(LOG_COLOR.OPTION_DESELECTED, "> " + upgrade.title);
			}
			add_to_action_log(LOG_COLOR.OPTION_DESELECTED, "> None (Done Shopping)");
			
			currentAction = ACTION.CHOOSE_UPGRADE;
		} break;
				
		case GAME_STATE.NIGHT: {
			currentAction = ACTION.DO_STATE_NIGHT;
			execute_action();
		} break;
				
		case GAME_STATE.REVIEW: {
			currentAction = ACTION.DO_STATE_REVIEW;
			execute_action();
		} break;
	}
}

function do_state_day() {
	var oldLoot = loot;
	loot += 20 + irandom(partySize) * 10;
	
	log_increase("Loot", oldLoot, loot);
	
	currentAction = ACTION.END_STATE;
}

function choose_upgrade() {
	currentAction = ACTION.DO_STATE_UPGRADE;
	execute_action();
}

function do_state_upgrade() {
	var numUpgrades = array_length_1d(upgrades);
	if (cursorIndex == numUpgrades) {
		stash_action_log(numUpgrades + 2);
		stash_clear_action_log();
		
		if (upgradesPurchased == 0)
			add_to_action_log(LOG_COLOR.DEFAULT, "No upgrades purchased");
		else if (upgradesPurchased == 1)
			add_to_action_log(LOG_COLOR.DEFAULT, "1 upgrade purchased");
		else
			add_to_action_log(LOG_COLOR.DEFAULT, string(upgradesPurchased) + " upgrades purchased");
		upgradesPurchased = 0;
		
		currentAction = ACTION.END_STATE;
		return;
	}
	
	var upgrade = upgrades[cursorIndex];
	if (upgrade.maxedOut) {
		currentAction = ACTION.CHOOSE_UPGRADE;
		return; // NOTE(bret): Do nothing
	}
	
	if (upgrade.nextCost <= loot) {
		++upgradesPurchased;
		perform_upgrade(upgrade.index);
		currentAction = ACTION.CHOOSE_UPGRADE;
		//currentAction = ACTION.END_STATE;
		return;
	}
	
	// Cannot afford
	currentAction = ACTION.CHOOSE_UPGRADE;
}

function do_state_night() {
	var oldPartySize = partySize;
	partySize = approach(partySize, get_ship_capacity(), 1 + irandom(4));
	
	if (oldPartySize == partySize)
		add_to_action_log(LOG_COLOR.FAILED, "Party +0 (No space for new members)");
	else
		log_increase("Party", oldPartySize, partySize);
	
	currentAction = ACTION.END_STATE;
}

function do_state_review() {
	var shipCapacity = get_ship_capacity();
	var goal = get_party_size_goal();
	add_to_action_log(LOG_COLOR.DEFAULT, "Your ship capacity is " + string(shipCapacity));
	add_to_action_log(LOG_COLOR.DEFAULT, "You can house " + string(shipCapacity - partySize) + " more party members");
	add_to_action_log(LOG_COLOR.DEFAULT, "You have " + string(partySize) + "/" + string(goal) + " party members needed");
	
	currentAction = ACTION.END_STATE;
}

function next_state() {
	gameState = (gameState + 1) % GAME_STATE.NUM;
	if (gameState == 0) {
		++day;
	}
	
	if (ds_list_size(actionLog) > 0)
		add_to_action_log(LOG_COLOR.DEFAULT, "");
	add_to_action_log(LOG_COLOR.CHANGE_STATE, "# Switched state to [" + game_state_to_string(gameState) + "]");
	
	switch (gameState) {
		case GAME_STATE.DAY: {
			audio_stop_sound(snd_track_night);
			audio_play_sound(snd_track_day, 10, true);
		} break;
		
		case GAME_STATE.NIGHT: {
			audio_stop_sound(snd_track_day);
			audio_play_sound(snd_track_night, 10, true);
		} break;
	}
	
	currentAction = ACTION.BEGIN_STATE;
}

function game_state_to_string(gameState) {
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
