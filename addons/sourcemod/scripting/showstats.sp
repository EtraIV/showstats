#include <sourcemod>
#include <convars>
#include <clients>
#include <tf2>
#include <tf2_stocks>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION		"2.1.3"
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
	int iTimeLeft, iPlayers = GetClientCount(), iMaxPlayers = GetMaxHumanPlayers();
	ConVar cvAnon = FindConVar("sm_anonymize");

	GetMapTimeLeft(iTimeLeft);
	GetCurrentMap(szCurrentMap, sizeof(szCurrentMap));
	GetNextMap(szNextMap, sizeof(szNextMap));

	ReplyToCommand(client, "Players,Max Players,Time Left,Random Crits,Alltalk,Anon Mode,Current Map,Next Map");
	ReplyToCommand(client, "%i,%i,%i,%i,%i,%i,\"%s\",\"%s\"",
		iPlayers,
		iMaxPlayers,
		iTimeLeft,
		GetConVarInt(g_cvRandomCrits),
		GetConVarInt(g_cvAlltalk),
		cvAnon ? GetConVarInt(cvAnon) : 0,
		szCurrentMap,
		szNextMap);
	ReplyToCommand(client, "Name,Team,Class,Score,Kills,Deaths,Assists,Dominations,Captures,Defenses,Healing,Time");

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i)) {
			char szName[32];
			GetClientName(i, szName, sizeof(szName));
			ReplaceString(szName, sizeof(szName), "\"", NULL_STRING);

			ReplyToCommand(client, "\"%s\",%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%.0f",
				szName,
				GetClientTeam(i),
				GetEntProp(i, Prop_Send, "m_iClass"),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iTotalScore", _, i),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iScore", _, i),
				GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iDeaths", _, i),
				GetEntProp(i, Prop_Send, "m_iKillAssists"),
				GetEntProp(i, Prop_Send, "m_iDominations"),
				GetEntProp(i, Prop_Send, "m_iCaptures"),
				GetEntProp(i, Prop_Send, "m_iDefenses"),
				GetEntProp(i, Prop_Send, "m_iHealPoints"),
				GetClientTime(i)
			);
		}
	}

	delete cvAnon;
	return Plugin_Handled;
}
