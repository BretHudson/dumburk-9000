//var gameStateStr = string(gameState) + " [" + gameStateToStr(gameState) + "]";

drawX = 20;
drawXGap = 130;

var drawStat = function(str) {
	draw_text(drawX, 20, str);
	
	drawX += drawXGap;
}

var dayNightStr = gameState < GAME_STATE.NIGHT ? "Day:   " : "Night: ";

drawStat(dayNightStr + string(day));
drawStat("Loot: " + string(loot));
drawStat("Party: " + string(partySize));
drawStat("Ship Capacity: " + string(getShipCapacity()));

var maxMessages = 14;
var firstIndex = max(0, actionLogLength - maxMessages);
for (var i = firstIndex; i < actionLogLength; ++i) {
	var log = actionLog[i];
	draw_set_color(stateColors[log[0]]);
	var yOffset = max(0, (maxMessages - actionLogLength)) + (i - firstIndex);
	draw_text(20, 60 + 20 *  yOffset, log[1]);
}

draw_set_color(c_white);

var drawY = 60;
for (var i = 0; i < array_length_1d(upgrades); ++i) {
	var upgrade = upgrades[i];
	
	if (upgrade.maxedOut)
		continue;
	
	draw_text(460, drawY, upgrade.title + ":");
	
	draw_set_halign(fa_right);
	draw_text(580, drawY, string(upgrade.nextCost));
	
	drawY += 20;
	draw_set_halign(fa_left);
}

draw_set_color(c_white);