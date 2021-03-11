#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Rebel"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

bool isRebel[MAXPLAYERS];
int dynamicGlow[MAXPLAYERS];
GlobalForward onAddRebel = null;
GlobalForward onRemoveRebel = null;

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
	CreateNative("JB_AddRebel", AddRebel);
	CreateNative("JB_RemoveRebel", RemoveRebel);
	CreateNative("JB_IsRebel", IsRebel);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
	
	onAddRebel = CreateGlobalForward("OnAddRebel", ET_Event, Param_Cell);
	onRemoveRebel = CreateGlobalForward("OnRemoveRebel", ET_Event, Param_Cell);
}

public void OnClientDisconnect_Post(int _client)
{
	JB_RemoveRebel(_client);
}

public void OnGameStart(int _gameID)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		JB_RemoveRebel(i);
	}
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		JB_RemoveRebel(i);
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	int _killer = GetClientOfUserId(_event.GetInt("attacker"));
	
	if(GetClientTeam(_victim) == CS_TEAM_CT && GetClientTeam(_killer) == CS_TEAM_T)
	{
		JB_AddRebel(_killer);
	}
	
	JB_RemoveRebel(_victim);
		
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int AddRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_IsRebel(_client) || JB_GetDayMode() != Normal)
	{
		return false;
	}
	
	isRebel[_client] = true;
	dynamicGlow[_client] = JB_RenderDynamicGlow(_client, "255 0 0");
	SDKHook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	
	Call_StartForward(onAddRebel);
	Call_PushCell(_client);
	Call_Finish();
	return true;
}

public int RemoveRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_IsRebel(_client) == false)
	{
		return false;
	}
	
	isRebel[_client] = false;
	SDKUnhook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	RemoveEntity(dynamicGlow[_client]);
	dynamicGlow[_client] = -1;
	
	Call_StartForward(onRemoveRebel);
	Call_PushCell(_client);
	Call_Finish();
	return true;
}

public int IsRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return isRebel[_client];
}