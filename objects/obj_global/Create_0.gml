gameState = -1;
day = 0;

partySize = 1;
loot = 0;

enum UPGRADES {
	SHIP,
	NUM
};

upgrades = [
	create_upgrade(UPGRADES.SHIP, "Ship", [100, 250, 800, 1200])
];

// Validate I put them in the correct order
for (var i = 0; i < array_length_1d(upgrades); ++i) {
	var upgrade = upgrades[i];
	if (upgrade.index != i) {
		show_message("obj_global: Upgrade index invalid");
	}
}

sync_upgrades();

actionLogLength = 0;
actionLog = [];

stateColors = [c_white, c_lime, c_ltgray, c_yellow];

next_state();