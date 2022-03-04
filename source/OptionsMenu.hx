package;

class OptionsMenu extends MusicBeatState
{
	override function create()
	{
		var bg = new MenuBG(OPTIONS);
		bg.active = false;
		add(bg);
		openSubState(new PreferencesMenu(false));
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState == null)
			openSubState(new PreferencesMenu(false));
	}
}
