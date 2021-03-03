#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Gun Menu"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

char guns[6][2][LENGTH_64] =
{
	{"weapon_ak47",					"AK-47"},
	{"weapon_m4a1_silencer",		"M4A1-S"},
	{"weapon_m4a1",					"M4A4"},
	{"weapon_awp",					"AWP"},
	{"weapon_galilar",				"Galil AR"},
	{"weapon_famas",				"Famas"}
};

bool isEventHooked[2];
bool isUsed[MAXPLAYERS];

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
	RegConsoleCmd("bronie", GunsMenuCmd);
	RegConsoleCmd("guns", GunsMenuCmd);
}

public void OnMapStart()
{
	for (int i = 0; i < sizeof(isEventHooked); i++)
	{
		isEventHooked[i] = false;
	}
}

public void OnDayModeChanged(DayMode _dayMode)
{
	if(_dayMode == WarmUp || _dayMode == Normal)
	{
		if(isEventHooked[0] == false) isEventHooked[0] = HookEventEx("round_prestart", Event_RoundPrestart_Post);
		if(isEventHooked[1] == false) isEventHooked[1] = HookEventEx("player_spawn", Event_PlayerSpawn_Post);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			isUsed[i] = false;
		}
	}
	else
	{
		if(isEventHooked[0]) UnhookEvent("round_prestart", Event_RoundPrestart_Post);
		if(isEventHooked[1]) UnhookEvent("player_spawn", Event_PlayerSpawn_Post);
	}
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		isUsed[i] = false;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	if(GetClientTeam(_client) == CS_TEAM_CT)
	{
		isUsed[_client] = false;
		displayGunsMenu(_client);
	}
	
	return Plugin_Continue;
}

public Action GunsMenuCmd(int _client, int _args)
{
	if(!IsPlayerAlive(_client) || GetClientTeam(_client) != CS_TEAM_CT || isUsed[_client])
	{
		return Plugin_Handled;
	}
	
	displayGunsMenu(_client);
	return Plugin_Handled;
}

void displayGunsMenu(int _client)
{
	if(!IsPlayerAlive(_client) || GetClientTeam(_client) != CS_TEAM_CT || isUsed[_client])
	{
		return;
	}
	
	Menu _menu = CreateMenu(GunsMenuHandler);
	_menu.SetTitle("[Menu] Wybierz broń");
	for (int i = 0; i < sizeof(guns); i++)
	{
		_menu.AddItem(guns[i][0], guns[i][1]);
	}
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int GunsMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(!IsPlayerAlive(_param1) || GetClientTeam(_param1) != CS_TEAM_CT || isUsed[_param1])
			{
				return -1;
			}
				
			isUsed[_param1] = true;
			
			char itemInfo[LENGTH_32];
			_menu.GetItem(_param2, itemInfo, sizeof(itemInfo));
			
			int _firstWeapon = GetPlayerWeaponSlot(_param1, 0);
			if(_firstWeapon != -1)
			{
				RemovePlayerItem(_param1, _firstWeapon);
			}
			GivePlayerItem(_param1, itemInfo);
			
			int _secondWeapon = GetPlayerWeaponSlot(_param1, 1);
			if(_secondWeapon != -1)
			{
				RemovePlayerItem(_param1, _secondWeapon);
			}
			GivePlayerItem(_param1, "weapon_deagle");
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}