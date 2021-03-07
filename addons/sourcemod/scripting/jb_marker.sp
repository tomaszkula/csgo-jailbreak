#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Marker"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

bool isPainting[MAXPLAYERS];
float markerLastPosition[MAXPLAYERS][3];
int beamSprite = 0;

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
	RegConsoleCmd("+paint", PaintCmd);
	RegConsoleCmd("-paint", PaintCmd);
	RegConsoleCmd("+maluj", PaintCmd);
	RegConsoleCmd("-maluj", PaintCmd);
}

public void OnMapStart()
{
	beamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	HookEvent("round_prestart", Event_RoundPrestart_Post);
	HookEvent("player_death", Event_PlayerDeath_Post);
	
	CreateTimer(0.1, PaintTimer, _, TIMER_REPEAT);
}

public void OnClientDisconnect_Post(int _client)
{
	isPainting[_client] = false;
}

public Action Event_RoundPrestart_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		isPainting[i] = false;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath_Post(Event _event, const char[] _name, bool _dontBroadcast)
{
	int _victim = GetClientOfUserId(_event.GetInt("userid"));
	isPainting[_victim] = false;
		
	return Plugin_Continue;
}

public Action PaintCmd(int _client, int _args)
{
	if(JB_GetSimon() != _client)
	{
		return Plugin_Handled;
	}
	
	char _command[LENGTH_16];
	GetCmdArg(0, _command, sizeof(_command));

	if(_command[0] == '+')
	{
		JB_TraceClientViewPosition(_client, markerLastPosition[_client]);
		isPainting[_client] = true;
	}
	else
	{
		markerLastPosition[_client][0] = 0.0;
		markerLastPosition[_client][1] = 0.0;
		markerLastPosition[_client][2] = 0.0;
		isPainting[_client] = false;
	}
	
	return Plugin_Handled;
}

public Action PaintTimer(Handle _timer)
{
	float _markerPosition[3];
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(!isPainting[i])
		{
			continue;
		}
			
		JB_TraceClientViewPosition(i, _markerPosition);
		if(GetVectorDistance(_markerPosition, markerLastPosition[i]) > 3.0)
		{
			int _color[4];
			_color[0] = GetRandomInt(0, 255);
			_color[1] = GetRandomInt(0, 255);
			_color[2] = GetRandomInt(0, 255);
			_color[3] = 255;
			
			TE_SetupBeamPoints(markerLastPosition[i], _markerPosition, beamSprite, 0, 0, 0, 25.0, 2.0, 3.0, 10, 0.0, _color, 0);
			TE_SendToAll();
			
			markerLastPosition[i] = _markerPosition;
		}
	}
}