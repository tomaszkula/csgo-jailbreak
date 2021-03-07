#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Players"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

char modelsDownloadPath[] = "configs/tomkul777/jailbreak/files_to_download.txt";

char wardenModels[][][] =
{
	{"models/player/custom_player/kuristaja/jailbreak/guard1/guard1.mdl",				"models/player/custom_player/kuristaja/jailbreak/guard1/guard1_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/guard2/guard2.mdl",				"models/player/custom_player/kuristaja/jailbreak/guard2/guard2_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl",				"models/player/custom_player/kuristaja/jailbreak/guard3/guard3_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/guard4/guard4.mdl",				"models/player/custom_player/kuristaja/jailbreak/guard4/guard4_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/guard5/guard5.mdl",				"models/player/custom_player/kuristaja/jailbreak/guard5/guard5_arms.mdl"}
};

char prisonerModels[][][] =
{
	{"models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.mdl"},
	{"models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.mdl",			"models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.mdl"}
};

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
	HookEvent("player_spawn", Event_PlayerSpawn_Post);
}

public void OnMapStart()
{
	char _path[LENGTH_256];
	BuildPath(Path_SM, _path, sizeof(_path), modelsDownloadPath);
	DownloadFromFile(_path);
	
	for (int i = 0; i < sizeof(wardenModels); i++)
	{
		PrecacheModel(wardenModels[i][0], true);
		PrecacheModel(wardenModels[i][1], true);
	}
	
	for (int i = 0; i < sizeof(prisonerModels); i++)
	{
		PrecacheModel(prisonerModels[i][0], true);
		PrecacheModel(prisonerModels[i][1], true);
	}
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	
	int _weapon = -1;
	for(int i = 0; i < 5; i++)
    {
    	if(i == 2 || (_weapon = GetPlayerWeaponSlot(_client, i)) == -1)
    	{
    		continue;
    	}
    	
        RemovePlayerItem(_client, _weapon);
    }
    
	int _knife = GetPlayerWeaponSlot(_client, 2);
	SetEntPropEnt(_client, Prop_Send, "m_hActiveWeapon", _knife);
	
	if (GetClientTeam(_client) == CS_TEAM_CT)
	{
		int _wardenModelsCount = sizeof(wardenModels);
		if(_wardenModelsCount > 0)
		{
			int _modelID = GetRandomInt(0, _wardenModelsCount - 1);
			
			SetEntityModel(_client, wardenModels[_modelID][0]); // player model
			SetEntPropString(_client, Prop_Send, "m_szArmsModel", wardenModels[_modelID][1]); // arms model
		}
	}
	else if (GetClientTeam(_client) == CS_TEAM_T)
	{
		int _prisonerModelsCount = sizeof(prisonerModels);
		if(_prisonerModelsCount > 0)
		{
			int _modelID = GetRandomInt(0, _prisonerModelsCount - 1);
			
			SetEntityModel(_client, prisonerModels[_modelID][0]); // player model
			SetEntPropString(_client, Prop_Send, "m_szArmsModel", prisonerModels[_modelID][1]); // arms model
		}
	}
	
	return Plugin_Continue;
}