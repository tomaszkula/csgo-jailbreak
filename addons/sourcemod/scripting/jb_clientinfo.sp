#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Client Info"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

Handle clientInfoHUD = null;

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
	clientInfoHUD = CreateHudSynchronizer();
}

public void OnMapStart()
{
	CreateTimer(0.2, DisplayClientInfoHUD, _, TIMER_REPEAT);
}

public Action DisplayClientInfoHUD(Handle _timer)
{
	SetHudTextParams(-1.0, 0.8, 0.3, 255, 255, 110, 0);
	for(int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i))
        {
        	continue;
        }
        
        int _target = JB_TraceClientViewEntity(i);
        if (_target < 1 || _target > MaxClients || !IsClientInGame(_target) || !IsPlayerAlive(_target))
        {
        	continue;
        }
        
        char _targetName[LENGTH_64];
        GetClientName(_target, _targetName, sizeof(_targetName));
        
        int _targetHealth = GetClientHealth(_target);
        
        switch(GetClientTeam(i))
        {
        	case CS_TEAM_CT:
        	{
        		switch(GetClientTeam(_target))
        		{
        			case CS_TEAM_CT:
        				ShowSyncHudText(i, clientInfoHUD, "Strażnik : %s\nHP : %i", _targetName, _targetHealth);
        				
        			case CS_TEAM_T:
        				ShowSyncHudText(i, clientInfoHUD, "Więzień : %s\nHP : %i", _targetName, _targetHealth);
        		}
        	}
        	
        	case CS_TEAM_T:
        	{
        		switch(GetClientTeam(_target))
        		{
        			case CS_TEAM_CT:
        				ShowSyncHudText(i, clientInfoHUD, "Strażnik : %s", _targetName);
        				
        			case CS_TEAM_T:
        				ShowSyncHudText(i, clientInfoHUD, "Więzień : %s\nHP : %i", _targetName, _targetHealth);
        		}
        	}
       	}
    }
    
   	return Plugin_Continue;
}