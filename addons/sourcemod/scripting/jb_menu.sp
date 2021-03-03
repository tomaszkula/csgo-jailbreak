#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Menu"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

#define WARDEN_MENU_ADD_SIMON "warden_menu_add_simon"
#define WARDEN_MENU_SIMON_MENU "warden_menu_simon_menu"
//#define WARDENMENU_SEARCH "search"

#define SIMON_MENU_OPEN_CELLS "simon_menu_open_cells"
#define SIMON_MENU_PRISONERS_MANAGER_MENU "simon_menu_prisoners_manager_menu"
#define SIMON_MENU_MINI_GAMES_MENU "simon_menu_mini_games_menu"
#define SIMON_MENU_GAMES_MENU "simon_menu_games_menu"

#define PRISONERS_MANAGER_MENU_HEAL_MENU "prisoners_manager_menu_heal_menu"
#define PRISONERS_MANAGER_MENU_REBEL_MENU "prisoners_manager_menu_rebel_menu"

#define HEAL_100_HP_MENU "heal_100_hp_menu"
#define HEAL_MAX_HP_MENU "heal_max_hp_menu"

#define ADMIN_MENU "admin_menu"
#define ADMIN_MENU_REVIVE_MENU "admin_menu_revive_menu"

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
	RegConsoleCmd("menu", MenuCmd);
}

public Action MenuCmd(int _client, int args)
{
	displayMenu(_client);
	return Plugin_Handled;
}

void displayMenu(int _client)
{
	if(IsPlayerAlive(_client))
	{
		if(GetClientTeam(_client) == CS_TEAM_CT)
		{
			displayWardenMenu(_client);
		}
		else
		{
		}
	}
	else
	{
		displayOtherMenu(_client);
	}
}

