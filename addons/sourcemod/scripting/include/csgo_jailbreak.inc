/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included



#define PLUGIN_AUTHOR "tomkul777"
#define FORUM_URL "forum.pl"




////////////////////////////////////////////////////////////
/////////////////////////// DATA ///////////////////////////
////////////////////////////////////////////////////////////

#define CS_TEAM_NONE        	0   	/**< No team yet. */
#define CS_TEAM_SPECTATOR   	1  		/**< Spectators. */
#define CS_TEAM_T       		2 		/**< Terrorists. */
#define CS_TEAM_CT      		3 		/**< Counter-Terrorists. */ 




////////////////////////////////////////////////////////////
//////////////////////// CUSTOM DATA ///////////////////////
////////////////////////////////////////////////////////////

#define LENGTH_1 1 << 0
#define LENGTH_2 1 << 1
#define LENGTH_4 1 << 2
#define LENGTH_8 1 << 3
#define LENGTH_16 1 << 4
#define LENGTH_32 1 << 5
#define LENGTH_64 1 << 6
#define LENGTH_128 1 << 7
#define LENGTH_256 1 << 8

enum DayMode
{
	None = 0,
	WarmUp = 1,
	Normal = 2,
	Game = 3
}




////////////////////////////////////////////////////////////
///////////////////////// FORWARDS /////////////////////////
////////////////////////////////////////////////////////////

// Called after day calculation
forward void OnDayChanged(int _day);

// Called after day mode calculation
forward void OnDayModeChanged(DayMode _dayMode);




////////////////////////////////////////////////////////////
///////////////////////// NATIVES //////////////////////////
////////////////////////////////////////////////////////////

// Returns day
native int JB_GetDay();

/*
 * Returns name of day of the week for a given day
 *
 * @param _dayNumber			 	  		day
 * @param _dayName							returned day name
 * @param _dayNameLength					_dayName array length
 */
native void JB_GetDayName(int _day, char[] _dayName, int _dayNameLength);

// Returns day mode
native DayMode JB_GetDayMode();

/*
 * Returns name of day mode for a given day mode
 *
 * @param _dayMode			 	  			day mode
 * @param _dayModeName						returned day mode name
 * @param _dayModeNameLength				_dayModeName array length
 */
native void JB_GetDayModeName(DayMode _dayMode, char[] _dayModeName, int _dayModeNameLength);

// Returns remaining god mode time for warm up
native int JB_GetWarmUpGodModeTime();




////////////////////////////////////////////////////////////
///////////////////////// STOCKS ///////////////////////////
////////////////////////////////////////////////////////////

/*
 * Returns number of prisoners
 *
 * @param _onlyAlive     					should count only alive prisoners
 * @return              					number of prisoners
 */
stock int JB_GetPrisonersCount(bool _onlyAlive = false)
{
	int _prisonersCount = 0;
	if(_onlyAlive) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_T)
			{
				continue;
			}
			
			_prisonersCount++;
		}
	}
	else
	{
		_prisonersCount = GetTeamClientCount(CS_TEAM_T);
	}
	
	return _prisonersCount;
}

/*
 * Returns number of wardens
 *
 * @param _onlyAlive     					should count only alive wardens
 * @return              					number of wardens
 */
stock int JB_GetWardensCount(bool _onlyAlive = false)
{
	int _wardensCount = 0;
	if(_onlyAlive) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
			{
				continue;
			}
			
			_wardensCount++;
		}
	}
	else
	{
		_wardensCount = GetTeamClientCount(CS_TEAM_CT);
	}
	
	return _wardensCount;
}