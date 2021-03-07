#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Random"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

bool isDrawn[MAXPLAYERS];

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char [] error, int err_max)
{
	CreateNative("JB_GetRandomPrisoner", GetRandomPrisoner);
	CreateNative("JB_ResetRepetitions", ResetRepetitions);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
}

public void OnClientDisconnect_Post(int _client)
{
	isDrawn[_client] = false;
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		isDrawn[i] = false;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	isDrawn[_victim] = false;
		
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int GetRandomPrisoner(Handle plugin, int argc)
{
	bool _canRepeat = GetNativeCell(1);
	
	int _clients[MAXPLAYERS], _count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T || JB_HasFreeDay(i) || JB_IsRebel(i))
		{
			continue;
		}
			
		if(!_canRepeat && isDrawn[i])
		{
			continue;
		}
		
		_clients[_count] = i;
		_count++;
	}
	
	if(_count < 1)
	{
		return 0;
	}
	
	int _clientID = GetRandomInt(0, _count - 1);
	int _client = _clients[_clientID];
	if(!_canRepeat)
	{
		isDrawn[_client] = true;
	}
	return _client;
}

public int ResetRepetitions(Handle plugin, int argc)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		isDrawn[i] = false;
	}
}