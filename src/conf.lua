function love.conf(t)
    t.window.title = "Fruity Maze: Arcade Edition"
    t.window.width = 1024
    t.window.height = 768
    t.window.resizable = true
    t.modules.physics = false

    if arg[#arg] == "-debug" then
        t.console = true
    end
end
