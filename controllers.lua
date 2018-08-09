controllers = {}

controls = {} --The results are stored here, by key

BUFFERTIME = .25

function controllers.setupControls()
    --camera controls
    controllers.addKeyControl("panUp", {"i"}, false, true)
    controllers.addKeyControl("panLeft", {"j"}, false, true)
    controllers.addKeyControl("panDown", {"k"}, false, true)
    controllers.addKeyControl("panRight", {"l"}, false, true)

    controllers.addKeyControl("zoomIn", {"."}, false, true)
    controllers.addKeyControl("zoomOut", {"/"}, false, true)

    controllers.addKeyControl("nextFocusedObject", {"]"}, false, false)
    controllers.addKeyControl("prevFocusedObject", {"["}, false, false)
    controllers.addKeyControl("freeCamera", {"\\"}, false, false)
    controllers.addKeyControl("resetCamera", {"\'"}, false, false)

    --player controls
    controllers.addKeyControl("playerUp", {"up","w"}, false, true)
    controllers.addKeyControl("playerLeft", {"left","a"}, false, true)
    controllers.addKeyControl("playerDown", {"down","s"}, false, true)
    controllers.addKeyControl("playerRight", {"right","d"}, false, true)

    --Debug controls
    controllers.addKeyControl("resetGame", {"r"}, true, true)
    controllers.addKeyControl("removeWallCollision", {"v"}, false, false)
end

function controllers.addKeyControl(key, letters, buffered, holdable)
    control = {}
    control.letters = letters
    control.buffered = buffered
    control.holdable = holdable
    control.active = false
    if buffered then
        control.timeElapsed = BUFFERTIME
    end
    if not holdable then
        control.released = true
    end
    controls[key] = control
end

function controllers.checkControl(key)
    return controls[key].active
end

function controllers.updateControls(dt)
    for k,control in pairs(controls) do

        pressed = false
        for i,l in ipairs(control.letters) do
            if love.keyboard.isDown(l) then
                pressed = true
            elseif not control.holdable then
                control.released = true
            end
        end

        if control.buffered then -- check if buffer time has elapsed
            control.timeElapsed = control.timeElapsed + dt
            if control.timeElapsed < BUFFERTIME then
                pressed = false
            else
                control.timeElapsed = 0
            end
        end


        if not control.holdable then -- check if key has been released
            if not control.released then
                pressed = false
            end
            if pressed then
                control.released = false
            end
        end

        if pressed then
            control.active = true
        else
            control.active = false
        end
    end
end

return controllers

--[[
A "control" is a table with:
 "letters" - an array of keyboard characters that can be used as input
 "buffered" - a boolean, to see if the key should wait between checking input
 "holdable" - a boolean, to see if the key should wait to be released to be pressed again
 "active" - whether or not the control was active on the last program update
 the key should be veguely descriptive
]]
