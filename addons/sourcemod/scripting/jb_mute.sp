#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Mute"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

bool isMuted[MAXPLAYERS][MAXPLAYERS];

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
	RegConsoleCmd("mute", MuteMenuCmd);
}

public Action MuteMenuCmd(int _client, int _args)
{
	displayMuteMenu(_client);
	return Plugin_Handled;
}

void displayMuteMenu(int _client)
{
	Menu _menu = CreateMenu(MuteMenuHandler);
	_menu.SetTitle("[ Wycisz/Odcisz gracza ]");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || i == _client)
		{
			continue;
		}
		
		char _targetName[LENGTH_64];
		GetClientName(i, _targetName, sizeof(_targetName));
		if(isMuted[_client][i])
		{
        	Format(_itemTitle, sizeof(_itemTitle), "%s [Wyciszony]", _targetName);
        }
		else
        {
        	Format(_itemTitle, sizeof(_itemTitle), "%s", _targetName);
       	}
		
		_menu.AddItem(_itemInfo, _itemTitle);
	}
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int MuteMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo));
			
			int _target = StringToInt(_itemInfo);
			if(!IsClientInGame(_target))
			{
				displayMuteMenu(_param1);
				return -1;
			}
			
			isMuted[_param1][_target] = !isMuted[_param1][_target];
			SetListenOverride(_param1, _target, isMuted[_param1][_target] ? Listen_No : Listen_Yes);
			
			displayMuteMenu(_param1);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}