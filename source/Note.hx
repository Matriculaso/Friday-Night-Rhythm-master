package;

using StringTools;

#if polymod
#end
class Note extends flixel.FlxSprite
{
	public static final swagWidth:Float = 160 * 0.7;

	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteJSONData:Int = 0;
	public var noteType:Int = 0;
	public var noteStyle:String = '';
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var singSuffix = '';

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public var isSpaceBarNote:Bool = false;

	var isChartingNote:Bool = false;

	public function new(_strumTime:Float, _noteData:Int, ?_prevNote:Note, ?_sustainNote:Bool = false, ?_isChartingNote:Bool = false, ?_isBar:Bool = false)
	{
		super();
		noteStyle = getNoteStyle();

		if (prevNote == null)
			prevNote = this;

		prevNote = _prevNote;
		isSustainNote = _sustainNote;

		x += 50;
		y -= 2000;

		strumTime = _strumTime;

		noteData = _noteData % 4;
		noteJSONData = _noteData;
		noteType = Std.int(noteJSONData / 8);

		isSpaceBarNote = _isBar && noteData == 0;

		isChartingNote = _isChartingNote;
		loadNote();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		var downscroll = getPref('downscroll') && !isChartingNote;
		if (animation.curAnim != null)
			if (animation.curAnim.name.endsWith('Scroll'))
				flipY = downscroll;
		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function loadNote()
	{
		@:privateAccess
		animation._animations = null;

		var downscroll = false;
		var note = PlayState.notesColor[noteData];

		if (isSpaceBarNote)
			note = 'orange';
		if (curSong == 'ratio' && strumTime >= 100342.105263158 && strumTime <= 141157.894736842)
			noteStyle = 'pixel-dizzle';
		switch (noteStyle)
		{
			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix('${note}Scroll', '${note}0', 24, false, false, downscroll);
				animation.addByPrefix('${note}holdend', '${note} hold end', 24, false);
				animation.addByPrefix('${note}hold', '${note} hold piece', 24, false);

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();

			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('${note}Scroll', [4 + noteData], 24, false, false, downscroll);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('${note}holdend', [4 + noteData]);
					animation.add('${note}hold', [noteData]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			case 'pixel-dizzle':
				loadGraphic(Paths.image('squizzle/arrows-pixels-squizzle', 'rhythm'), true, 17, 17);

				animation.add('${note}Scroll', [4 + noteData], 24, false, false, downscroll);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('squizzle/arrowEndsSquizzle', 'rhythm'), true, 7, 6);

					animation.add('${note}holdend', [4 + noteData]);
					animation.add('${note}hold', [noteData]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
		}

		antialiasing = getPref('antialiasing') && noteStyle != 'pixel' && noteStyle != 'pixel-dizzle';

		x += swagWidth * noteData;
		animation.play('${note}Scroll');

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			x += width / 2;

			animation.play('${note}holdend');
			updateHitbox();

			x -= width / 2;

			if (noteStyle == 'pixel' || noteStyle == 'pixel-dizzle')
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${note}hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	public static function getNoteStyle():String
	{
		var _noteStyle = '';
		if (PlayState.SONG != null)
			switch (curSong)
			{
				default:
					_noteStyle = 'normal';
			}
		switch (PlayState.curStage)
		{
			case 'school', 'schoolEvil':
				_noteStyle = 'pixel';
			default:
				_noteStyle = 'normal';
		}
		return _noteStyle;
	}
}
