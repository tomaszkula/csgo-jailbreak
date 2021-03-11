#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Wish"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

#define WISH_CUSTOM "custom"
#define WISH_REVENGE "zemsta"
#define WISH_DUEL "duel"

#define WISH_FREEDAY "freeday"
const int WISH_FREEDAYS_COUNT = 2;
int wishFreeDaysCount = 0;

enum WishStatus
{
	NoWish = 0,
	FreeDayWish,
	ChosenWish
}

int last = 0;
WishStatus wishStatus = NoWish;

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
	
	RegConsoleCmd("zyczenie", WishCmd);
	RegConsoleCmd("wish", WishCmd);
	RegConsoleCmd("lr", WishCmd);
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	last = 0;
	wishStatus = NoWish;
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	if(last == _victim)
	{
		last = 0;
		wishStatus = NoWish;
	}
	
	checkLast();
	
	return Plugin_Continue;
}

public Action WishCmd(int _client, int args)
{
	displayWishMenu(_client);
	return Plugin_Handled;
}

void displayWishMenu(int _client)
{
	if(_client != last)
	{
		return;
	}
	
	switch(wishStatus)
	{
		case NoWish:
		{
			displayWishMainMenu(_client);
		}
		
		case FreeDayWish:
		{
			displayWishFreeDayMenu(_client, wishFreeDaysCount);
		}
	}
}

void displayWishMainMenu(int _client)
{
	if(_client != last || wishStatus != NoWish)
	{
		return;
	}
	
	Menu menu = CreateMenu(WishMenuHandler, MENU_ACTIONS_ALL);
	menu.SetTitle("[ Życzenie ]");
	menu.AddItem(WISH_CUSTOM, "Własne życzenie");
	menu.AddItem(WISH_REVENGE, "Zemsta");
	menu.AddItem(WISH_FREEDAY, "FreeDay dla więźniów");
	menu.AddItem(WISH_DUEL, "Pojedynek");
	menu.ExitButton = false;
	menu.Display(_client, MENU_TIME_FOREVER);
}

public int WishMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(_param1 != last || wishStatus != NoWish)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			char _itemTitle[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo), _, _itemTitle, sizeof(_itemTitle)); 
			
			if(StrEqual(_itemInfo, WISH_CUSTOM))
			{
				wishStatus = ChosenWish;
			}
			else if(StrEqual(_itemInfo, WISH_REVENGE))
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
					{
						continue;
					}
					
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
				}
				
				GivePlayerItem(_param1, "weapon_ak47");
				SetEntProp(_param1, Prop_Data, "m_takedamage", 0, 1);
				
				wishStatus = ChosenWish;
			}
			else if(StrEqual(_itemInfo, WISH_FREEDAY))
			{
				wishStatus = FreeDayWish;
				wishFreeDaysCount = 0;
				displayWishFreeDayMenu(_param1, wishFreeDaysCount);
			}
			
			char _targetName[LENGTH_64];
			GetClientName(_param1, _targetName, sizeof(_targetName));
			PrintToChatAll("%s Ostatni więzień \x07%s \x01wybrał \x10[%s]\x01.", JB_PREFIX, _targetName, _itemTitle);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayWishFreeDayMenu(int _client, int _wishFreeDaysCount)
{
	if(_client != last || wishStatus != FreeDayWish)
	{
		return;
	}
	
	Menu _menu = CreateMenu(WishFreeDayMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Życzenie ] [ FreeDay ] [ %i / %i ]", _wishFreeDaysCount + 1, WISH_FREEDAYS_COUNT);
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || GetClientTeam(i) != CS_TEAM_T)
		{
			continue;
		}
		
		char _targetName[LENGTH_64];
		GetClientName(i, _targetName, sizeof(_targetName));
		
		Format(_itemInfo, sizeof(_itemInfo), "%i", i);
		
		if(JB_HasFreeDayNextDay(i))
		{
			Format(_itemTitle, sizeof(_itemTitle), "%s [jutro FD]", _targetName);
		}
		else
		{
			Format(_itemTitle, sizeof(_itemTitle), "%s", _targetName);
		}
		_menu.AddItem(_itemInfo, _itemTitle);
	}
	_menu.ExitButton = false;
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int WishFreeDayMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(_param1 != last || wishStatus != FreeDayWish)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			int _target = StringToInt(_itemInfo);
			if(!IsClientInGame(_target) || GetClientTeam(_target) != CS_TEAM_T || JB_HasFreeDayNextDay(_target))
			{
				displayWishFreeDayMenu(_param1, wishFreeDaysCount);
				return -1;
			}
			
			JB_AddFreeDayNextDay(_target);
			
			char _targetName[LENGTH_64];
			GetClientName(_target, _targetName, sizeof(_targetName));
			PrintToChatAll("%s Ostatni więzień wybrał \x04FreeDay'a\x01[%i/%i] dla więźnia \x07%s\x01.", JB_PREFIX, wishFreeDaysCount + 1, WISH_FREEDAYS_COUNT, _targetName);
			
			++wishFreeDaysCount;
			if(wishFreeDaysCount < WISH_FREEDAYS_COUNT)
			{
				displayWishFreeDayMenu(_param1, wishFreeDaysCount);
			}
			else
			{
				wishStatus = ChosenWish;
			}
		}
		
		case MenuAction_DrawItem:
		{
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			int _target = StringToInt(_itemInfo);
			if(JB_HasFreeDayNextDay(_target))
			{
				return ITEMDRAW_DISABLED;
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void checkLast()
{
	PrintToChatAll("Check last, last = %i", last);
	if(last != 0)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T || JB_HasFreeDay(i) || JB_IsRebel(i))
		{
			continue;
		}
		
		last = i;
		break;
	}
	
	if(last == 0)
	{
		return;
	}
	
	char _targetName[LENGTH_64];
	GetClientName(last, _targetName, sizeof(_targetName));
	PrintToChatAll("%s \x07%s \x01został ostatnim więźniem.", JB_PREFIX, _targetName);
}