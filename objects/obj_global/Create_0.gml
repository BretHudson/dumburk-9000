gameState = -1;
day = 0;

advanceTimer = 0;
advanceTimeout = 13;

partySize = 1;
loot = 0;

enum UPGRADE {
	// Multiple levels
	SHIP,
	DANCE_FLOOR,
	
	// Single upgrade
	TREE,
	
	NUM
}

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

actionTable = [];
function addAction(action, func) {
	actionTable[action] = func;
}

cursorIndex = 0;

addAction(ACTION.BEGIN_STATE, _begin_state);

addAction(ACTION.DO_STATE_DAY, _do_state_day);

addAction(ACTION.CHOOSE_UPGRADE, choose_upgrade);
addAction(ACTION.DO_STATE_UPGRADE, _do_state_upgrade);

addAction(ACTION.DO_STATE_NIGHT, _do_state_night);

addAction(ACTION.DO_STATE_REVIEW, _do_state_review);

addAction(ACTION.END_STATE, _next_state);

currentAction = {
	value: ACTION.END_STATE,
	//arguments: ds_list_create()
};

upgradesPurchased = 0;
actionLog = ds_list_create();
actionLogStash = ds_list_create();

execute_action();