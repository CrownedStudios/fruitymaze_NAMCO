local FileLogger = {}

function FileLogger:LogToFile(fileName, message)
    love.filesystem.append(fileName .. ".txt", os.date("[%H:%M:%S] ") .. message .. "\n")
end

return FileLogger
