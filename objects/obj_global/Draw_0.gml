if (live_call()) return live_result;

draw_set_font(fnt_default);
draw_set_font(gmFont);

//var gameStateStr = string(gameState) + " [" + game_state_to_string(gameState) + "]";

var draw_stats = function() {
	var stats = ds_list_create();
	
	var push_stat = function(stats, str, num, digits) {
		str += string_replace_all(string_format(num, digits, 0), " ", "*");
		// Max width
		ds_list_add(stats, str);
	};
	
	var dayNightStr = gameState < GAME_STATE.NIGHT ? "Day:   " : "Night: ";
	
	var partyDigits = 1 + log10(get_party_size_goal());
	
	// TODO(bret): We might want to render numbers out with a second, monospaced font
	push_stat(stats, dayNightStr, day, 3);
	push_stat(stats, "Loot: ", loot, 6);
	push_stat(stats, "Party: ", partySize, partyDigits);
	push_stat(stats, "Ship Capacity: ", get_ship_capacity(), partyDigits);
	
	var strWidths = 0;
	for (var i = 0; i < ds_list_size(stats); ++i) {
		strWidths += string_width(stats[| i]);
	}
	
	var drawX = 20;
	var drawXPadding = drawX;
	var drawXContainer = camera_get_view_width(view_camera[0]) - (drawXPadding * 2);
	var drawXGap = (drawXContainer - strWidths) / (ds_list_size(stats) - 1);
	
	var height = camera_get_view_height(view_camera[0]);
	
	draw_set_valign(fa_bottom);
	for (var i = 0; i < ds_list_size(stats); ++i) {
		var str = stats[| i];
		draw_text(drawX, height - 20, str);
		drawX += string_width(str) + drawXGap;
	}
	draw_set_valign(fa_top);
	
	ds_list_destroy(stats);
};

draw_stats();

var actionLogLength = ds_list_size(actionLog);
var maxMessages = 14;
var firstIndex = max(0, actionLogLength - maxMessages);
for (var i = firstIndex; i < actionLogLength; ++i) {
	var log = actionLog[| i];
	draw_set_color(log[0]);
	//var yOffset = max(0, (maxMessages - actionLogLength)) + (i - firstIndex);
	var yOffset = i - firstIndex;
	draw_text(20, 20 + 20 *  yOffset, log[1]);
}

draw_set_color(c_white);

drawX = camera_get_view_width(view_camera[0]) - 20;
draw_set_halign(fa_right);
draw_text(drawX, 20, "Upgrades / Cost");
draw_set_halign(fa_left);

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
	draw_text(drawX, drawY, upgrade.title + levelStr + ": " + costStr);
	
	drawY += 20;
	draw_set_halign(fa_left);
}

draw_set_color(c_white);
