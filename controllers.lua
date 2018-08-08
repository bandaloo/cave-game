controllers = {}

controls = {} --The results are stored here, by key

BUFFERTIME = .25
function controllers.addControl(key, letters, buffered, holdable)
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
        print("key: ", k)

        pressed = false
        for i,l in ipairs(control.letters) do
            print(l)
            if love.keyboard.isDown(l) then
                print("down")
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
            print("true!")
            control.active = true
        else
            print("false")
            control.active = false
        end
    end
end

return controllers

--[[
A "control" is a table with:
 "letters" - an array of keyboard characters that can be used as input
 "buffered" - a boolean, to see if the key should wait between checking input
 "holdable" - a boolaen, to see if the key should wait to be released to be pressed again
 "active" - whether or not the control was active on the last program update
 the key should be veguely descriptive
]]