void displayWardenMenu(int _client)
{
	if(!IsPlayerAlive(_client) || GetClientTeam(_client) != CS_TEAM_CT)
	{
		return;
	}
	
	Menu _menu = CreateMenu(WardenMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU STRAŻNIKA ]");
	if (JB_GetSimon() == _client)
	{
		_menu.AddItem(WARDEN_MENU_SIMON_MENU, "Menu Prowadzącego");
	}
	else
	{
		_menu.AddItem(WARDEN_MENU_ADD_SIMON, "Zostań Prowadzącym");
	}
	//_menu.AddItem(WARDENMENU_SEARCH, "Przeszukaj więźnia");
	_menu.AddItem(ADMIN_MENU, "Menu Admina");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int WardenMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(!IsPlayerAlive(_param1) || GetClientTeam(_param1) != CS_TEAM_CT)
			{
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, WARDEN_MENU_ADD_SIMON))
			{
				JB_AddSimon(_param1);
				displayWardenMenu(_param1);
			}
			else if(StrEqual(_itemInfo, WARDEN_MENU_SIMON_MENU))
			{
				if(JB_GetSimon() == _param1)
				{
					displaySimonMenu(_param1);
				}
				else
				{
					displayWardenMenu(_param1);
				}
			}
			else if(StrEqual(_itemInfo, ADMIN_MENU))
			{
				if(GetUserAdmin(_param1) != INVALID_ADMIN_ID)
				{
					displayAdminMenu(_param1);
				}
				else
				{
					displayWardenMenu(_param1);
				}	
			}
			/*else if(StrEqual(szItemInfo, WARDENMENU_SEARCH))
			{
				FakeClientCommand(iClient, "search");
				DisplayWardenMenu(iClient);
			}*/
			
			/*if(!GetAdminFlag(GetUserAdmin(iClient), Admin_Ban))
			{
				if(StrEqual(szItemInfo, WARDENMENU_ADMINMENU))
					return -1;
			}
			else
			{
				if(StrEqual(szItemInfo, WARDENMENU_ADMINMENU))
					JB_DisplayAdminMenu(iClient);
			}*/
		}
		
		case MenuAction_DrawItem:
		{
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, WARDEN_MENU_ADD_SIMON) && JB_CanBeSimon(_param1) == false)
			{
				return ITEMDRAW_DISABLED;
			}
			/*else if(StrEqual(szItemInfo, WARDENMENU_ADMINMENU) && !GetAdminFlag(GetUserAdmin(iClient), Admin_Ban))
				return ITEMDRAW_DISABLED;*/
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displaySimonMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		return;
	}
	
	Menu _menu = CreateMenu(SimonMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU PROWADZĄCEGO ]");
	_menu.AddItem(SIMON_MENU_OPEN_CELLS, "Otwórz cele");
	_menu.AddItem(SIMON_MENU_PRISONERS_MANAGER_MENU, "Menu zarządzania więźniami");
	_menu.AddItem(SIMON_MENU_MINI_GAMES_MENU, "Menu mini zabaw");
	_menu.AddItem(SIMON_MENU_GAMES_MENU, "Menu zabaw");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int SimonMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, SIMON_MENU_PRISONERS_MANAGER_MENU))
			{
				displayPrisonersManagerMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayPrisonersManagerMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		return;
	}
	
	Menu _menu = CreateMenu(PrisonersManagerMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[Menu] Zarządzanie więźniami");
	_menu.AddItem(PRISONERS_MANAGER_MENU_HEAL_MENU, "Ulecz więźnia");
	_menu.AddItem(PRISONERS_MANAGER_MENU_REBEL_MENU, "Zabierz buntownika");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int PrisonersManagerMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_HEAL_MENU))
			{
				displayHealMenu(_param1);
			}
			else if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_REBEL_MENU))
			{
				displayRebelMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayHealMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		return;
	}
	
	Menu _menu = CreateMenu(HealMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[Menu] Ulecz więźnia");
	_menu.AddItem(HEAL_100_HP_MENU, "Do 100 HP");
	_menu.AddItem(HEAL_MAX_HP_MENU, "Do maksymalnego HP");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int HealMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, HEAL_100_HP_MENU))
			{
				displayHeal100HPMenu(_param1);
			}
			else if(StrEqual(_itemInfo, HEAL_MAX_HP_MENU))
			{
				//displayHealMenu(_param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			displaySimonMenu(_param1);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayHeal100HPMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		return;
	}
	
	Menu _menu = CreateMenu(Heal100HPMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[Menu] Ulecz więźnia do 100 HP");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for(int i = 1; i <= MaxClients; i++)
	{
    	if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T || !JB_CanHeal(i, 100))
    	{
        	continue;
        }
        
        char _targetName[LENGTH_64];
        GetClientName(i, _targetName, sizeof(_targetName));
        
        Format(_itemInfo, sizeof(_itemInfo), "%i", i);
        Format(_itemTitle, sizeof(_itemTitle), "%s [%iHP]", _targetName, GetClientHealth(i));
        _menu.AddItem(_itemInfo, _itemTitle);
	} 
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int Heal100HPMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			int _target = StringToInt(_itemInfo);
			
			if(!IsClientInGame(_target) || !IsPlayerAlive(_target) || GetClientTeam(_target) != CS_TEAM_T)
	    	{
	    		displayHealMenu(_param1);
	        	return -1;
	        }
			
			char _targetName[LENGTH_64];
			GetClientName(_target, _targetName, sizeof(_targetName));
			
			SetEntityHealth(_target, 100);
			PrintToChatAll("%s Więzień \x07%s \x01został uleczony przez prowadzącego.", JB_PREFIX, _targetName);
		}
		
		case MenuAction_Cancel:
		{
			displayHealMenu(_param1);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayRebelMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		return;
	}
	
	Menu _menu = CreateMenu(RebelMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Zabierz buntownika ]");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for(int i = 1; i <= MaxClients; i++)
	{
    	if(!JB_IsRebel(i))
    	{
        	continue;
        }
        
        char _targetName[LENGTH_64];
        GetClientName(i, _targetName, sizeof(_targetName));
        
        Format(_itemInfo, sizeof(_itemInfo), "%i", i);
        Format(_itemTitle, sizeof(_itemTitle), "%s", _targetName);
        _menu.AddItem(_itemInfo, _itemTitle);
	} 
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int RebelMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			int _target = StringToInt(_itemInfo);
			
			if(JB_RemoveRebel(_target))
	    	{
	    		char _targetName[LENGTH_64];
	    		GetClientName(_target, _targetName, sizeof(_targetName));
	    		PrintToChatAll("%s Prowadzący zabrał buntownika więźniowi \x07%s\x01.", JB_PREFIX, _targetName);
	    		
	    		displayRebelMenu(_param1);
	        }
			else
	        {
	        	displayRebelMenu(_param1);
	        	return -1;
	       	}
		}
		
		case MenuAction_Cancel:
		{
			displaySimonMenu(_param1);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayAdminMenu(int _client)
{
	if(GetUserAdmin(_client) == INVALID_ADMIN_ID)
	{
		return;
	}
	
	Menu _menu = CreateMenu(AdminMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU ADMINA ]");
	_menu.AddItem(ADMIN_MENU_REVIVE_MENU, "Ożyw gracza");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int AdminMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(GetUserAdmin(_param1) == INVALID_ADMIN_ID)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, ADMIN_MENU_REVIVE_MENU))
			{
				displayReviveMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayReviveMenu(int _client)
{
	if(GetUserAdmin(_client) == INVALID_ADMIN_ID)
	{
		return;
	}
	
	Menu _menu = CreateMenu(ReviveMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Ożyw gracza ]");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for(int i = 1; i <= MaxClients; i++)
	{
    	if(!JB_CanBeRevived(i))
    	{
        	continue;
        }
        
        char _targetName[LENGTH_64];
        GetClientName(i, _targetName, sizeof(_targetName));
        
        Format(_itemInfo, sizeof(_itemInfo), "%i", i);
        Format(_itemTitle, sizeof(_itemTitle), "%s", _targetName);
        _menu.AddItem(_itemInfo, _itemTitle);
	} 
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int ReviveMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(GetUserAdmin(_param1) == INVALID_ADMIN_ID)
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			int _target = StringToInt(_itemInfo);
			
			if(JB_Revive(_target))
	    	{
	    		char _targetName[LENGTH_64];
	    		GetClientName(_target, _targetName, sizeof(_targetName));
	    		PrintToChatAll("%s Admin ożywił gracza %s.", JB_PREFIX, _targetName);
	    		
	    		displayReviveMenu(_param1);
	        }
			else
	        {
	        	displayReviveMenu(_param1);
	        	return -1;
	       	}
		}
		
		case MenuAction_Cancel:
		{
			displayAdminMenu(_param1);
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayOtherMenu(int _client)
{
	if(IsPlayerAlive(_client))
	{
		return;
	}
	
	Menu _menu = CreateMenu(OtherMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU OBSERWATORA ]");
	_menu.AddItem(ADMIN_MENU, "Menu Admina");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int OtherMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(IsPlayerAlive(_param1))
			{
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, ADMIN_MENU))
			{
				if(GetUserAdmin(_param1) != INVALID_ADMIN_ID)
				{
					displayAdminMenu(_param1);
				}
				else
				{
					displayMenu(_param1);
				}	
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}