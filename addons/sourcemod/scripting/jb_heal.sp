#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Heal"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
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

public APLRes AskPluginLoad2(Handle myself, bool late, char [] error, int err_max)
{
	CreateNative("JB_CanHeal", CanHeal);
	CreateNative("JB_Heal", Heal);
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int CanHeal(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	int _health = GetNativeCell(2);
	
	int _clientHealth = GetClientHealth(_client);
	return _clientHealth < _health;
}

public int Heal(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	int _health = GetNativeCell(2);
	if(JB_CanHeal(_client, _health) == false)
	{
		return false;
	}
	
	SetEntityHealth(_client, _health);
	return true;
}