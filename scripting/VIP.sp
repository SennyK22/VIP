#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

ConVar g_cvVipJoinMessage;
ConVar g_cvVipLeftMessage;
ConVar g_cvPrefix;


public Plugin myinfo =
{
	name = "VIP",
	author = "SennyK",
	description = "VIP CSGO",
	version = "1.0.0",
	url = "https://github.com/SennyK22/VIP"
};


public void OnPluginStart()
{
	HookEvent("player_connect", vip_join_server, EventHookMode_Post);
	HookEvent("player_disconnect", vip_left_server, EventHookMode_Post);
	HookEvent("player_hurt", player_hurt, EventHookMode_Post);

	g_cvVipJoinMessage = CreateConVar("sm_prefix", "KURDE!", "Prefix przed wiadomościami");
	g_cvVipJoinMessage = CreateConVar("sm_vipjoinserver", "wszedł na serwer!", "Postać wiadomości: GRACZ wszedł na serwer!");
	g_cvVipLeftMessage = CreateConVar("sm_vipleftserver", "wyszedł z serwera!", "Postać wiadomości: GRACZ wyszedł z serwera!");

}

public Action vip_join_server(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	char s_name[64];

	if ((GetUserFlagBits(client) & ADMFLAG_RESERVATION)){
		CPrintToChatAll("%s %s", s_name, g_cvVipJoinMessage);
	}

}

public Action vip_left_server(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	char s_name[64];

	if ((GetUserFlagBits(client) & ADMFLAG_RESERVATION)){
		CPrintToChatAll("%s %s", s_name, g_cvVipLeftMessage);
	}
}

public Action player_hurt(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	if(client > 0 && IsClientConnected(client) && IsClientInGame(client)){
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if(attacker > 0 && IsClientConnected(attacker) && IsClientInGame(attacker)){
			int i_dmg = GetEventInt(event, "dmg_health");

			PrintHintText(attacker, "Zadałeś %s obrażeń!", i_dmg);
		}
	}
}