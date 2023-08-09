#include <sourcemod>
#include <httpclient>

const char[] kGriefersListURL = "https://raw.githubusercontent.com/davemcdowell/L4D2-Griefers/main/ingest";
Array<const char[]> g_Griefers; // Dynamic array to store griefers' list

public void OnPluginStart()
{
    HttpGet(kGriefersListURL, OnGriefersListFetched);
}

public void OnGriefersListFetched(int httpStatus, const char[] data)
{
    if (httpStatus == 200)
    {
        g_Griefers.remove_all();

        int lines = ExplodeString("\n", data, true);
        for (int i = 0; i < lines; i++)
        {
            const char[] line = g_Griefers[i];
            if (line[0] != '#' && line[0] != '\0')
            {
                g_Griefers.insertLast(line);
            }
        }

        LogMessage("Griefers list fetched and updated.");
    }
    else
    {
        LogError("Failed to fetch griefers list. HTTP status: %d", httpStatus);
    }
}

public Action OnPlayerSpawn(int client)
{
    const char[] steamId = GetClientAuthString(client);

    if (IsSteamIdInGriefersList(steamId))
    {
        // Get the player's name
        const char[] playerName = GetClientName(client);

        // Display message for griefer player
        PrintToChat(client, "%s was found on the griefers list!", playerName);
    }

    return Plugin_Continue;
}

public bool IsSteamIdInGriefersList(const char[] steamId)
{
    for (int i = 0; i < g_Griefers.length; i++)
    {
        if (StrEqual(steamId, g_Griefers[i]))
        {
            return true;
        }
    }
    return false;
}
