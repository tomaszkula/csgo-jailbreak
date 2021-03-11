#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Division"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

bool isDivided[MAXPLAYERS];
int dynamicGlow[MAXPLAYERS];

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
	CreateNative("JB_AddDivision", AddDivision);
	CreateNative("JB_RemoveDivision", RemoveDivision);
	CreateNative("JB_IsDivided", IsDivided);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
}

public void OnClientDisconnect_Post(int _client)
{
	JB_RemoveDivision(_client);
}

public void OnAddFreeDay(int _client)
{
	JB_RemoveDivision(_client);
}

public void OnAddRebel(int _client)
{
	JB_RemoveDivision(_client);
}

public void OnGameStart(int _gameID)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		JB_RemoveDivision(i);
	}
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		JB_RemoveDivision(i);
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	JB_RemoveDivision(_victim);
		
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int AddDivision(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	char _color[LENGTH_16];
	GetNativeString(2, _color, sizeof(_color));
	if(JB_IsDivided(_client))
	{
		return false;
	}
	
	isDivided[_client] = true;
	dynamicGlow[_client] = JB_RenderDynamicGlow(_client, _color);
	SDKHook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	return true;
}

public int RemoveDivision(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_IsDivided(_client) == false)
	{
		return false;
	}
	
	isDivided[_client] = false;
	SDKUnhook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	RemoveEntity(dynamicGlow[_client]);
	dynamicGlow[_client] = -1;
	return true;
}

public int IsDivided(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return isDivided[_client];
}