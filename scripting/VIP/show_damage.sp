public Action player_hurt(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	if (client > 0 && IsClientConnected(client) && IsClientInGame(client))
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (attacker > 0 && IsClientConnected(attacker) && IsClientInGame(attacker))
		{
			if (g_cvShowDmgOnlyVip)
			{
				if (!CheckCommandAccess(attacker, "", ADMFLAG_RESERVATION, true))
				{
					return Plugin_Handled;
				}
			}

			int i_dmg = GetEventInt(event, "dmg_health");

			float RandomX[] = { 0.25, 0.28, 0.31, 0.34, 0.37, 0.40, 0.43 };
			int   randX     = GetRandomInt(0, 6);
			float RandomY[] = { 0.31, 0.34, 0.37, 0.40, 0.43, 0.46, 0.49 };
			int   randY     = GetRandomInt(0, 6);

			SetHudTextParams(RandomX[randX], RandomY[randY], 1.3, 255, 0, 0, 200, 1);    // red
			ShowHudText(attacker, -1, "%d", i_dmg);
		}
	}
	return Plugin_Handled;
}