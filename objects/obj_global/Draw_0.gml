//var gameStateStr = string(gameState) + " [" + gameStateToStr(gameState) + "]";

drawX = 20;
drawXGap = 130;

var draw_stat = function(str) {
	draw_text(drawX, 20, str);
	
	drawX += drawXGap;
}

var dayNightStr = gameState < GAME_STATE.NIGHT ? "Day:   " : "Night: ";

draw_stat(dayNightStr + string(day));
draw_stat("Loot: " + string(loot));
draw_stat("Party: " + string(partySize));
draw_stat("Ship Capacity: " + string(get_ship_capacity()));

var actionLogLength = ds_list_size(actionLog);
var maxMessages = 14;
var firstIndex = max(0, actionLogLength - maxMessages);
for (var i = firstIndex; i < actionLogLength; ++i) {
	var log = ds_list_find_value(actionLog, i);
	draw_set_color(log[0]);
	var yOffset = max(0, (maxMessages - actionLogLength)) + (i - firstIndex);
	draw_text(20, 60 + 20 *  yOffset, log[1]);
}

draw_set_color(c_white);

var drawY = 60;
for (var i = 0; i < array_length_1d(upgrades); ++i) {
	var upgrade = upgrades[i];
	
	var levelStr = "";
	if (!upgrade.singleUpgrade)
		levelStr = upgrade.maxedOut ? " [MAX]" : " [LV" + string(upgrade.level) + "]";
	
	var costStr = string_format(upgrade.nextCost, 4, 0);
	if ((upgrade.singleUpgrade) && (upgrade.maxedOut))
		costStr = " [X]";
	
	draw_set_halign(fa_right);
	draw_text(580, drawY, upgrade.title + levelStr + ": " + costStr);
	
	drawY += 20;
	draw_set_halign(fa_left);
}

draw_set_color(c_white);