-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo R6 + Nháy Mặt Lưng (Visualizer) 💟
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
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Dọn dẹp cũ nếu có
    if FakeBoombox then FakeBoombox:Destroy() end
    for _, bar in pairs(VisualizerBars) do if bar then bar:Destroy() end end
    VisualizerBars = {}
    if loopConnection then loopConnection:Disconnect() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character or not (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")) then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Khởi tạo Mesh chuẩn Chroma Boombox
    FakeBoombox = Instance.new("SpecialMesh")
    FakeBoombox.MeshId = "rbxassetid://212641536" 
    FakeBoombox.TextureId = "rbxassetid://212641550" 
    
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    -- Tăng bề ngang lên 2.2 (Cũ là 1.8) để hợp với dáng vuông của R6 trong ảnh 1000056610.jpg
    part.Size = Vector3.new(2.2, 1.3, 0.4) 
    part.CanCollide = false
    part.Massless = true
    FakeBoombox.Parent = part
    part.Parent = character
    
    -- Gắn và Xoay Xéo như đeo Balo Quai Chéo sau lưng
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.1, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- TẠO CÁC THANH SÓNG NHẠC TRÙNG VỚI BỀ MẶT LƯNG KHỐI VUÔNG
    local barCount = 5 
    local barWidth = 2.0 / barCount -- Dãn bề ngang sóng ra theo tỉ lệ loa mới
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Độ dày (Z) mỏng lại để áp sát vào mặt lưng, chiều cao mặc định ban đầu nhỏ
        local varSize = Vector3.new(barWidth - 0.05, 0.1, 0.05) 
        bar.Size = varSize
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Cài đặt vị trí: Đưa ra bề mặt lưng (Z = 0.21) và xếp hàng ngang
        local xOffset = -1.0 + (i - 0.5) * barWidth
        -- Cho chân thanh sóng xuất phát từ giữa khối vuông đi lên
        barWeld.C0 = CFrame.new(xOffset, 0, 0.21) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + Nhảy sóng nhấp nhô TRÊN BỀ MẶT LƯNG
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Lấy độ lớn âm thanh hiện tại
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 300, 0, 1) 
        
        -- Tốc độ màu cầu vồng theo nhịp bass
        local speedMultiplier = 1 + (normLoudness * 3)
        hue = (hue + (0.6 * speedMultiplier)) % 360 
        
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        part.Color = mainColor
        FakeBoombox.VertexColor = Vector3.new(mainColor.R, mainColor.G, mainColor.B)
        
        -- Cập nhật dải sóng nhảy đều đặn trên bề mặt lưng
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                local waveFactor = math.sin(tick() * 12 + item.Index) * 0.1
                -- Chiều cao nhịp vừa vặn, ôm gọn trong phạm vi mặt lưng khối vuông (tối đa 0.9)
                local targetHeight = math.clamp((normLoudness * 0.7) + waveFactor, 0.1, 0.9)
                
                -- Thay đổi chiều cao (Y) theo nhịp nhạc
                item.Part.Size = Vector3.new(item.Part.Size.X, targetHeight, item.Part.Size.Z)
                
                -- Căn chỉnh tâm Weld: Đẩy dịch chuyển Y lên bằng một nửa chiều cao để nhịp mọc hướng lên trên bề mặt lưng cực chuẩn
                local xOffset = -1.0 + (item.Index - 0.5) * barWidth
                item.Weld.C0 = CFrame.new(xOffset, -0.4 + (targetHeight / 2), 0.21)
                
                -- Đổi màu dải cầu vồng lệch nhịp 
                local barHue = (hue + (item.Index * 18)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE (HỒI SINH KHÔNG MẤT LOA)
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

-- Kích hoạt phát nhạc và gọi Loa Đeo Chéo xuất hiện
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        CreateFakeBoombox() 
        print("Thanh Phuc đã bật nhạc + Boombox R6 Equalizer mặt lưng!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)

