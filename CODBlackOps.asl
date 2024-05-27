state("BlackOps")
{
	string35 currentlevelName : 0x21033E8; // Doesn't work for langagues other than English (idk why)
	long Loader : 0x2AEA4B0;	// Changed based on timing method changes by community vote
	bool Loader2 : 0x3CE1594;	// aciidz: covers actual loads more accurately, doesn't cover cutscenes
}

startup 
{
	settings.Add("missions", true, "All Missions"); // Decided to add this just so it's like all the other ones

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

init
{
	vars.USDDtime = false;
}

update
{
	
}

start
{
	return ((current.currentlevelName == "cuba") && (current.Loader != 0 && !current.Loader2));
}

onStart
{
	vars.USDDtime = false;
}

isLoading
{
	// if loading, pause the timer. if on USDD (pentagon), pause the timer. if on main menu, pause the timer (for USDD skip).
	return (current.Loader == 0 || current.Loader2) || (current.currentlevelName == "pentagon") || (current.currentlevelName == "frontend");
}

reset
{
	// adding old.currentlevelName != frontend fixes timer resetting when doing USDD skip
	// only checking against pentagon would just delay the reset by 1 autosplitter refresh cycle
	return ((current.currentlevelName == "frontend") && (old.currentlevelName != "frontend") && (old.currentlevelName != "pentagon"));
}

split
{
	// If on a different map, the map exists in settings, and the setting is enabled
	if (current.currentlevelName != old.currentlevelName && settings.ContainsKey(current.currentlevelName) && settings[current.currentlevelName])
  	{
		// If we're on USDD, do USDD skip logic
		if (current.currentlevelName == "pentagon")
		{
			// Add game time of 4:55
			vars.USDDtime = true;
			return true;
		}
		// We're not on USDD, so just return true
		else
		{
			return true;
		}
	}
}

gameTime 
{
	if (vars.USDDtime == true) 
	{					
		vars.USDDtime = false;
		return timer.CurrentTime.GameTime.Value.Add(new TimeSpan (0, 4, 55)); // Time taken from the mean of most of the submitted any% runs
	}
}
