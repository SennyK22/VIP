public void OnClientPostAdminCheck(int client)
{
	CreateTimer(10.0, Timer_Welcome, client);
}

public Action Timer_Welcome(Handle timer, any client)
{
	if (!IsClientConnected(client))
		return Plugin_Continue;

	int flags = GetUserFlagBits(client);

	char s_name[64];
	GetClientName(client, s_name, sizeof(s_name));

	if (flags & ADMFLAG_RESERVATION)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i)) continue;

			if (g_cvShowVipJoinInfo)
				C_PrintToChatAll("{gold}✯VIP✯ %s {default}wbił na serwer!", s_name);
			// SetHudTextParams(0.1, 0.4, 4.0, 204, 204, 0, 200, 1);    // red
			// ShowHudText(i, -1, "✯VIP✯ %s wbił na serwer!", s_name);
		}
	}

	return Plugin_Handled;
}