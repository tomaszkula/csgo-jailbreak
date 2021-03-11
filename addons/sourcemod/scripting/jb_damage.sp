#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Damage"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

DamageMode damageMode = TvCT;

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
	CreateNative("JB_SetDamageMode", SetDamageMode);
}

public void OnClientPutInServer(int _client)
{
	SDKHook(_client, SDKHook_OnTakeDamage, SDKHookCB_OnTakeDamage);
}

public Action SDKHookCB_OnTakeDamage(int _victim, int &_attacker, int &_inflictor, float &_damage, int &_damagetype)
{
	if(_victim <= 0 || _victim > MaxClients || _attacker <= 0 || _attacker > MaxClients ||
		_victim == _attacker)
	{
		return Plugin_Continue;
	}
	
	int _victimTeam = GetClientTeam(_victim);
	int _attackerTeam = GetClientTeam(_attacker);
	
	switch(damageMode)
	{
		case v:
		{
			return Plugin_Handled;
		}
		
		case TvCT:
		{
			if(_victimTeam == _attackerTeam)
			{
				return Plugin_Handled;
			}
		}
		
		case TvT:
		{
			if(_victimTeam != CS_TEAM_T || _attackerTeam != CS_TEAM_T)
			{
				return Plugin_Handled;
			}
		}
		
		case CTvCT:
		{
			if(_victimTeam != CS_TEAM_CT || _attackerTeam != CS_TEAM_CT)
			{
				return Plugin_Handled;
			}
		}
		
		case TvT_CTvCT:
		{
			if((_victimTeam == CS_TEAM_CT && _attackerTeam == CS_TEAM_CT) == false ||
				(_victimTeam == CS_TEAM_T && _attackerTeam == CS_TEAM_T) == false)
			{
				return Plugin_Handled;
			}
		}
		
		case TvTvCTvCT:
		{
			return Plugin_Continue;
		}
	}
	
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int SetDamageMode(Handle plugin, int argc)
{
	DamageMode _damageMode = GetNativeCell(1);
	damageMode = _damageMode;
}