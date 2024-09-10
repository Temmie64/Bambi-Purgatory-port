--[[ made by Laztrix#5670 

please credit if you gonna use this as a mod that will be public

]]

local timeEffect = 0.75
local zoomMulti = {0.015,0.015}
local alphaTrail = 0.8

local passDirectionBF = null
local passDirectionDad = null
local passDirectionGF = null
local passDirectionMom = null

function onSongStart()
	luaDebugMode = true
	if songName == 'Who' or songName == 'Voting-Time' or songName == 'Sussus Nuzzus' or songName == 'Idk' then
		noGhost = true
	end
	if songPath == 'double-kill' or songPath == 'reinforcements' or songPath == 'armed' then
		isMom = false
		runHaxeCode([[
			setVar('mommy',true);
		]])
	end
	makeTrailEffect()
end
function onEvent(n,v1,v2)
	if n == 'Change Character' then
		isTrail = false
		runHaxeCode([[
			game.remove(trailBF);
			game.remove(trailDad);
			game.remove(trailGF);
			if (trailMom != null)
				game.remove(trailMom);

		]])
		runTimer('characterChanged',0.2)
	end
end
function goodNoteHit(id, direction, noteType, isSustainNote)
	if not isSustainNote and not gfSection and noteType == '' then
		if passDirectionBF ~= nil and not noGhost then
			runHaxeCode([[
				trailBF.playAnim(game.singAnimations[]]..passDirectionBF..[[], true);
				trailBF.alpha = ]]..alphaTrail..[[;
			]])
			cancelTimer('bfframed')
			triggerEvent("Add Camera Zoom",zoomMulti[0],zoomMulti[1])
			doTweenAlpha('betrailbf','trailBF',0,timeEffect,'linear')
		end
		passDirectionBF = direction
		runTimer('bfframed', 0.01)
	end
	if not isSustainNote and noteType == 'Opponent 2 Sing' or not isSustainNote and noteType == 'Both Opponent Sing' then
		if passDirectionMom ~= nil and not noGhost and isMom then
			runHaxeCode([[
				trailMom.playAnim(game.singAnimations[]]..passDirectionMom..[[], true);
				trailMom.alpha = ]]..alphaTrail..[[;
			]])
			cancelTimer('momframed')
			triggerEvent("Add Camera Zoom",zoomMulti[0],zoomMulti[1])
			doTweenAlpha('betrailmom','trailMom',0,timeEffect,'linear')
		end
		passDirectionMom = direction
		runTimer('momframed', 0.01)
	end
end
function opponentNoteHit(id, direction ,noteType, isSustainNote)
	if not isSustainNote and not gfSection and noteType == '' or not isSustainNote and noteType == 'Both Opponent Sing' then
		if passDirectionDad ~= nil and not noGhost then
			runHaxeCode([[
				trailDad.playAnim(game.singAnimations[]]..passDirectionDad..[[], true);
				trailDad.alpha = ]]..alphaTrail..[[;
			]])
			cancelTimer('dadframed')
			triggerEvent("Add Camera Zoom",zoomMulti[0],zoomMulti[1])
			doTweenAlpha('betraildad','trailDad',0,timeEffect,'linear')
		end
		passDirectionDad = direction
		runTimer('dadframed', 0.01)
	end
	if not isSustainNote and noteType == 'Opponent 2 Sing' or not isSustainNote and noteType == 'Both Opponent Sing' then
		if passDirectionMom ~= nil and not noGhost and isMom then
			runHaxeCode([[
				trailMom.playAnim(game.singAnimations[]]..passDirectionMom..[[], true);
				trailMom.alpha = ]]..alphaTrail..[[;
			]])
			cancelTimer('momframed')
			triggerEvent("Add Camera Zoom",zoomMulti[0],zoomMulti[1])
			doTweenAlpha('betrailmom','trailMom',0,timeEffect,'linear')
		end
		passDirectionMom = direction
		runTimer('momframed', 0.01)
	end
	if not isSustainNote and gfSection and noteType == 'GF Sing' then
		if passDirectionGF ~= nil and not noGhost then
			runHaxeCode([[
				trailGF.playAnim(game.singAnimations[]]..passDirectionGF..[[], true);
				trailGF.alpha = ]]..alphaTrail..[[;
			]])
			cancelTimer('gfframed')
			triggerEvent("Add Camera Zoom",zoomMulti[0],zoomMulti[1])
			doTweenAlpha('betrailgf','trailGF',0,timeEffect,'linear')
		end
		passDirectionGF = direction
		runTimer('gfframed', 0.01)
	end
end
function onTimerCompleted(t)
    if t == 'bfframed' then
        passDirectionBF = nil
    end

    if t == 'dadframed' then
        passDirectionDad = nil
    end

	if t == 'gfframed' then
        passDirectionGF = nil
    end

	if t == 'momframed' then
        passDirectionMom = nil
    end

	if t == 'characterChanged' then
		makeTrailEffect()
	end
end

function makeTrailEffect()
	isTrail = true
	runHaxeCode([[
	// getting character original position
		BFPos = [game.boyfriend.x,game.boyfriend.y];
      	DadPos = [game.dad.x,game.dad.y];
		GFPos = [game.gf.x,game.gf.y];

	// new characters for the trails
		trailBF = new Boyfriend(BFPos[0], BFPos[1], ']]..boyfriendName..[[');
		game.addBehindBF(trailBF);

		trailGF = new Character(GFPos[0], GFPos[1], ']]..gfName..[[');
		game.addBehindGF(trailGF);
		
		trailDad = new Character(DadPos[0], DadPos[1], ']]..dadName..[[');
		game.addBehindDad(trailDad);

	if (getVar('mommy')){
		MomPos = [mom.x,mom.y];
		trailMom = new Character(MomPos[0], MomPos[1], mom.curCharacter);
		game.addBehindGF(trailMom);
		game.variables.set('trailMom', trailMom);
		trailMom.alpha = 0;
	}
		

	// set the variable so you can mess it with setProperty stuff
		game.variables.set('trailDad', trailDad);
        game.variables.set('trailBF', trailBF);
		game.variables.set('trailGF', trailGF);

	// grrr
		trailDad.alpha = 0;
		trailBF.alpha = 0;
		trailGF.alpha = 0;
	]])
	setProperty('trailDad.color',getIconColor('dad'))
	setProperty('trailGF.color',getIconColor('gf'))
	setProperty('trailBF.color',getIconColor('boyfriend'))
	if isMom then
		setProperty('trailMom.color',getColorFromHex(rgbToHex(runHaxeCode(" return mom.healthColorArray; "))))
	end
end
function onUpdatePost()
	if isTrail then
		runHaxeCode([[
		// preventing the characters to go back playing idle animation
			trailGF.holdTimer = 0;
			trailDad.holdTimer = 0;
			trailBF.holdTimer = 0;
			if (getVar('mommy'))
			trailMom.holdTimer = 0;
		]])
	end
end

function getIconColor(chr)
	return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end

--[[ made by Laztrix#5670 

please credit if you gonna use this as a mod that will be public

]]