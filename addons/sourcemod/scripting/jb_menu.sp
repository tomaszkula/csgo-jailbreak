#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Menu"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

#define WARDEN_MENU_ADD_SIMON "warden_menu_add_simon"

//#define WARDENMENU_SEARCH "search"

#define SIMON_MENU "simon_menu"
#define SIMON_MENU_OPEN_CELLS "simon_menu_open_cells"
#define SIMON_MENU_MINI_GAMES_MENU "simon_menu_mini_games_menu"
#define SIMON_MENU_GAMES_MENU "simon_menu_games_menu"

#define PRISONERS_MANAGER_MENU "prisoners_manager_menu"
#define PRISONERS_MANAGER_MENU_RANDOM_MENU "prisoners_manager_menu_random_menu"
#define PRISONERS_MANAGER_MENU_HEAL_MENU "prisoners_manager_menu_heal_menu"
#define PRISONERS_MANAGER_MENU_FREEDAY_MENU "prisoners_manager_menu_freeday_menu"
#define PRISONERS_MANAGER_MENU_REBEL_MENU "prisoners_manager_menu_rebel_menu"

#define RANDOM_MENU_REPETITION "random_menu_repetition"
#define RANDOM_MENU_NO_REPETITION "random_menu_no_repetition"
#define RANDOM_MENU_RESET "random_menu_reset"
#define RANDOM_MENU_BLANK "blank"

#define HEAL_100_HP_MENU "heal_100_hp_menu"
#define HEAL_MAX_HP_MENU "heal_max_hp_menu"

#define DIVISION_MENU "division_menu"
char divisionColors[][][] =
{
	{"żółty",			"255 255 0"},
	{"aqua",			"0 255 255"},
	{"magenta",			"255 0 255"},
	{"biały",			"255 255 255"},
	{"czarny",			"0 0 0"}
};

#define ADMIN_MENU "admin_menu"
#define ADMIN_MENU_REVIVE_MENU "admin_menu_revive_menu"
#define ADMIN_MENU_CELLS_MENU "admin_menu_cells_menu"

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

