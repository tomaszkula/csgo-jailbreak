#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "[JB] Countdown"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <csgo_jailbreak>

#pragma newdecls required

char countdownSounds[][][] = 
{
	{"1",				"tomkul777/jailbreak/1.wav"},
	{"2",				"tomkul777/jailbreak/2.wav"},
	{"3",				"tomkul777/jailbreak/3.wav"},
	{"4",				"tomkul777/jailbreak/4.wav"},
	{"5",				"tomkul777/jailbreak/5.wav"},
	{"6",				"tomkul777/jailbreak/6.wav"},
	{"7",				"tomkul777/jailbreak/7.wav"},
	{"8",				"tomkul777/jailbreak/8.wav"},
	{"9",				"tomkul777/jailbreak/9.wav"},
	{"10",				"tomkul777/jailbreak/10.wav"}
};

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
	CreateNative("JB_PlayCountdownSound", PlayCountdownSound);
}

public void OnMapStart()
{
	char _downloadPath[LENGTH_256];
	for (int i = 0; i < sizeof(countdownSounds); i++)
	{
		Format(_downloadPath, sizeof(_downloadPath), "sound/%s", countdownSounds[i][1]);
		AddFileToDownloadsTable(_downloadPath);
		
		PrecacheSound(countdownSounds[i][1]);
	}
}

/////////////////////////////////////////////////////////////
////////////////////////// NATIVES //////////////////////////
/////////////////////////////////////////////////////////////

public int PlayCountdownSound(Handle plugin, int argc)
{
	int _number = GetNativeCell(1);
	for (int i = 0; i < sizeof(countdownSounds); i++)
	{
		if(StringToInt(countdownSounds[i][0]) == _number)
		{
			EmitSoundToAll(countdownSounds[i][1]);
			return;
		}
	}
}