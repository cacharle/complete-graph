local SDL = require "SDL"

local width  = 1000
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

renderer:setDrawBlendMode(SDL.blendMode.Add)

local node_num = 6
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
            elseif code == SDL.scancode.Up or code == SDL.scancode.K then
                node_num = node_num + 1
                radian = (2 * math.pi) / node_num
            elseif code == SDL.scancode.Down or code == SDL.scancode.J then
                if node_num > 2 then
                    node_num = node_num - 1
                    radian = (2 * math.pi) / node_num
                end
            end
        end
    end
    renderer:setDrawColor(0xff222222)
    renderer:clear()

    renderer:setDrawColor(0x22eeeeee)
    local rects = {}
    local start = 0
    local rect_size = 4
    for i = 1,node_num do
        local padding = 50
        local w = width - padding
        rect = {
            y = math.ceil(math.sin(start) * (w / 2.0)) + (w / 2) + (padding / 2),
            x = math.ceil(math.cos(start) * (w / 2.0)) + (w / 2) + (padding / 2),
            w = rect_size,
            h = rect_size,
        }
        table.insert(rects, rect)
        start = start + radian
    end
    renderer:fillRects(rects)

    renderer:setDrawColor(0x22eeeeee)
    for i = 1, #rects do
        for j = 1, (i - 1) do
            renderer:drawLine {
                x1 = rects[i].x + (rect_size / 2),
                x2 = rects[j].x + (rect_size / 2),
                y1 = rects[i].y + (rect_size / 2),
                y2 = rects[j].y + (rect_size / 2),
            }
        end
    end

    renderer:present()
    SDL.delay(10)
end

SDL.quit()
