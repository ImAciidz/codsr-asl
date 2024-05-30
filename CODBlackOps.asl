state("BlackOps")
{
	string35 levelName : 0x21033E8;
	long Loader : 0x2AEA4B0;	// covers loads ineffectively, handles cutscenes that are supposed to be removed from timing
	bool Loader2 : 0x3CE1594;	// covers actual loads more accurately, doesn't cover cutscenes
}

startup 
{
	settings.Add("missions", true, "All Missions");
	vars.missions = new Dictionary<string,string> 
	{ 
	  	{"vorkuta", "Vorkuta"},
		{"pentagon", "USDD"},
		{"flashpoint", "Executive Order"},
		{"khe_sanh", "SOG"},
		{"hue_city", "The Defector"},
		{"kowloon", "Numbers"},
		{"fullahead", "Project Nova"},
		{"creek_1", "Victor Charlie"},
		{"river", "Crash Site"},
		{"wmd_sr71", "WMD"},
		{"pow", "Payback"}, 
		{"rebirth", "Rebirth"},
		{"int_escape", "Revelations"},
		{"underwaterbase", "Redemption"},
		{"outro", "Menu Screen"},
	}; 
	foreach (var Tag in vars.missions)
	{
		settings.Add(Tag.Key, true, Tag.Value, "missions");
	};

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)  
	{        
		var timingMessage = MessageBox.Show 
		(
			"This game uses Time without Loads (Game Time) as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time? This will make verification easier",
			"LiveSplit | Call of Duty: Black Ops",
			MessageBoxButtons.YesNo,MessageBoxIcon.Question
		);
		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
}

update
{
	
}

start
{
	return ((current.levelName == "cuba") && (current.Loader != 0 && !current.Loader2));
}

onStart
{
	vars.USDDtime = false;
}

isLoading
{
	// if loading, pause the timer. if on USDD (pentagon), pause the timer. if on main menu, pause the timer (for USDD skip).
	return (current.Loader == 0 || current.Loader2) || (current.levelName == "pentagon") || (current.levelName == "frontend");
}

reset
{
	// reset if we just quit to the main menu, and the level we are quitting from is not USDD
	return ((current.levelName == "frontend") && (old.levelName != "frontend") && (old.levelName != "pentagon"));
}

split
{
	// If on a different map, the map exists in settings, and the setting is enabled
	if (current.levelName != old.levelName && settings.ContainsKey(current.levelName) && settings[current.levelName])
  	{
		// If we're on USDD...
		if (current.levelName == "pentagon")
		{
			// Add game time of 4:55
			vars.USDDtime = true;
		}
		return true;
	}
}

gameTime 
{
	if (vars.USDDtime == true) 
	{					
		vars.USDDtime = false;
		// 4:55 is the time taken from the mean of most of the submitted any% runs
		return timer.CurrentTime.GameTime.Value.Add(new TimeSpan (0, 4, 55));
	}
}
