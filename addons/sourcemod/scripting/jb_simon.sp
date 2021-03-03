#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Simon"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

#define AUTO_SIMON_DELAY 15.0

int simon = 0;
Handle autoSimonTimer = null;
GlobalForward onSimonChanged = null;

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("JB_GetSimon", GetSimon);
	CreateNative("JB_CanBeSimon", CanBeSimon);
	CreateNative("JB_AddSimon", AddSimon);
}

public void OnPluginStart()
{
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd_Post);
	HookEvent("player_team", Event_PlayerTeam_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
	
	onSimonChanged = CreateGlobalForward("OnSimonChanged", ET_Event, Param_Cell);
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	removeSimon();
	return Plugin_Continue;
}

public Action Event_RoundFreezeEnd_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	if(simon == 0)
	{
		autoSimonTimer = CreateTimer(AUTO_SIMON_DELAY, AutoSimonTimer);
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerTeam_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	bool _isDisconnected = _event.GetBool("disconnect");
	if(_isDisconnected)
	{
		int _client = GetClientOfUserId(_event.GetInt("userid"));
		if(_client == simon)
		{
			removeSimon();
			addRandomSimon();
		}
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	if(_victim == simon)
	{
		removeSimon();
		addRandomSimon();
	}
		
	return Plugin_Continue;
}

public Action AutoSimonTimer(Handle _timer)
{
	autoSimonTimer = INVALID_HANDLE;
	addRandomSimon();
	return Plugin_Handled;
}

void addRandomSimon()
{
	int _wardensCount = 0;
	int _wardens[MAXPLAYERS];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!JB_CanBeSimon(i))
		{
			continue;
		}
		
		_wardens[_wardensCount] = i;
		_wardensCount++;
	}
	
	if (_wardensCount > 0)
	{
		int _simon = _wardens[GetRandomInt(0, _wardensCount - 1)];
		JB_AddSimon(_simon);
		//JB_DisplaySimonMenu(_newSimon);
	}
}

void breakAutoSimonTimer()
{
	if(autoSimonTimer != INVALID_HANDLE)
	{
		KillTimer(autoSimonTimer);
		autoSimonTimer = INVALID_HANDLE;
    }
}

void removeSimon()
{
	simon = 0;
	Call_StartForward(onSimonChanged);
	Call_PushCell(0);
	Call_Finish();
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int GetSimon(Handle plugin, int argc)
{
	return simon;
}

public int CanBeSimon(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if (!IsClientInGame(_client) || !IsPlayerAlive(_client) || GetClientTeam(_client) != CS_TEAM_CT ||
		simon != 0 || JB_GetDayMode() != Normal)
	{
		return false;
	}
	
	return true;
}

public int AddSimon(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_CanBeSimon(_client) == false)
	{
		return false;
	}
	
	simon = _client;
	Call_StartForward(onSimonChanged);
	Call_PushCell(_client);
	Call_Finish();
	
	breakAutoSimonTimer();
	return true;
}