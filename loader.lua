-- Kawnew Premium Script Loader (Based on Night)

if getgenv().Night then
    return error("kawnew is already loaded")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local plrs = game:GetService("Players")
local localPlayer = plrs.LocalPlayer
local localPlayerName = localPlayer.Name

local baseFolder = "Kawnew Premium Script"
local configFolder = "Kawnew Config [" .. localPlayerName .. "]"

-- Create folders
if not isfolder(baseFolder) then makefolder(baseFolder) end
if not isfolder(configFolder) then makefolder(configFolder) end
if not isfolder(baseFolder .. "/Assets") then makefolder(baseFolder .. "/Assets") end
if not isfolder(baseFolder .. "/Assets/Fonts") then makefolder(baseFolder .. "/Assets/Fonts") end

getgenv().Night = {
    Dev = false,
    Connections = {},
    Pages = {},
    Tabs = {Tabs = {}},
    Corners = {},
    Load = os.clock(),
    Notifications = {Objects = {}, Active = {}},
    ArrayList = {Objects = {}, Loaded = false},
    ControlsVisible = true,
    Mobile = false,
    CurrentOpenTab = nil,
    GameSave = game.PlaceId,
    CheckOtherConfig = true,
    Assets = {},
    Teleporting = false,
    InitSave = nil,
    Config = {
        UI = {
            Position = {X = 0.5, Y = 0.5},
            Size = {X = 0.37294304370880129, Y = 0.683131217956543},
            FullScreen = false,
            ToggleKeyCode = "LeftAlt",
            Scale = 1,
            Notifications = true,
            Anim = true,
            ArrayList = false,
            TabColor = {value1 = 25, value2 = 25, value3 = 25},
            TabTransparency = 0.03,
            KeybindTransparency = 0.7,
            KeybindColor = {value1 = 0, value2 = 0, value3 = 0},
        },
        Game = {
            Modules = {},
            Keybinds = {},
            Sliders = {},
            TextBoxes = {},
            MiniToggles = {},
            Dropdowns = {},
            ModuleKeybinds = {},
            Other = {}
        },
    }
}

if getgenv().NightInit then
    if getgenv().NightInit.GameSave then
        getgenv().Night.GameSave = getgenv().NightInit.GameSave
    end
    if getgenv().NightInit.CheckOtherConfig then
        getgenv().Night.CheckOtherConfig = getgenv().NightInit.CheckOtherConfig
    end
    if getgenv().NightInit.Dev then
        getgenv().Night.Dev = true
    end
    getgenv().Night.InitSave = getgenv().NightInit
    getgenv().NightInit = nil
end

local Assets = nil
if getgenv().Night.Dev and isfile(baseFolder .. "/Library/Init.lua") then
    loadstring(readfile(baseFolder .. "/Library/Init.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/warprbx/NightRewrite/refs/heads/main/Night/Library/Init.lua"))()
end
Assets = getgenv().Night.Assets

if not Assets or typeof(Assets) ~= "table" or (Assets and not Assets.Functions) then
    getgenv().Night = nil
    return warn("Failed to load Functions, Night uninjected")
end

local uis = Assets.Functions.cloneref(game:GetService("UserInputService"))
local ws = Assets.Functions.cloneref(game:GetService("Workspace"))
local plrs = Assets.Functions.cloneref(game:GetService("Players"))
local currentCamera = ws:FindFirstChildWhichIsA("Camera")

if not uis.KeyboardEnabled and uis.TouchEnabled then
    getgenv().Night.Mobile = true
    getgenv().Night.Config.UI.Size = {X = 0.7, Y = 0.9}
end

local HttpService = game:GetService("HttpService")

-- Load UI config
local uiPath = configFolder .. "/UI.json"
local UI = isfile(uiPath) and HttpService:JSONDecode(readfile(uiPath)) or "no file"
if UI == "no file" then
    writefile(uiPath, HttpService:JSONEncode(getgenv().Night.Config.UI))
else
    getgenv().Night.Config.UI = UI
end

-- Load Game config
local gameConfigPath = configFolder .. "/" .. tostring(getgenv().Night.GameSave) .. ".json"
local gamesave = isfile(gameConfigPath) and HttpService:JSONDecode(readfile(gameConfigPath)) or "no file"
if gamesave == "no file" and getgenv().Night.CheckOtherConfig then
    local altGameConfig = configFolder .. "/" .. tostring(game.PlaceId) .. ".json"
    if isfile(altGameConfig) then
        gamesave = HttpService:JSONDecode(readfile(altGameConfig))
    end
end
if gamesave == "no file" then
    writefile(gameConfigPath, HttpService:JSONEncode(getgenv().Night.Config.Game))
else
    getgenv().Night.Config.Game = gamesave
end

-- Adjust scale for mobile
if getgenv().Night.Mobile and currentCamera then
    local scale = (currentCamera.ViewportSize.X / 1000) - 0.1
    getgenv().Night.Config.UI.Scale = math.clamp(scale, 0.4, 1)
end

if queue_on_teleport then
    table.insert(getgenv().Night.Connections, plrs.LocalPlayer.OnTeleport:Connect(function(state)
        if not getgenv().Night.Teleporting then
            getgenv().Night.Teleporting = true
            local str = ""
            if getgenv().Night.InitSave then
                str = "getgenv().NightInit = {"
                for i, v in pairs(getgenv().Night.InitSave) do
                    if typeof(v) == "string" then
                        str = str..tostring(i)..' = "'..tostring(v)..'", '
                    else
                        str = str..tostring(i).." = "..tostring(v)..", "
                    end
                end
                str = string.sub(str, 1, #str - 2).."}\n"
            end
            str = str..[[
                if not game:IsLoaded() then
                    game.Loaded:Wait()
                end

                if getgenv().NightInit and getgenv().NightInit.Dev and isfile("Kawnew Premium Script/Loader.lua") then
                    loadstring(readfile("Kawnew Premium Script/Loader.lua"))()
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/warprbx/NightRewrite/refs/heads/main/Night/Loader.luau"))()
                end
            ]]
            queue_on_teleport(str)
        end
    end))
end

Assets.Main.Load("Universal")
Assets.Main.Load(getgenv().Night.GameSave)
Assets.Main.ToggleVisibility(true)

getgenv().Night.Main = Assets.Main
getgenv().Night.LoadTime = os.clock() - getgenv().Night.Load
Assets.Notifications.Send({
    Description = "Loaded in " .. string.format("%.1f", getgenv().Night.LoadTime) .. " seconds",
    Duration = 5
})

local versionPath = baseFolder .. "/Version.txt"
if not isfile(versionPath) then
    writefile(versionPath, "Current version: 2.1.4")
    Assets.Notifications.Send({
        Description = "Kawnew has been updated to V2.1.4",
        Duration = 15
    })
end

local text = readfile(versionPath)
if text ~= "Current version: 2.1.4" then
    writefile(versionPath, "Current version: 2.1.4")
    Assets.Notifications.Send({
        Description = "Kawnew has been updated to V2.1.4",
        Duration = 15
    })
end

Night.Loaded = true
return Assets.Main
