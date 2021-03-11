#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Kill Day"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <csgo_jailbreak>

#pragma newdecls required

char weapons[][] =
{
	"weapon_ak47",
	"weapon_m4a1_silencer"
};

const int WEAPON_TIME = 6;
const int FIGHT_TIME = 6;
int weaponTime = 0;
int fightTime = 0;
int gameID = 0;
Handle giveWeaponTimer = null;
Handle fightTimer = null;

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
	gameID = JB_RegisterGame("Kill Day", 30);
}

public void OnGameStart(int _gameID)
{
	if(_gameID != gameID)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
		{
			continue;
		}
		
		switch(GetClientTeam(i))
		{
			case CS_TEAM_CT:
			{
				//SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			}
		}
	}
	
	weaponTime = WEAPON_TIME;
	giveWeaponTimer = CreateTimer(1.0, GiveWeaponTimer, _, TIMER_REPEAT);
	
	JB_SetDamageMode(v);
	
	HookEvent("player_spawn", Event_PlayerSpawn_Post);
}

public void OnGameEnd(int _gameID)
{
	if(_gameID != gameID)
	{
		return;
	}
	
	breakGiveWeaponTimer();
	breakFightTimer();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
		{
			continue;
		}
		
		switch(GetClientTeam(i))
		{
			case CS_TEAM_CT:
			{
				//SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	
	//JB_SetFriendlyFire(false);
	
	UnhookEvent("player_spawn", Event_PlayerSpawn_Post);
}

public Action Event_PlayerSpawn_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _client = GetClientOfUserId(_event.GetInt("userid"));
	switch(GetClientTeam(_client))
	{
		case CS_TEAM_CT:
		{
			//SetEntProp(_client, Prop_Data, "m_takedamage", 0, 1);
		}
		
		case CS_TEAM_T:
		{
			if(weaponTime <= 0)
			{
				int _weaponID = GetRandomInt(0, sizeof(weapons) - 1);
				GivePlayerItem(_client, weapons[_weaponID]);
			}
		}
	}
	
	return Plugin_Continue;
}

public Action GiveWeaponTimer(Handle _timer)
{
	if(--weaponTime > 0)
	{
		PrintHintTextToAll("<font color='#FFF'>Więźniowie otrzymają broń za:</font><br><font color='#0F0'>%is</font>", weaponTime);
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T)
			{
				continue;
			}
			
			int _weaponID = GetRandomInt(0, sizeof(weapons) - 1);
			GivePlayerItem(i, weapons[_weaponID]);
		}
		
		fightTime = FIGHT_TIME;
		fightTimer = CreateTimer(1.0, FightTimer, _, TIMER_REPEAT);
		
		breakGiveWeaponTimer();
	}
}


public Action FightTimer(Handle _timer)
{
	if(--fightTime > 0)
	{
		PrintHintTextToAll("<font color='#FFF'>Walka rozpocznie się za:</font><br><font color='#F00'><center>%is</center></font>", fightTime);
		JB_PlayCountdownSound(fightTime);
	}
	else
	{
		PrintHintTextToAll("<font color='#FFF'>WALKA ROZPOCZĘTA !!!</font>");
		JB_SetDamageMode(TvT);
		
		breakFightTimer();
	}
}

void breakGiveWeaponTimer()
{
	if(giveWeaponTimer != INVALID_HANDLE)
	{
		KillTimer(giveWeaponTimer);
		giveWeaponTimer = INVALID_HANDLE;
	}
}

void breakFightTimer()
{
	if(fightTimer != INVALID_HANDLE)
	{
		KillTimer(fightTimer);
		fightTimer = INVALID_HANDLE;
	}
}