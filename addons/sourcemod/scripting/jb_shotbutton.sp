#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Shot Button"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

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
	HookEvent("round_start", Event_RoundStart_Post);
}

public Action Event_RoundStart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _entity = -1;
	while ((_entity = FindEntityByClassname(_entity, "func_button")) != -1)
	{
		SetEntProp(_entity, Prop_Data, "m_spawnflags", GetEntProp(_entity, Prop_Data, "m_spawnflags") | 32 | 512);
		SDKHook(_entity, SDKHook_OnTakeDamage, SDKHookCB_OnTakeDamage);
	}
	
	return Plugin_Continue;
}

public Action SDKHookCB_OnTakeDamage(int _victim, int& _attacker, int& _inflictor, float& _damage, int& _damagetype)
{
	if(JB_GetSimon() == _attacker)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}