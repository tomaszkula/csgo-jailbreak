#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Warm Up"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

bool isGodModeEnabled = false;
int godModeTime = 0;
Handle godModeTimer = null;

ConVar cvGodModeDuration = null;
int godModeDuration = 0;

bool isEventHooked = false;

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
	CreateNative("JB_GetWarmUpGodModeTime", GetGodModeTime);
}

public void OnPluginStart()
{
	cvGodModeDuration = CreateConVar("jb_warmup_god_mode_duration", "60", "God mode duration for warm up");
	godModeDuration = cvGodModeDuration.IntValue;
	HookConVarChange(cvGodModeDuration, ConVar_GodeModeDuration);
}

public void OnDayModeChanged(DayMode _dayMode)
{
	if(_dayMode == WarmUp)
	{
		isEventHooked = HookEventEx("player_spawn", Event_PlayerSpawn_Post);
		
		isGodModeEnabled = true;
		for (int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i))
			{
				continue;
			}
			
			setGodMode(i, true);
		}
		
		godModeTime = godModeDuration;
		godModeTimer = CreateTimer(1.0, GodModeTimer, _, TIMER_REPEAT);
	}
	else
	{
		if(isGodModeEnabled == false)
		{
			return;
		}
		
		if(isEventHooked)
		{
			UnhookEvent("player_spawn", Event_PlayerSpawn_Post);
		}
		
		if(godModeTimer != INVALID_HANDLE)
		{
			KillTimer(godModeTimer);
			godModeTimer = INVALID_HANDLE;
		}
		
		isGodModeEnabled = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i))
			{
				continue;
			}
			
			setGodMode(i, false);
		}
	}
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	if(isGodModeEnabled)
	{
		setGodMode(_client, true);
	}
	
	return Plugin_Continue;
}

public void ConVar_GodeModeDuration(ConVar _convar, const char[] _oldValue, const char[] _newValue)
 {
     godModeDuration = StringToInt(_newValue);
 }
 
public Action GodModeTimer(Handle _timer)
{
	if(--godModeTime <= 0)
	{
		KillTimer(godModeTimer);
		godModeTimer = INVALID_HANDLE;
		
		isGodModeEnabled = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i))
			{
				continue;
			}
			
			setGodMode(i, false);
		}
	}
	
	return Plugin_Continue;
}

void setGodMode(int _client, bool _isGodModeEnabled)
{
	SetEntProp(_client, Prop_Data, "m_takedamage", _isGodModeEnabled ? 0 : 2, 1);
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int GetGodModeTime(Handle plugin, int argc)
{
	return godModeTime;
}