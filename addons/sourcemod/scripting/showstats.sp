#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <json>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION		"2.0"
#define PLUGIN_VERSION_CVAR	"sm_showstats_version"

public Plugin myinfo = {
	name = "[TF2] Show Player Stats",
	author = "Etra",
	description = "Super simple plugin to print player stats to console in JSON.",
	version = PLUGIN_VERSION,
	url = "https://github.com/EtraIV/showstats"
};

methodmap PlayerStats < JSON_Object {
	public PlayerStats()
	{
		return view_as<PlayerStats>(new JSON_Object());
	}

	public void SetName(const char[] value)
	{
		this.SetString("name", value);
	}
	
	property TFTeam team {
		public set(TFTeam value)
		{
			this.SetInt("team", view_as<int>(value));
		}
	}

	property TFClassType class {
		public set(TFClassType value)
		{
			this.SetInt("class", view_as<int>(value));
		}
	}
	
	property int score {
		public set(int value)
		{
			this.SetInt("score", value);
		}
	}
	
	property int kills {
		public set(int value)
		{
			this.SetInt("kills", value);
		}
	}
	
	property int deaths {
		public set(int value)
		{
			this.SetInt("deaths", value);
		}
	
	}
	
	property int assists {
		public set(int value)
		{
			this.SetInt("assists", value);
		}
	}
	
	property int captures {
		public set(int value)
		{
			this.SetInt("captures", value);
		}
	}
	
	property int defenses {
		public set(int value)
		{
			this.SetInt("defenses", value);
		}
	}

	property int healing {
		public set(int value)
		{
			this.SetInt("healing", value);
		}
	}
}

ConVar g_cvVersion = null;

public void OnPluginStart()
{
	g_cvVersion = CreateConVar(PLUGIN_VERSION_CVAR, PLUGIN_VERSION, "Plugin version.", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_PRINTABLEONLY);
	RegAdminCmd("sm_showstats", ShowPlayerStats, ADMFLAG_GENERIC, "Print all player stats");
}

public Action ShowPlayerStats(int client, int args)
{
	char buffer[3072], nextmap[PLATFORM_MAX_PATH];
	int timeleft;
	JSON_Object stats = new JSON_Object();
	JSON_Array players = new JSON_Array();

	GetNextMap(nextmap, sizeof(nextmap));
	GetMapTimeLeft(timeleft);
	stats.SetString("nextmap", nextmap);
	stats.SetInt("timeleft", timeleft);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i)) {
			char name[32];
			PlayerStats player = new PlayerStats();
			GetClientName(i, name, sizeof(name));

			player.SetName(name);
			player.team = TF2_GetClientTeam(i);
			player.class = TF2_GetPlayerClass(i);
			player.score = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iTotalScore", _, i);
			player.kills = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iScore", _, i);
			player.deaths = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iDeaths", _, i);
			player.assists = GetEntProp(i, Prop_Send, "m_iKillAssists");
			player.captures = GetEntProp(i, Prop_Send, "m_iCaptures");
			player.defenses = GetEntProp(i, Prop_Send, "m_iDefenses");
			player.healing = GetEntProp(i, Prop_Send, "m_iHealPoints");

			players.PushObject(player);
		}
	}

	stats.SetObject("players", players);
	stats.Encode(buffer, sizeof(buffer));
	ReplyToCommand(client, buffer);

	json_cleanup_and_delete(stats);
	return Plugin_Handled;
}