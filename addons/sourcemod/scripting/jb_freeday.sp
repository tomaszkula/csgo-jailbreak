#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] FreeDay"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

bool hasFreeDay[MAXPLAYERS];
bool hasFreeDayNextDay[MAXPLAYERS];
int dynamicGlow[MAXPLAYERS];
GlobalForward onAddFreeDay = null;
GlobalForward onRemoveFreeDay = null;

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
	CreateNative("JB_AddFreeDay", AddFreeDay);
	CreateNative("JB_AddFreeDayNextDay", AddFreeDayNextDay);
	CreateNative("JB_RemoveFreeDay", RemoveFreeDay);
	CreateNative("JB_HasFreeDay", HasFreeDay);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
	
	onAddFreeDay = CreateGlobalForward("OnAddFreeDay", ET_Event, Param_Cell);
	onRemoveFreeDay = CreateGlobalForward("OnRemoveFreeDay", ET_Event, Param_Cell);
}

public void OnClientPutInServer(int _client)
{
	SDKHook(_client, SDKHook_OnTakeDamage, SDKHookCB_OnTakeDamage);
}

public void OnClientDisconnect_Post(int _client)
{
	JB_RemoveFreeDay(_client);
	hasFreeDayNextDay[_client] = false;
	killLastFreeDays();
}

public void OnAddRebel(int _client)
{
	JB_RemoveFreeDay(_client);
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		JB_RemoveFreeDay(i);
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	if(JB_GetDayMode() == Normal && hasFreeDayNextDay[_client])
	{
		hasFreeDayNextDay[_client] = false;
		JB_AddFreeDay(_client);
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	JB_RemoveFreeDay(_victim);
	
	killLastFreeDays();
	
	return Plugin_Continue;
}

public Action SDKHookCB_OnTakeDamage(int _victim, int &_attacker, int &_inflictor, float &_damage, int &_damagetype)
{
	if(_attacker > 0 && _attacker <= MaxClients && JB_HasFreeDay(_attacker))
	{
		return Plugin_Handled;
	}
		
	return Plugin_Continue;
}

void killLastFreeDays()
{
	int _freeDays[MAXPLAYERS];
	int _freeDaysCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(JB_HasFreeDay(i))
		{
			_freeDays[_freeDaysCount] = i;
			_freeDaysCount++;
		}
	}
	
	int _noFreeDaysCount = JB_GetPrisonersCount(true) - _freeDaysCount;
	if(_noFreeDaysCount <= 1)
	{
		for (int i = 0; i < _freeDaysCount; i++)
		{
			ForcePlayerSuicide(_freeDays[i]);
		}
	}
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int AddFreeDay(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_HasFreeDay(_client))
	{
		return;
	}
	
	hasFreeDay[_client] = true;
	dynamicGlow[_client] = JB_RenderDynamicGlow(_client, "0 255 0");
	SDKHook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	
	Call_StartForward(onAddFreeDay);
	Call_PushCell(_client);
	Call_Finish();
	
	killLastFreeDays();
}

public int AddFreeDayNextDay(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	hasFreeDayNextDay[_client] = true;
}

public int RemoveFreeDay(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_HasFreeDay(_client) == false)
	{
		return;
	}
	
	hasFreeDay[_client] = false;
	SDKUnhook(dynamicGlow[_client], SDKHook_SetTransmit, SDKHookCB_SetTransmit);
	RemoveEntity(dynamicGlow[_client]);
	dynamicGlow[_client] = -1;
	
	Call_StartForward(onRemoveFreeDay);
	Call_PushCell(_client);
	Call_Finish();
}

public int HasFreeDay(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return hasFreeDay[_client];
}