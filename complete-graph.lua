local SDL = require 'SDL'
local argparse = require "argparse"

local parser = argparse("complete-graph", "Complete graph visualization")

parser:option("-m --mode", 'node increment mode')
    :choices { 'normal', 'even', 'odd' }
    :default('normal')
    :args(1)
local args = parser:parse()

local mode = args.mode

function unwrap(ret_err)
    ret, err = ret_err
    if not ret then
        error(err)
    end
    return ret
end

unwrap(SDL.init { SDL.flags.Video })

local init_window_size  = 600

local window = unwrap(SDL.createWindow {
    title  = "Complete Graph",
    width  = init_window_size,
    height = init_window_size,
    flags = SDL.window.Resizable,
})

local renderer = unwrap(SDL.createRenderer(window, 0, {}))

renderer:setDrawBlendMode(SDL.blendMode.Add)

local node_num = nil
if mode == 'normal' or mode == 'even' then
    node_num = 2
elseif mode == 'odd' then
    node_num = 3
end

local alpha = 0x22

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
                if mode == 'normal' then
                    node_num = node_num + 1
                elseif mode == 'odd' or mode == 'even' then
                    node_num = node_num + 2
                end
            elseif code == SDL.scancode.Down or code == SDL.scancode.J then
                if node_num > 2 then
                    if mode == 'normal' then
                        node_num = node_num - 1
                    elseif mode == 'odd' or mode == 'even' then
                        node_num = node_num - 2
                    end
                end
            elseif code == SDL.scancode.Left or code == SDL.scancode.H then
                alpha = alpha - 0x02
                if alpha < 0x0 then
                    alpha = 0x0
                end
            elseif code == SDL.scancode.Right or code == SDL.scancode.L then
                alpha = alpha + 0x02
                if alpha > 0xff then
                    alpha = 0xff
                end
            end
        elseif e.type == SDL.event.WindowEvent then
            if e.event == SDL.eventWindow.Resized then
                w, h = window:getSize()
                width = math.min(w, h)
            end
        end

    end
    renderer:setDrawColor(0xff222222)
    renderer:clear()

    renderer:setDrawColor(0x22eeeeee)
    local rects = {}
    local start = 0
    local rect_size = 4
    local radian = (2 * math.pi) / node_num
    local width, height = window:getSize()
    local window_min_size = math.min(width, height)
    local window_max_size = math.max(width, height)
    for i = 1,node_num do
        local padding = 50
        local w = window_min_size - padding
        rect = {
            y = math.ceil(math.sin(start) * (w / 2.0)) + (w / 2) + (padding / 2),
            x = math.ceil(math.cos(start) * (w / 2.0)) + (w / 2) + (padding / 2),
            w = rect_size,
            h = rect_size,
        }
        if window_max_size == height then
            rect.y = rect.y + (window_max_size - window_min_size) / 2
        elseif window_max_size == width then
            rect.x = rect.x + (window_max_size - window_min_size) / 2
        end
        table.insert(rects, rect)
        start = start + radian
    end
    renderer:fillRects(rects)

    local draw_color = 0x00eeeeee
    draw_color = (alpha << 24) | draw_color
    renderer:setDrawColor(draw_color)
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
