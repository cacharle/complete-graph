local SDL = require "SDL"

local width  = 500
local height = width

function unwrap(ret_err)
    ret, err = ret_err
    if not ret then
        error(err)
    end
    return ret
end

unwrap(SDL.init { SDL.flags.Video })

local window = unwrap(SDL.createWindow {
    title  = "TSP",
    width  = width,
    height = height,
})

local renderer = unwrap(SDL.createRenderer(window, 0, {}))

local node_num = 10
local radian = (2 * math.pi) / node_num

local running = true
while running do
    for e in SDL.pollEvent() do
        if e.type == SDL.event.Quit then
            running = false
        elseif e.type == SDL.event.KeyDown then
            local code = e.keysym.scancode
            if code == SDL.scancode.Escape or code == SDL.scancode.Q then
                running = false
            end
        end
    end
    renderer:setDrawColor(0xff222222)
    renderer:clear()

    renderer:setDrawColor(0xffeeeeee)
    local start = 0
    for i = 1,node_num do
        point = {
            y = math.asin(start) * (width / 2 - 10),
            x = math.acos(start) * (width / 2 - 10),
        }
        print(point.y, point.x)
        renderer:drawPoint(point)

        start = start + radian
    end

    renderer:present()
    SDL.delay(1000)
end

SDL.quit()
