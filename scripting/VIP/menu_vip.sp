public Action MenuVIP(int client, int args)
{
    Menu VIP = new Menu(VIP);

    VIP.SetTitle("VIP");
    VIP.AddItem("sm_buyvip", "Kup VIP");
    VIP.AddItem("sm_infovip", "Co daje VIP");
    VIP.AddItem("sm_testvip", "Wytestuj VIP");
    VIP.AddItem("sm_author", "Info o Autorze");

    VIP.Display(client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public int VIP(Menu VIP, MenuAction action, int client, int choice)
{
    switch(action)
    {
        case MenuAction
    }
}