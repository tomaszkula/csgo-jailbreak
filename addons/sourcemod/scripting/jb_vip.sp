#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Vip"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

#define VIP_FLAG ADMFLAG_CUSTOM1
#define VIP_HEALTH 110
#define VIP_SMOKE_CHANCE 0.5
#define VIP_FLASH_CHANCE 0.1
#define VIP_JUMPS_COUNT 2

#define SUPER_VIP_FLAG ADMFLAG_CUSTOM2
#define SUPER_VIP_HEALTH 125
#define SUPER_VIP_SMOKE_CHANCE 1
#define SUPER_VIP_FLASH_CHANCE 0.5
#define SUPER_VIP_HE_CHANCE 0.1
#define SUPER_VIP_JUMPS_COUNT 3

int jumpsCount[MAXPLAYERS];
int lastFlags[MAXPLAYERS];
int lastButtons[MAXPLAYERS];

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
	CreateNative("JB_IsVip", IsVip);
	CreateNative("JB_IsSuperVip", IsSuperVip);
}

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn_Post);
	
	UserMsg _sayText2 = GetUserMessageId("SayText2");
	HookUserMessage(_sayText2, UserMessage_SayText2, true);
}

public Action OnPlayerRunCmd(int _client, int& _buttons1, int& impulse, float _vel[3], float _angles[3], int& _weapon, int& _subtype, int& _cmdnum, int& _tickcount, int& _seed, int _mouse[2])
{
	int _maxJumpsCount = 0;
	if(JB_IsSuperVip(_client))
	{
		_maxJumpsCount = SUPER_VIP_JUMPS_COUNT;
	}
	else if(JB_IsVip(_client))
	{
		_maxJumpsCount = VIP_JUMPS_COUNT;
	}
	else
	{
		return;
	}
	
	int _flags = GetEntityFlags(_client);
	int _buttons = GetClientButtons(_client);
	
	if (lastFlags[_client] & FL_ONGROUND)
	{
		if (!(_flags & FL_ONGROUND) && !(lastButtons[_client] & IN_JUMP) && (_buttons & IN_JUMP))
		{
			jumpsCount[_client]++;
		}
	}
	else if(_flags & FL_ONGROUND)
	{
		jumpsCount[_client] = 0;
	}
	else if (!(lastButtons[_client] & IN_JUMP) && (_buttons & IN_JUMP))
	{
		if(0 < jumpsCount[_client] < _maxJumpsCount)
		{
			jumpsCount[_client]++;
			
			float _velocity[3];
			GetEntPropVector(_client, Prop_Data, "m_vecVelocity", _velocity);
			_velocity[2] = 250.0;
			TeleportEntity(_client, NULL_VECTOR, NULL_VECTOR, _velocity);
		}
	}
	
	lastFlags[_client] = _flags;
	lastButtons[_client] = _buttons;
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	if(JB_IsSuperVip(_client))
	{
		SetEntityHealth(_client, SUPER_VIP_HEALTH);
		
		float _chance = GetRandomFloat();
		if(_chance <= SUPER_VIP_SMOKE_CHANCE)
		{
			GivePlayerItem(_client, "weapon_smokegrenade");
		}
		if(_chance <= SUPER_VIP_FLASH_CHANCE)
		{
			GivePlayerItem(_client, "weapon_flashbang");
		}
		if(_chance <= SUPER_VIP_HE_CHANCE)
		{
			GivePlayerItem(_client, "weapon_hegrenade");
		}
		
		SetEntProp(_client, Prop_Send, "m_bHasHelmet", true);
		SetEntProp(_client, Prop_Send, "m_ArmorValue", 200);
		
		CS_SetClientClanTag(_client, "[SuperVIP]");
	}
	else if(JB_IsVip(_client))
	{
		SetEntityHealth(_client, VIP_HEALTH);
		
		float _chance = GetRandomFloat();
		if(_chance <= VIP_SMOKE_CHANCE)
		{
			GivePlayerItem(_client, "weapon_smokegrenade");
		}
		if(_chance <= VIP_FLASH_CHANCE)
		{
			GivePlayerItem(_client, "weapon_flashbang");
		}
		
		SetEntProp(_client, Prop_Send, "m_ArmorValue", 100);
		
		
		CS_SetClientClanTag(_client, "[VIP]");
	}
	
	return Plugin_Continue;
}

public Action UserMessage_SayText2(UserMsg _msg_id, Protobuf _msg, const int[] _players, int _playersNum, bool _reliable, bool _init)
{
	int _client = _msg.ReadInt("ent_idx");
	
	char _buffer[LENGTH_256];
	_msg.ReadString("params", _buffer, sizeof(_buffer), 0);
	if(JB_IsVip(_client))
	{
		Format(_buffer, sizeof(_buffer), "\x07[SuperVIP] %s", _buffer);
	}
	else if(JB_IsVip(_client))
	{
		Format(_buffer, sizeof(_buffer), "\x07[VIP] %s", _buffer);
	}
	_msg.SetString("params", _buffer, 0);
	
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int IsVip(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return (GetUserFlagBits(_client) & (VIP_FLAG | ADMFLAG_ROOT));
}

public int IsSuperVip(Handle plugin, int argc)
{
	int _client = GetNativeCell(1);
	return (GetUserFlagBits(_client) & (SUPER_VIP_FLAG | ADMFLAG_ROOT));
}