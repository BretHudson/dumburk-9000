if (live_call()) return live_result;

gameState = -1;
day = 0;

advanceTimer = 0;
advanceTimeout = 13;

partySize = 1;
loot = 0;

cursorIndex = 0;

init();

currentAction = ACTION.END_STATE;

upgradesPurchased = 0;
actionLog = ds_list_create();
actionLogStash = ds_list_create();

gmFont = draw_get_font();

show_message("This game was unfinished, but is a prototype that will be expanded after the jam :)");

execute_action();