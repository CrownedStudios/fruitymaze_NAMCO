function love.conf(t)
    t.window.title = "Fruity Maze: Arcade Edition"
    t.window.width = 512
    t.window.height = 480
    t.window.resizable = false
    t.modules.physics = false

    if arg[#arg] == "-debug" then
        t.console = true
    end
end
