if shared.VapeExecuted then return else shared.VapeExecuted = true end

loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Vynixius/Source.lua"))()
local GuiLibrary = shared.Vynixius

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GUI = GuiLibrary:CreateWindow("GUI", "PC", UDim2.new(0,6,0,6), true)
local Combat = GuiLibrary:CreateWindow("Combat", "Sword", UDim2.new(0,177,0,6), false)
local Blatant = GuiLibrary:CreateWindow("Blatant", "Warning", UDim2.new(0,177,0,6), false)
local Render = GuiLibrary:CreateWindow("Render", "Eye", UDim2.new(0,177,0,6), false)

GUI:CreateButton("Combat", function() Combat:SetVisible(true) end, function() Combat:SetVisible(false) end)
GUI:CreateButton("Blatant", function() Blatant:SetVisible(true) end, function() Blatant:SetVisible(false) end)
GUI:CreateButton("Render", function() Render:SetVisible(true) end, function() Render:SetVisible(false) end)

local Aimbot = {Enabled = false, TargetPart = "Head"}
local SilentAim = {Enabled = false}
local AntiKatana = {Enabled = false}
local KillAura = {Enabled = false, Range = 15}
local InfinityJump = {Enabled = false}

Aimbot = Combat:CreateOptionsButton("Aimbot", function()
    Aimbot.Enabled = true
    spawn(function()
        while task.wait() and Aimbot.Enabled do
            if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")) then continue end
            local closest = nil
            local closestDist = math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr == LocalPlayer or not plr.Character then continue end
                local targetPart
                if Aimbot.TargetPart == "Random" then
                    local parts = {}
                    if plr.Character:FindFirstChild("Head") then table.insert(parts, plr.Character.Head) end
                    if plr.Character:FindFirstChild("UpperTorso") then table.insert(parts, plr.Character.UpperTorso) end
                    if plr.Character:FindFirstChild("HumanoidRootPart") then table.insert(parts, plr.Character.HumanoidRootPart) end
                    if #parts > 0 then targetPart = parts[math.random(#parts)] end
                else
                    targetPart = plr.Character:FindFirstChild(Aimbot.TargetPart) or plr.Character.Head
                end
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if dist < closestDist and dist < 300 then
                            closestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
            if closest then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
            end
        end
    end)
end, function() Aimbot.Enabled = false end, true)

Combat:CreateDropdown("Aimbot Part", {"Head", "Torso", "Random"}, function(val)
    Aimbot.TargetPart = val == "Torso" and "UpperTorso" or val
end)

InfinityJump = Combat:CreateOptionsButton("Infinity Jump", function()
    InfinityJump.Enabled = true
    UserInputService.JumpRequest:Connect(function()
        if InfinityJump.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end, function() InfinityJump.Enabled = false end, false)

SilentAim = Combat:CreateOptionsButton("Silent Aim", function() SilentAim.Enabled = true end, function() SilentAim.Enabled = false end, false)

AntiKatana = Combat:CreateOptionsButton("Anti-Katana", function()
    AntiKatana.Enabled = true
    local katanaRemote = ReplicatedStorage:FindFirstChild("KatanaSwing") or ReplicatedStorage:FindFirstChild("SwordSwing") or ReplicatedStorage:FindFirstChild("MeleeSwing")
    if not katanaRemote then return end
    hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if AntiKatana.Enabled and self == katanaRemote and method == "FireServer" then
            local attacker = args[1]
            if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (attacker.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 10 then
                    task.spawn(function()
                        task.wait(0.05)
                        katanaRemote:FireServer(LocalPlayer.Character.HumanoidRootPart, "Parry")
                    end)
                end
            end
        end
        return hookmetamethod(game, "__namecall")(self, ...)
    end)
end, function() AntiKatana.Enabled = false end, false)

KillAura = Combat:CreateOptionsButton("KillAura", function()
    KillAura.Enabled = true
    spawn(function()
        while task.wait(0.05) and KillAura.Enabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= KillAura.Range then
                            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool and tool:FindFirstChild("Handle") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end
    end)
end, function() KillAura.Enabled = false end, false)

local SpeedHack = {Speed = 16}
SpeedHack = Blatant:CreateSlider("Speed", 16, 200, function(val)
    SpeedHack.Speed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

local FlyHack = {Enabled = false, Speed = 200}
FlyHack = Blatant:CreateOptionsButton("Fly Hack", function()
    FlyHack.Enabled = true
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
    spawn(function()
        while FlyHack.Enabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                bodyGyro.CFrame = Camera.CFrame
                local move = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                bodyVelocity.Velocity = move.Unit * FlyHack.Speed
            end
            task.wait()
        end
        bodyGyro:Destroy()
        bodyVelocity:Destroy()
    end)
end, function() FlyHack.Enabled = false end, false)

local ESP = {Box = {}, Line = {}, Enabled = true}
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromRGB(255,0,0)
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(0,255,0)
    ESP.Box[plr] = box
    ESP.Line[plr] = line
    spawn(function()
        while ESP.Enabled and plr.Character do
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if root and head then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                if onScreen then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.5
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    box.Visible = true
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(rootPos.X, rootPos.Y)
                    line.Visible = true
                else
                    box.Visible = false
                    line.Visible = false
                end
            end
            task.wait()
        end
        box:Remove()
        line:Remove()
    end)
end
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then CreateESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if ESP.Enabled then CreateESP(plr) end
end)

local NoClip = {Enabled = false}
NoClip = Render:CreateOptionsButton("NoClip", function()
    NoClip.Enabled = true
    spawn(function()
        while NoClip.Enabled do
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end, function() NoClip.Enabled = false end, false)

GuiLibrary:Notify("Vape Loaded", "Delta Ready")
