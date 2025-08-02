-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AHS"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
toggleBtn.Text = "Open AHS"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 260, 0, 530)
mainFrame.Position = UDim2.new(0, 10, 0.45, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Visible = false

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleBtn.Text = mainFrame.Visible and "Close AHS" or "Open AHS"
end)

-- Drag GUI
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- UI toggles creation helper
local y = 10
local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    y += 30
end

createToggle("Aimbot", false, function(v) AimbotToggle = v end)
createToggle("Auto Weapon Detect", true, function(v) AutoWeaponEnabled = v end)
createToggle("Prediction", true, function(v) PredictionEnabled = v end)
createToggle("Team Check", true, function(v) TeamCheck = v end)
createToggle("Wall Check", true, function(v) WallCheck = v end)
createToggle("Dead Check", true, function(v) DeadCheck = v end)
createToggle("Friends Check", true, function(v) FriendsCheck = v end)
createToggle("Aim Head/Torso", true, function(v) AimPart = v and "Head" or "Torso" end)
createToggle("ESP", true, function(v)
    ESPEnabled = v
    for _, billboard in pairs(ESP_Objects) do
        if billboard and billboard:IsA("BillboardGui") then
            billboard.Enabled = v
        end
    end
end)

local fovLabel = Instance.new("TextLabel", mainFrame)
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.Position = UDim2.new(0, 10, 0, y)
fovLabel.Text = "FOV: " .. FOV
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.BackgroundTransparency = 1
y += 20

local fovSlider = Instance.new("TextButton", mainFrame)
fovSlider.Size = UDim2.new(1, -20, 0, 25)
fovSlider.Position = UDim2.new(0, 10, 0, y)
fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovSlider.TextColor3 = Color3.new(1, 1, 1)
fovSlider.Text = "Increase FOV"
fovSlider.MouseButton1Click:Connect(function()
    FOV = (FOV >= 200) and 50 or FOV + 25
    fovLabel.Text = "FOV: " .. tostring(FOV)
end)
y += 35

-- =========  Prediction Strength UI  =========
-- 1) Khai báo trước, tạm = nil
local predLabel

-- 2) Hàm cập-nhật (kiểm tra nil cho chắc)
local function updatePredLabel()
    if predLabel then
        predLabel.Text = ("PredStrength: %.2f"):format(PredictionStrength)
    end
end

-- 3) Tạo Label (TextButton)
predLabel = Instance.new("TextButton")
predLabel.Size = UDim2.new(1, -20, 0, 25)
predLabel.Position = UDim2.new(0, 10, 0, y)
predLabel.BackgroundTransparency = 1
predLabel.TextColor3 = Color3.new(1,1,1)
predLabel.Font = Enum.Font.SourceSansBold
predLabel.TextSize = 18
predLabel.Parent = mainFrame
updatePredLabel()            -- giờ predLabel đã tồn tại
y += 30

-- Nút “–”
local minusBtn = Instance.new("TextButton", mainFrame)
minusBtn.Size = UDim2.new(0.48, -15, 0, 25)
minusBtn.Position = UDim2.new(0, 10, 0, y)
minusBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.Text = "-"

-- Nút “+”
local plusBtn = minusBtn:Clone()
plusBtn.Position = UDim2.new(0.52, 5, 0, y)
plusBtn.Text = "+"

minusBtn.Parent, plusBtn.Parent = mainFrame, mainFrame
y += 35

-- Xử lý tăng/giảm
local function changePred(delta)
    PredictionStrength = math.clamp(PredictionStrength + delta, 0.50, 1)
    updatePredLabel()
end
minusBtn.MouseButton1Click:Connect(function() changePred(-0.05) end)
plusBtn.MouseButton1Click:Connect(function() changePred( 0.05) end)

-- Nhập tay khi bấm vào nhãn
predLabel.MouseButton1Click:Connect(function()
    -- Tạo TextBox tạm
    local box = Instance.new("TextBox", mainFrame)
    box.Size = predLabel.Size
    box.Position = predLabel.Position
    box.Text = tostring(PredictionStrength)
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 18
    box.ClearTextOnFocus = false
    box.FocusLost:Connect(function(enter)
        if enter then
            local v = tonumber(box.Text)
            if v then
                PredictionStrength = math.clamp(v, 0.50, 1)
            end
        end
        updatePredLabel()
        box:Destroy()
    end)
    box:CaptureFocus()
end)

-- Auto detect weapon state
local function UpdateWeaponState()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    HoldingWeapon = (tool and RangedWeapons[tool.Name]) and true or false
end

if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(UpdateWeaponState)
    LocalPlayer.Character.ChildRemoved:Connect(UpdateWeaponState)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(UpdateWeaponState)
    char.ChildRemoved:Connect(UpdateWeaponState)
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Visible = true

local function CreateBillboardESP(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Nếu đã có sẵn billboard thì chỉ cần đồng bộ trạng thái hiển thị
    local existing = head:FindFirstChild("ESP_Billboard")
    if existing then
        existing.Enabled = ESPEnabled
        return existing
    end

    -- Tạo BillboardGui mới
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 60, 0, 16)  -- nhỏ gọn hơn
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ESPEnabled   -- ẩn/hiện theo toggle hiện tại

    -- Label bên trong
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = character.Name or ""
    label.TextColor3 = Color3.fromRGB(0, 255, 0)        -- xanh lá mạ
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard

    billboard.Parent = head
    return billboard
end

local function SetupESPForPlayer(player)
    player.CharacterAdded:Connect(function(char)
        wait(0.1)
        local billboard = CreateBillboardESP(char)
        ESP_Objects[player] = billboard
    end)
    if player.Character then
        local billboard = CreateBillboardESP(player.Character)
        ESP_Objects[player] = billboard
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then SetupESPForPlayer(player) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then SetupESPForPlayer(plr) end
end)

-- Giảm tần suất cập nhật offset ESP (cập nhật mỗi 0.1s thay vì mỗi frame)
local lastESPUpdate = 0
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    local now = tick()
    if now - lastESPUpdate < 0.1 then return end
    lastESPUpdate = now

    local screenPositions = {}
    for player, billboard in pairs(ESP_Objects) do
        local char = player.Character
        if char and billboard and billboard.Adornee then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    table.insert(screenPositions, {billboard = billboard, screenY = pos.Y})
                end
            end
        end
    end
    table.sort(screenPositions, function(a, b) return a.screenY < b.screenY end)

    local offsetY = 0
    local spacing = 12
    for _, data in ipairs(screenPositions) do
        if data.billboard and data.billboard.Parent then
            data.billboard.StudsOffset = Vector3.new(0, 2 + offsetY / 50, 0)
            offsetY += spacing           
        end
    end
end)