public void OnSimonChanged(int _simon)
{
	if(_simon == 0)
	{
		return;
	}
	
	displaySimonMenu(_simon);
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
			displayPrisonersMenu(_client);
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
		_menu.AddItem(SIMON_MENU, "Menu Prowadzącego");
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
				displayMenu(_param1);
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, WARDEN_MENU_ADD_SIMON))
			{
				JB_AddSimon(_param1);
				displayWardenMenu(_param1);
			}
			else if(StrEqual(_itemInfo, SIMON_MENU))
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
			else
			{
				displayMenu(_param1);
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

void displayPrisonersMenu(int _client)
{
	if(!IsPlayerAlive(_client) || GetClientTeam(_client) != CS_TEAM_T)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(PrisonersMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU WIĘŹNIA ]");
	_menu.AddItem(ADMIN_MENU, "Menu Admina");
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int PrisonersMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(!IsPlayerAlive(_param1) || GetClientTeam(_param1) != CS_TEAM_T)
			{
				displayMenu(_param1);
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

void displayOtherMenu(int _client)
{
	if(IsPlayerAlive(_client))
	{
		displayMenu(_client);
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
				displayMenu(_param1);
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

void displaySimonMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(SimonMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU PROWADZĄCEGO ]");
	_menu.AddItem(SIMON_MENU_OPEN_CELLS, "Otwórz cele");
	_menu.AddItem(PRISONERS_MANAGER_MENU, "Menu zarządzania więźniami");
	_menu.AddItem(SIMON_MENU_MINI_GAMES_MENU, "Menu mini zabaw");
	_menu.AddItem(SIMON_MENU_GAMES_MENU, "Menu zabaw");
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
				return - 1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, SIMON_MENU_OPEN_CELLS))
			{
				JB_OpenCells();
				displaySimonMenu(_param1);
			}
			else if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU))
			{
				displayPrisonersManagerMenu(_param1);
			}
			else if(StrEqual(_itemInfo, SIMON_MENU_MINI_GAMES_MENU))
			{
				
			}
			else if(StrEqual(_itemInfo, SIMON_MENU_GAMES_MENU))
			{
				
			}
			else
			{
				displayMenu(_param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displayMenu(_param1);
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
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(PrisonersManagerMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[Menu] Zarządzanie więźniami");
	_menu.AddItem(PRISONERS_MANAGER_MENU_RANDOM_MENU, "Wylosuj więźnia");
	_menu.AddItem(PRISONERS_MANAGER_MENU_HEAL_MENU, "Ulecz więźnia");
	_menu.AddItem(DIVISION_MENU, "Podziel więźniów");
	_menu.AddItem(PRISONERS_MANAGER_MENU_FREEDAY_MENU, "Daj/Zabierz FreeDay'a");
	_menu.AddItem(PRISONERS_MANAGER_MENU_REBEL_MENU, "Zabierz buntownika");
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_RANDOM_MENU))
			{
				displayRandomMenu(_param1);
			}
			else if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_HEAL_MENU))
			{
				displayHealMenu(_param1);
			}
			else if(StrEqual(_itemInfo, DIVISION_MENU))
			{
				displayDivisionMenu(_param1);
			}
			else if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_FREEDAY_MENU))
			{
				displayFreeDayMenu(_param1);
			}
			else if(StrEqual(_itemInfo, PRISONERS_MANAGER_MENU_REBEL_MENU))
			{
				displayRebelMenu(_param1);
			}
			else
			{
				displaySimonMenu(_param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displaySimonMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayRandomMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(RandomMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Wylosuj więźnia ]");
	_menu.AddItem(RANDOM_MENU_REPETITION, "Losuj z powtórzeniami");
	_menu.AddItem(RANDOM_MENU_BLANK, "");
	_menu.AddItem(RANDOM_MENU_BLANK, "");
	_menu.AddItem(RANDOM_MENU_NO_REPETITION, "Losuj bez powtórzeń");
	_menu.AddItem(RANDOM_MENU_RESET, "Zresetuj powtórzenia");
	_menu.ExitBackButton = true;
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int RandomMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				displayMenu(_param1);
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, RANDOM_MENU_REPETITION))
			{
				int _target = JB_GetRandomPrisoner(true);
				if(_target == 0)
				{
					PrintToChat(_param1, "%s Brak więźniów do wylosowania.", JB_PREFIX);
				}
				else
				{
					char _targetName[LENGTH_64];
					GetClientName(_target, _targetName, sizeof(_targetName));
					PrintCenterTextAll("Wylosowano %s", _targetName);
				}
				displayRandomMenu(_param1);
			}
			else if(StrEqual(_itemInfo, RANDOM_MENU_NO_REPETITION))
			{
				int _target = JB_GetRandomPrisoner(false);
				if(_target == 0)
				{
					PrintToChat(_param1, "%s Brak więźniów do wylosowania.", JB_PREFIX);
				}
				else
				{
					char _targetName[LENGTH_64];
					GetClientName(_target, _targetName, sizeof(_targetName));
					PrintCenterTextAll("Wylosowano %s", _targetName);
				}
				displayRandomMenu(_param1);
			}
			else if(StrEqual(_itemInfo, RANDOM_MENU_RESET))
			{
				JB_ResetRepetitions();
				displayRandomMenu(_param1);
			}
		}
		
		case MenuAction_DrawItem:
		{
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, RANDOM_MENU_BLANK))
			{
				return ITEMDRAW_SPACER;
			}
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
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

void displayHealMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(HealMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[Menu] Ulecz więźnia");
	_menu.AddItem(HEAL_100_HP_MENU, "Do 100 HP");
	_menu.AddItem(HEAL_MAX_HP_MENU, "Do maksymalnego HP");
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
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
			else
			{
				displayPrisonersManagerMenu(_param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
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

void displayHeal100HPMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(Heal100HPMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Ulecz więźnia do 100 HP ]");
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
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
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
			displayHealMenu(_param1);
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displayHealMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayDivisionMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(DivisionMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Podziel więźniów ]");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	_menu.AddItem("0", "Usuń podział");
	for (int i = 1; i < sizeof(divisionColors); i++)
	{
		Format(_itemInfo, sizeof(_itemInfo), "%i", i + 1);
		Format(_itemTitle, sizeof(_itemTitle), "%i drużyny", i + 1);
		_menu.AddItem(_itemInfo, _itemTitle);
	}
	_menu.ExitBackButton = true;
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int DivisionMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				displayMenu(_param1);
				return - 1;
			}
			
			char _itemInfo[LENGTH_4];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo));
			int _divisionsCount = StringToInt(_itemInfo);
			
			if(_divisionsCount == 0)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
			    	JB_RemoveDivision(i);
				}
				PrintToChatAll("%s Usunięto podział na kolory", JB_PREFIX, _divisionsCount);
			}
			else
			{
				int _clients[MAXPLAYERS], _clientsCount = 0;
				for(int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T || JB_IsRebel(i) || JB_HasFreeDay(i))
			    	{
			        	continue;
			        }
			        
					_clients[_clientsCount] = i;
					_clientsCount++;
				}
				
				JB_Permute(_clients, _clientsCount);
				for (int i = 0; i < _clientsCount; i++)
				{
					JB_RemoveDivision(_clients[i]);
			        
					int _divisionID = i % _divisionsCount;
					JB_AddDivision(_clients[i], divisionColors[_divisionID][1]);
				}
				
				PrintToChatAll("%s Podzielono więźniów na \x10%i \x01kolorów", JB_PREFIX, _divisionsCount);
			}
			
			displayDivisionMenu(_param1);
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
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

void displayFreeDayMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(FreeDayMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Daj/Zabierz FreeDay'a ]");
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for(int i = 1; i <= MaxClients; i++)
	{
    	if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T || JB_IsRebel(i))
    	{
        	continue;
        }
        
        char _targetName[LENGTH_64];
        GetClientName(i, _targetName, sizeof(_targetName));
        
        Format(_itemInfo, sizeof(_itemInfo), "%i", i);
        if(JB_HasFreeDay(i))
        {
        	Format(_itemTitle, sizeof(_itemTitle), "%s [ZABIERZ]", _targetName);
        }
        else
        {
        	Format(_itemTitle, sizeof(_itemTitle), "%s [DAJ]", _targetName);
       	}
        _menu.AddItem(_itemInfo, _itemTitle);
	}
	_menu.ExitBackButton = true;
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int FreeDayMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(JB_GetSimon() != _param1)
			{
				displayMenu(_param1);
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			int _target = StringToInt(_itemInfo);
			if(!IsClientInGame(_target) || !IsPlayerAlive(_target) || GetClientTeam(_target) != CS_TEAM_T)
	    	{
	        	displayFreeDayMenu(_param1);
	        	return -1;
	        }
			
			char _targetName[LENGTH_64];
			GetClientName(_target, _targetName, sizeof(_targetName));
			if(JB_HasFreeDay(_target))
	    	{
	    		JB_RemoveFreeDay(_target);
	    		PrintToChatAll("%s Prowadzący zabrał \x04FreeDay'a więźniowi \x07%s\x01.", JB_PREFIX, _targetName);
	        }
			else
	        {
	        	JB_AddFreeDay(_target);
	        	PrintToChatAll("%s Prowadzący dał \x04FreeDay'a więźniowi \x07%s\x01.", JB_PREFIX, _targetName);
	       	}
			displayFreeDayMenu(_param1);
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
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

void displayRebelMenu(int _client)
{
	if(JB_GetSimon() != _client)
	{
		displayMenu(_client);
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
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
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
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
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

void displayAdminMenu(int _client)
{
	if(GetUserAdmin(_client) == INVALID_ADMIN_ID)
	{
		displayMenu(_client);
		return;
	}
	
	Menu _menu = CreateMenu(AdminMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ MENU ADMINA ]");
	_menu.AddItem(ADMIN_MENU_REVIVE_MENU, "Ożyw gracza");
	_menu.AddItem(ADMIN_MENU_CELLS_MENU, "Ustaw przyciski cel");
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			if(StrEqual(_itemInfo, ADMIN_MENU_REVIVE_MENU))
			{
				displayReviveMenu(_param1);
			}
			else if(StrEqual(_itemInfo, ADMIN_MENU_CELLS_MENU))
			{
				displayCellsMenu(_param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displayMenu(_param1);
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
		displayMenu(_client);
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
	_menu.ExitBackButton = true;
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
				displayMenu(_param1);
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
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displayAdminMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}

void displayCellsMenu(int _client)
{
	if(GetUserAdmin(_client) == INVALID_ADMIN_ID)
	{
		displayMenu(_client);
		return;
	}
	
	
	Menu _menu = CreateMenu(CellsMenuHandler, MENU_ACTIONS_ALL);
	_menu.SetTitle("[ Ustaw przyciski cel ]");
	int _buttonsCount = JB_GetCellButtonsCount();
	int [] _buttons = new int[_buttonsCount];
	JB_GetCellButtons(_buttons, _buttonsCount);
	char _itemInfo[LENGTH_4], _itemTitle[LENGTH_64];
	for(int i = 0; i < _buttonsCount; i++)
	{
		Format(_itemInfo, sizeof(_itemInfo), "%i", i);
		if(IsValidEntity(_buttons[i]))
		{
			Format(_itemTitle, sizeof(_itemTitle), "[Zresetuj] SLOT %i, id = %i", i + 1, _buttons[i]);
		}
		else
		{
			Format(_itemTitle, sizeof(_itemTitle), "[USTAW] SLOT %i", i + 1);
		}
		_menu.AddItem(_itemInfo, _itemTitle);
	} 
	_menu.ExitBackButton = true;
	_menu.Display(_client, MENU_TIME_FOREVER);
}

public int CellsMenuHandler(Menu _menu, MenuAction _action, int _param1, int _param2)
{
	switch(_action)
	{
		case MenuAction_Select:
		{
			if(GetUserAdmin(_param1) == INVALID_ADMIN_ID)
			{
				displayMenu(_param1);
				return -1;
			}
			
			char _itemInfo[LENGTH_64];
			_menu.GetItem(_param2, _itemInfo, sizeof(_itemInfo)); 
			
			int _buttonsCount = JB_GetCellButtonsCount();
			int [] _buttons = new int[_buttonsCount];
			JB_GetCellButtons(_buttons, _buttonsCount);
			if(_param2 < 0 || _param2 >= _buttonsCount)
			{
				displayCellsMenu(_param1);
				return -1;
			}
			
			if(IsValidEntity(_buttons[_param2]))
			{
				JB_SetCellButton(_param2, -1);
			}
			else
			{
				int _entity = GetClientAimTarget(_param1, false);
				if(IsValidEntity(_entity))
				{
					char _entityClassname[LENGTH_64];
					GetEntityClassname(_entity, _entityClassname, sizeof(_entityClassname));
					if(!StrEqual(_entityClassname, "func_button"))
					{
						displayCellsMenu(_param1);
						return -1;
					}
						
					float _entityOrigin[3], _clientOrigin[3];
					GetEntPropVector(_entity, Prop_Send, "m_vecOrigin", _entityOrigin);
					GetClientAbsOrigin(_param1, _clientOrigin);
					float _distance = GetVectorDistance(_entityOrigin, _clientOrigin);
					if(_distance < 200.0)
					{
						JB_SetCellButton(_param2, _entity);
					}
				}
			}
			
			displayCellsMenu(_param1);
		}
		
		case MenuAction_Cancel:
		{
			if(_param2 == MenuCancel_ExitBack | MenuCancel_Interrupted)
			{
				displayAdminMenu(_param1);
			}
		}
		
		case MenuAction_End:
		{
			delete _menu;
		}
	}
	
	return 0;
}