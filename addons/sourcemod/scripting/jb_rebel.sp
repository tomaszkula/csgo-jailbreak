#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Rebel"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

bool isEventHooked[3];
bool isRebel[MAXPLAYERS];
int dynamicGlow[MAXPLAYERS];
GlobalForward onAddRebel = null;

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
	onAddRebel = CreateGlobalForward("OnAddRebel", ET_Event, Param_Cell);
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
	if(_dayMode == Normal)
	{
		if(isEventHooked[0] == false) isEventHooked[0] = HookEventEx("round_prestart", Event_RoundPrestart_Post);
		if(isEventHooked[1] == false) isEventHooked[1] = HookEventEx("player_team", Event_PlayerTeam_Post);
		if(isEventHooked[2] == false) isEventHooked[2] = HookEventEx("player_death", Event_PlayerDeath_Post);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			isRebel[i] = false;
			dynamicGlow[i] = -1;
		}
	}
	else
	{
		if(isEventHooked[0]) UnhookEvent("round_prestart", Event_RoundPrestart_Post);
		if(isEventHooked[1]) UnhookEvent("player_team", Event_PlayerTeam_Post);
		if(isEventHooked[2]) UnhookEvent("player_death", Event_PlayerDeath_Post);
	}
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		isRebel[i] = false;
		dynamicGlow[i] = -1;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerTeam_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	bool _isDisconnected = _event.GetBool("disconnect");
	if(_isDisconnected)
	{
		int _client = GetClientOfUserId(_event.GetInt("userid"));
		isRebel[_client] = false;
		dynamicGlow[_client] = -1;
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
	
	if(JB_IsRebel(_victim))
	{
		JB_RemoveRebel(_victim);
	}
		
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int AddRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_IsRebel(_client))
	{
		return;
	}
	
	isRebel[_client] = true;
	dynamicGlow[_client] = JB_RenderDynamicGlow(_client, "255 0 0");
	SDKHook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	
	Call_StartForward(onAddRebel);
	Call_PushCell(_client);
	Call_Finish();
}

public int RemoveRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_IsRebel(_client) == false)
	{
		return;
	}
	
	isRebel[_client] = false;
	SDKUnhook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	RemoveEntity(dynamicGlow[_client]);
	dynamicGlow[_client] = -1;
}

public int IsRebel(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return isRebel[_client];
}