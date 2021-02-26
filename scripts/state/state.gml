enum GAME_STATE {
	DAY,
	UPGRADE,
	NIGHT,
	REVIEW,
	NUM
}

function addToActionLog(str) {
	actionLog[actionLogLength++] = [gameState, str];
}

function create_upgrade(index, title, costs) {
	return {
		index: index,
		title: title,
		costs: costs,
		level: 0,
		maxedOut: false,
		nextCost: costs[0]
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
	
	// Show logs
	addToActionLog("Bought " + upgrade.title + " upgrade [" + string(upgrade.level) + " -> " + string(upgrade.level + 1) + "]");
	logIncrease("Loot", prevLoot, loot);
}

function sync_upgrades() {
	
}

function do_state() {
	switch (gameState) {
		case GAME_STATE.DAY: doStateDay(); break;
		case GAME_STATE.UPGRADE: doStateUpgrade(); break;
		case GAME_STATE.NIGHT: doStateNight(); break;
		case GAME_STATE.REVIEW: doStateReview(); break;
	}
	
	sync_upgrades();
}

function logIncrease(str, prev, next) {
	var increase = next - prev;
	var signStr = (increase < 0) ? "" : "+";
	addToActionLog(str + " " + signStr + string(increase) + " [" + string(prev) + " -> " + string(next) + "]");
}

function doStateDay() {
	var oldLoot = loot;
	loot += 10 + irandom(4) * 10;
	
	logIncrease("Loot", oldLoot, loot);
}

function doStateUpgrade() {
	var upgraded = false;
	for (var i = 0; i < array_length_1d(upgrades); ++i) {
		var upgrade = upgrades[i];
		if (upgrade.nextCost <= loot) {
			upgraded = true;
			perform_upgrade(upgrade.index);
			break;
		}
	}
	
	if (!upgraded) {
		addToActionLog("No upgrades purchased");
	}
}

function doStateNight() {
	var oldPartySize = partySize;
	partySize = approach(partySize, getShipCapacity(), 1 + irandom(4));
	
	if (oldPartySize == partySize)
		addToActionLog("Party +0 (No space for new members)");
	else
		logIncrease("Party", oldPartySize, partySize);
}

function doStateReview() {
	addToActionLog("Wow, you're doing well!");
}

function next_state() {
	gameState = (gameState + 1) % GAME_STATE.NUM;
	if (gameState == 0) {
		++day;
	}
	addToActionLog("");
	addToActionLog("> Switched state to [" + gameStateToStr(gameState) + "]");
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

function getShipCapacity() {
	return power(10, get_upgrade_level(UPGRADES.SHIP) + 1);
}