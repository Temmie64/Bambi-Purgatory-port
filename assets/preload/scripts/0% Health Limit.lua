function onUpdatePost()
	health = getProperty('health')
	if health < 0.0 then
		health = 0.0
	end
end