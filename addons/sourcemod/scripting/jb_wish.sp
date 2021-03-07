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

enum WishStatus
{
	NoWish = 0
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
	
	Menu menu = CreateMenu(WishMenuHandler, MENU_ACTIONS_ALL);
	menu.SetTitle("[ Życzenie ]");
	menu.AddItem(WISH_CUSTOM, "Własne życzenie");
	menu.AddItem(WISH_REVENGE, "Zemsta");
	menu.AddItem(WISH_FREEDAY, "FreeDay dla więźniów");
	menu.AddItem(WISH_DUEL, "Pojedynek");
	
	menu.ExitButton = false;
	menu.Display(_client, 20);
}

public int WishMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(_param1 != last)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			char _itemTitle[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo), _, _itemTitle, sizeof(_itemTitle)); 
			
			if(StrEqual(_itemInfo, WISH_CUSTOM))
			{
				
			}
			else if(StrEqual(_itemInfo, WISH_REVENGE))
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i) || !IsPlayerAlive(i)/* || GetClientTeam(i) != CS_TEAM_CT*/)
					{
						continue;
					}
					
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
				}
				
				GivePlayerItem(_param1, "weapon_ak47");
			}
			else if(StrEqual(_itemInfo, WISH_FREEDAY))
			{
				
			}
			
			char _targetName[LENGTH_64];
			GetClientName(_param1, _targetName, sizeof(_targetName));
			PrintToChatAll("%s Ostatni więzień \x07%s \x01wybrał \x10[%s]\x01.", JB_PREFIX, _targetName, _itemTitle);
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_Timeout)
			{
				PrintToChatAll("Timeout wish");
				//delete _menu;
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