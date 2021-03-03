#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Revive"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
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
	CreateNative("JB_CanBeRevived", CanBeRevived);
	CreateNative("JB_Revive", Revive);
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int CanBeRevived(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(!IsClientInGame(_client) || IsPlayerAlive(_client))
	{
		return false;
	}
	
	return true;
}

public int Revive(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	if(JB_CanBeRevived(_client) == false)
	{
		return false;
	}
	
	CS_RespawnPlayer(_client);
	return true;
}