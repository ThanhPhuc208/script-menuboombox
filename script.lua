-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo + Nháy Theo Nhạc (Visualizer Mặt Lưng) 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER MẶT LƯNG
local FakeBoombox = nil
local VisualizerBars = {}
local StrapPart = nil -- Quai đeo chéo
local loopConnection = nil -- Quản lý loop hiệu ứng tránh bị chồng luồng khi reset

local function CreateFakeBoombox()
    -- Dọn dẹp cũ nếu có
    if FakeBoombox then FakeBoombox:Destroy() end
    if StrapPart then StrapPart:Destroy() end
    for _, bar in pairs(VisualizerBars) do if bar then bar:Destroy() end end
    VisualizerBars = {}
    if loopConnection then loopConnection:Disconnect() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character or not (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")) then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Khởi tạo Mesh chuẩn Chroma Boombox (Dáng dẹp, gọn)
    FakeBoombox = Instance.new("SpecialMesh")
    FakeBoombox.MeshId = "rbxassetid://212641536" 
    FakeBoombox.TextureId = "rbxassetid://212641550" 
    
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Size = Vector3.new(1.8, 1.2, 0.4) -- Thu hẹp bề ngang cực kỳ gọn
    part.CanCollide = false
    part.Massless = true
    FakeBoombox.Parent = part
    part.Parent = character
    
    -- Gắn và Xoay Xéo như đeo Balo Quai Chéo sau lưng
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- TẠO QUAI ĐEO CHÉO (CHẠY TỪ CỔ/VAI XUỐNG EO)
    StrapPart = Instance.new("Part")
    StrapPart.Name = "ThanhPhucBoomboxStrap"
    StrapPart.Material = Enum.Material.Neon
    StrapPart.Size = Vector3.new(0.25, 2.3, 0.05) -- Kích thước quai dẹt dài ôm thân
    StrapPart.CanCollide = false
    StrapPart.Massless = true
    StrapPart.Parent = character
    
    local strapWeld = Instance.new("Weld")
    strapWeld.Part0 = torso
    strapWeld.Part1 = StrapPart
    strapWeld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(10), math.rad(15), math.rad(-35))
    strapWeld.Parent = StrapPart
    
    -- TẠO CÁC THANH SÓNG NHẠC PHẲNG ỐP NGOÀI BỀ MẶT LƯNG
    local barCount = 5 -- Số lượng thanh sóng nhạc xếp đều theo bề ngang
    local barWidth = 1.5 / barCount -- Thu hẹp lại một chút để nằm gọn bên trong mặt lưng loa
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Độ dày siêu mỏng (0.01) để nó dính sát như một decal/màn hình LED ngoài mặt lưng
        bar.Size = Vector3.new(barWidth - 0.04, 0.1, 0.01) 
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Căn vị trí: Nằm ngay ngoài bề mặt lưng khối (Z = 0.21), nháy dọc theo trục Y
        local xOffset = -0.75 + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, 0, 0.21) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + Co giãn sóng nhạc trên bề mặt sau
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Lấy độ lớn âm thanh hiện tại
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 320, 0, 1) 
        
        -- Tốc độ chuyển màu Cầu vồng chạy theo nhịp Bass
        local speedMultiplier = 1 + (normLoudness * 3)
        hue = (hue + (0.6 * speedMultiplier)) % 360 
        
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        part.Color = mainColor
        FakeBoombox.VertexColor = Vector3.new(mainColor.R, mainColor.G, mainColor.B)
        
        -- Cập nhật màu sắc cho Quai đeo chéo đồng điệu
        if StrapPart and StrapPart.Parent then
            local strapHue = (hue + 30) % 360
            StrapPart.Color = Color3.fromHSV(strapHue / 360, 1, 1)
        end
        
        -- Cập nhật các thanh sóng nháy dọc cực kỳ dễ nhìn và cân bằng
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Tạo nhịp sóng mượt, vừa vặn cân bằng không vượt quá chiều cao loa (max 1.2)
                local waveFactor = math.sin(tick() * 14 + item.Index) * 0.15
                local targetHeight = math.clamp((normLoudness * 0.8) + waveFactor, 0.1, 0.9) 
                
                -- Thay đổi chiều cao (Trục Y) co giãn ngay trên bề mặt phẳng của lưng loa
                item.Part.Size = Vector3.new(item.Part.Size.X, targetHeight, item.Part.Size.Z)
                
                -- Giữ nguyên vị trí tâm cố định ở giữa mặt sau để sóng co giãn đều từ trung tâm ra
                local xOffset = -0.75 + (item.Index - 0.5) * barWidth
                item.Weld.C0 = CFrame.new(xOffset, 0, 0.21)
                
                -- Đổi màu dải cầu vồng lệch nhịp từng thanh tạo hiệu ứng EQ LED chuyên nghiệp
                local barHue = (hue + (item.Index * 20)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) 
    if LocalSound.IsPlaying or LocalSound.TimePosition > 0 then
        CreateFakeBoombox()
    end
end)

-- GIAO DIỆN GUI (Giữ nguyên toàn bộ cấu trúc cũ)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Nút ẨN MENU
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false 
end)

-- Nút MỞ MENU
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true 
end)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Ô nhập ID Nhạc
local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

-- Nút PHÁT NHẠC
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        CreateFakeBoombox() 
        print("Thanh Phuc đã bật nhạc + Hiện sóng LED mặt lưng cực nét!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
