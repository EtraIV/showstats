#include <sourcemod>
#include <convars>
#include <clients>
#include <tf2>
#include <tf2_stocks>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION		"2.1.8"
#define PLUGIN_VERSION_CVAR	"sm_showstats_version"

public Plugin myinfo = {
	name = "[TF2] Show Player Stats",
	author = "Etra",
	description = "Super simple plugin to print player stats to console in CSV.",
	version = PLUGIN_VERSION,
	url = "https://github.com/EtraIV/showstats"
};

ConVar g_cvVersion = null;
ConVar g_cvRandomCrits = null;
ConVar g_cvAlltalk = null;

public void OnPluginStart()
{
	g_cvVersion = CreateConVar(PLUGIN_VERSION_CVAR, PLUGIN_VERSION, "Plugin version.", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_PRINTABLEONLY);
	RegAdminCmd("sm_showstats", ShowPlayerStats, ADMFLAG_GENERIC, "Print all player stats");
	g_cvRandomCrits = FindConVar("tf_weapon_criticals");
	g_cvAlltalk = FindConVar("sv_alltalk");
}

public Action ShowPlayerStats(int client, int args)
{
	char szCurrentMap[PLATFORM_MAX_PATH], szNextMap[PLATFORM_MAX_PATH];
	int iTimeLeft, iPlayers = GetClientCount(false), iMaxPlayers = GetMaxHumanPlayers();
	ConVar cvAnon = FindConVar("sm_anonymize");

	GetMapTimeLeft(iTimeLeft);
	GetCurrentMap(szCurrentMap, sizeof(szCurrentMap));
	GetNextMap(szNextMap, sizeof(szNextMap));

	ReplyToCommand(client, "Players,Max Players,Time Left,Random Crits,Alltalk,Anon Mode,Current Map,Next Map\n\
		%i,%i,%i,%i,%i,%i,\"%s\",\"%s\"\n\
		Name,Steam ID,Team,Class,Score,Kills,Deaths,Assists,Dominations,Captures,Defenses,Damage,Healing,Time",
		iPlayers,
		iMaxPlayers,
		iTimeLeft,
		GetConVarInt(g_cvRandomCrits),
		GetConVarInt(g_cvAlltalk),
		cvAnon ? GetConVarInt(cvAnon) : 0,
		szCurrentMap,
		szNextMap);

	for (int i = 1; i <= 33; i++) { // Hardcoded in limit of 33 for the maximum player count of TF2, used on a server with plugins to increase max playercount.
		if (IsClientInGame(i)) {
			char szName[MAX_NAME_LENGTH], szUserId[MAX_AUTHID_LENGTH];
			GetClientName(i, szName, sizeof(szName));
			GetClientAuthId(i, AuthId_Steam2, szUserId, sizeof(szUserId));
			ReplaceString(szName, sizeof(szName), "\"", NULL_STRING);

			ReplyToCommand(client, "\"%s\",\"%s\",%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%.0f",
				szName,
				szUserId,
				GetClientTeam(i),
				GetEntProp(i, Prop_Send, "m_iClass"),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iTotalScore", _, i),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iScore", _, i),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iDeaths", _, i),
				GetEntProp(i, Prop_Send, "m_iKillAssists"),
				GetEntProp(i, Prop_Send, "m_iDominations"),
				GetEntProp(i, Prop_Send, "m_iCaptures"),
				GetEntProp(i, Prop_Send, "m_iDefenses"),
				GetEntProp(i, Prop_Send, "m_iDamageDone"),
				GetEntProp(i, Prop_Send, "m_iHealPoints"),
				IsFakeClient(i) ? -1.0 : GetClientTime(i)	// Set to zero if the player is a bot to prevent error
			);
		}
	}

	delete cvAnon;
	return Plugin_Handled;
}
