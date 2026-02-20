-- // SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- // SIMPLE SESSION ENCRYPTION (ONLY FOR SESSION IDs)
local SessionEncryption = {
    Key = "SIMPLE-KEY-2024",
    
    Encrypt = function(self, text)
        local encrypted = {}
        for i = 1, #text do
            local charCode = string.byte(text, i)
            local keyCode = string.byte(self.Key, ((i - 1) % #self.Key) + 1)
            table.insert(encrypted, string.char(charCode + keyCode))
        end
        return table.concat(encrypted)
    end,
    
    Decrypt = function(self, encryptedText)
        local decrypted = {}
        for i = 1, #encryptedText do
            local charCode = string.byte(encryptedText, i)
            local keyCode = string.byte(self.Key, ((i - 1) % #self.Key) + 1)
            table.insert(decrypted, string.char(charCode - keyCode))
        end
        return table.concat(decrypted)
    end,
    
    SessionStorage = {},
    
    CreateSession = function(self, data)
        local sessionId = "SESS_" .. os.time() .. "_" .. math.random(1000, 9999)
        local encryptedData = self:Encrypt(sessionId .. "::" .. tostring(data))
        self.SessionStorage[sessionId] = encryptedData
        return sessionId
    end,
    
    ValidateSession = function(self, sessionId)
        if self.SessionStorage[sessionId] then
            local decrypted = self:Decrypt(self.SessionStorage[sessionId])
            local storedId = decrypted:match("(.*)::")
            return storedId == sessionId
        end
        return false
    end
}

-- // MINI TIPS SYSTEM
local function CreateMiniTips()
    local TipsGui = Instance.new("ScreenGui")
    TipsGui.Name = "MiniTips"
    TipsGui.DisplayOrder = 9998
    TipsGui.ResetOnSpawn = false
    TipsGui.Parent = (gethui and gethui()) or Player:WaitForChild("PlayerGui")
    
    local TipBox = Instance.new("Frame")
    TipBox.Size = UDim2.new(0, 280, 0, 38)
    TipBox.Position = UDim2.new(1, -290, 0, 15)
    TipBox.BackgroundColor3 = Color3.fromRGB(15, 8, 8)
    TipBox.BackgroundTransparency = 0.15
    TipBox.BorderSizePixel = 0
    
    Instance.new("UICorner", TipBox).CornerRadius = UDim.new(0, 10)
    
    local TipStroke = Instance.new("UIStroke", TipBox)
    TipStroke.Color = Color3.fromRGB(255, 60, 60)
    TipStroke.Thickness = 1.2
    TipStroke.Transparency = 0.4
    
    local TipIcon = Instance.new("TextLabel")
    TipIcon.Size = UDim2.new(0, 30, 1, 0)
    TipIcon.Position = UDim2.new(0, 8, 0, 0)
    TipIcon.Text = "💡"
    TipIcon.TextColor3 = Color3.fromRGB(255, 200, 100)
    TipIcon.Font = Enum.Font.GothamBold
    TipIcon.TextSize = 16
    TipIcon.BackgroundTransparency = 1
    TipIcon.Parent = TipBox
    
    local TipText = Instance.new("TextLabel")
    TipText.Size = UDim2.new(1, -45, 1, -8)
    TipText.Position = UDim2.new(0, 35, 0, 4)
    TipText.Text = ""
    TipText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TipText.Font = Enum.Font.Gotham
    TipText.TextSize = 12
    TipText.TextWrapped = true
    TipText.TextXAlignment = Enum.TextXAlignment.Left
    TipText.BackgroundTransparency = 1
    TipText.Parent = TipBox
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 0, 2)
    Progress.Position = UDim2.new(0, 0, 1, -2)
    Progress.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    Progress.BorderSizePixel = 0
    Progress.Parent = TipBox
    
    TipBox.Parent = TipsGui
    
    local Tips = {
        "BAN GUARANTEED < 30 MINUTES - FEDERAL CASE",
        "DIRECT REPORT TO FBI & INTERPOL",
        "SESSION ENCRYPTED - REPORT TEXT IS PLAIN",
        "COMPLETE FORENSIC EVIDENCE INCLUDED",
        "FEDERAL OFFENSE - FELONY CHARGES"
    }
    
    local function ShowTips()
        TipBox.Position = UDim2.new(1, -290, 0, -50)
        TipBox.Visible = true
        
        local slideIn = TweenService:Create(
            TipBox,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint),
            {Position = UDim2.new(1, -290, 0, 15)}
        )
        slideIn:Play()
        
        task.wait(0.5)
        
        for i = 1, 5 do
            TipText.Text = Tips[i]
            
            Progress.Size = UDim2.new(0, 0, 0, 2)
            local tween = TweenService:Create(
                Progress,
                TweenInfo.new(2.5, Enum.EasingStyle.Linear),
                {Size = UDim2.new(1, 0, 0, 2)}
            )
            tween:Play()
            
            task.wait(2.5)
            
            if i < 5 then
                TipText.TextTransparency = 1
                task.wait(0.1)
                TipText.TextTransparency = 0
            end
        end
        
        local slideOut = TweenService:Create(
            TipBox,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint),
            {Position = UDim2.new(1, -290, 0, -50)}
        )
        slideOut:Play()
        
        task.wait(0.5)
        TipsGui:Destroy()
    end
    
    task.spawn(function()
        task.wait(1.5)
        ShowTips()
    end)
end

-- // DATA COLLECTOR
local ServerData = {
    ServerId = game.JobId:sub(1, 8),
    PlaceId = game.PlaceId,
    GameName = "Loading...",
    TotalPlayers = #Players:GetPlayers(),
    ReportCount = 0
}

task.spawn(function()
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(ServerData.PlaceId).Name
    end)
    ServerData.GameName = success and result or "Roblox Game"
end)

-- // COMPACT GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rathub_report"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or Player:WaitForChild("PlayerGui")

CreateMiniTips()

-- // LAUNCHER BUTTON
local LaunchBtn = Instance.new("ImageButton")
LaunchBtn.Name = "Launcher"
LaunchBtn.Size = UDim2.new(0, 55, 0, 55)
LaunchBtn.Position = UDim2.new(0, 20, 0.5, -27.5)
LaunchBtn.Image = "rbxassetid://129711402878476"
LaunchBtn.BackgroundColor3 = Color3.fromRGB(22, 12, 12)
LaunchBtn.BackgroundTransparency = 0.05
LaunchBtn.AutoButtonColor = false

Instance.new("UICorner", LaunchBtn).CornerRadius = UDim.new(1, 0)

local BtnStroke = Instance.new("UIStroke", LaunchBtn)
BtnStroke.Color = Color3.fromRGB(255, 50, 50)
BtnStroke.Thickness = 2.5

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -6, 0, 6)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
StatusDot.BorderSizePixel = 0
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)
StatusDot.Parent = LaunchBtn

task.spawn(function()
    while true do
        local pulse = TweenService:Create(
            StatusDot,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
            {Size = UDim2.new(0, 10, 0, 10)}
        )
        pulse:Play()
        task.wait(1.6)
    end
end)

task.spawn(function()
    while true do
        local pulse = TweenService:Create(
            BtnStroke,
            TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
            {Thickness = 3.5}
        )
        pulse:Play()
        task.wait(2.5)
    end
end)

LaunchBtn.Parent = ScreenGui

-- // MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 8, 8)
MainFrame.BackgroundTransparency = 0.03
MainFrame.Visible = false

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(80, 25, 25)
FrameStroke.Thickness = 2
FrameStroke.Transparency = 0.15

MainFrame.Parent = ScreenGui

-- Draggable function
local function MakeDraggable(ui)
    local dragging, dragInput, dragStart, startPos
    ui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ui.Position
        end
    end)
    ui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

MakeDraggable(LaunchBtn)
MakeDraggable(MainFrame)

-- Toggle animation
LaunchBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.BackgroundTransparency = 1
        
        local grow = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 350, 0, 480),
                Position = UDim2.new(0.5, -175, 0.5, -240),
                BackgroundTransparency = 0.03
            }
        )
        grow:Play()
    else
        local shrink = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            }
        )
        shrink:Play()
        
        task.wait(0.3)
        MainFrame.Visible = false
    end
end)

-- // HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 26)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Text = "RatHub"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 0, 18)
SubTitle.Position = UDim2.new(0, 15, 0, 36)
SubTitle.Text = "Server: " .. ServerData.ServerId .. " | Reports: 0"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.BackgroundTransparency = 1
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -33, 0, 13)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- // TARGET SELECTION
local TargetSection = Instance.new("Frame")
TargetSection.Size = UDim2.new(1, -30, 0, 110)
TargetSection.Position = UDim2.new(0, 15, 0, 65)
TargetSection.BackgroundTransparency = 1
TargetSection.Parent = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 22)
TargetLabel.Position = UDim2.new(0, 0, 0, 0)
TargetLabel.Text = "TARGET SELECTION:"
TargetLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 14
TargetLabel.BackgroundTransparency = 1
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = TargetSection

local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(1, 0, 0, 36)
TargetBox.Position = UDim2.new(0, 0, 0, 25)
TargetBox.PlaceholderText = "Type username or click player below"
TargetBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.BackgroundColor3 = Color3.fromRGB(30, 16, 16)
TargetBox.Font = Enum.Font.Gotham
TargetBox.TextSize = 13
TargetBox.ClearTextOnFocus = false
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 8)

local BoxStroke = Instance.new("UIStroke", TargetBox)
BoxStroke.Color = Color3.fromRGB(65, 28, 28)
BoxStroke.Thickness = 1.8

TargetBox.Parent = TargetSection

local PlayerFrame = Instance.new("ScrollingFrame")
PlayerFrame.Size = UDim2.new(1, 0, 0, 45)
PlayerFrame.Position = UDim2.new(0, 0, 0, 68)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(26, 13, 13)
PlayerFrame.BackgroundTransparency = 0.08
PlayerFrame.ScrollBarThickness = 3
PlayerFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 70)
PlayerFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
PlayerFrame.ScrollingDirection = Enum.ScrollingDirection.X
Instance.new("UICorner", PlayerFrame).CornerRadius = UDim.new(0, 8)
PlayerFrame.Parent = TargetSection

local PlayerLayout = Instance.new("UIListLayout", PlayerFrame)
PlayerLayout.Padding = UDim.new(0, 6)
PlayerLayout.FillDirection = Enum.FillDirection.Horizontal
PlayerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- Update player list
local function UpdatePlayers()
    for _, child in pairs(PlayerFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(0, 120, 0, 32)
            PlayerBtn.Text = "@" .. player.DisplayName
            PlayerBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 22, 22)
            PlayerBtn.Font = Enum.Font.Gotham
            PlayerBtn.TextSize = 12
            PlayerBtn.AutoButtonColor = true
            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 6)
            
            local BtnStroke = Instance.new("UIStroke", PlayerBtn)
            BtnStroke.Color = Color3.fromRGB(65, 30, 30)
            BtnStroke.Thickness = 1.5
            
            PlayerBtn.MouseButton1Click:Connect(function()
                TargetBox.Text = player.Name
                TargetBox.TextColor3 = Color3.fromRGB(255, 120, 120)
                
                local pulse = TweenService:Create(
                    PlayerBtn,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Color3.fromRGB(60, 28, 38)}
                )
                pulse:Play()
                
                task.wait(0.15)
                pulse = TweenService:Create(
                    PlayerBtn,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Color3.fromRGB(40, 22, 22)}
                )
                pulse:Play()
            end)
            
            PlayerBtn.Parent = PlayerFrame
        end
    end
    ServerData.TotalPlayers = #Players:GetPlayers() - 1
end

task.spawn(function()
    while true do
        UpdatePlayers()
        task.wait(7)
    end
end)

-- // REPORT SECTION
local ReportSection = Instance.new("Frame")
ReportSection.Size = UDim2.new(1, -30, 0, 260)
ReportSection.Position = UDim2.new(0, 15, 0, 185)
ReportSection.BackgroundTransparency = 1
ReportSection.Parent = MainFrame

local ReportLabel = Instance.new("TextLabel")
ReportLabel.Size = UDim2.new(1, 0, 0, 22)
ReportLabel.Position = UDim2.new(0, 0, 0, 0)
ReportLabel.Text = "FEDERAL REPORT CATEGORIES:"
ReportLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
ReportLabel.Font = Enum.Font.GothamSemibold
ReportLabel.TextSize = 14
ReportLabel.BackgroundTransparency = 1
ReportLabel.TextXAlignment = Enum.TextXAlignment.Left
ReportLabel.Parent = ReportSection

local ReportContainer = Instance.new("ScrollingFrame")
ReportContainer.Size = UDim2.new(1, 0, 1, -25)
ReportContainer.Position = UDim2.new(0, 0, 0, 25)
ReportContainer.BackgroundTransparency = 1
ReportContainer.ScrollBarThickness = 3
ReportContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 70)
ReportContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ReportContainer.Parent = ReportSection

local ReportLayout = Instance.new("UIListLayout", ReportContainer)
ReportLayout.Padding = UDim.new(0, 8)

-- // FEDERAL REPORT TEMPLATES WITH DESCRIPTIONS
local Reports = {
    {
        Icon = "FEDERAL", 
        Title = "CHILD PREDATOR", 
        Description = "People who target minors for sexual purposes, request explicit photos, or attempt to meet minors in person",
        Color = Color3.fromRGB(255, 30, 30), 
        Duration = 1.5,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("PREDATOR_CASE_" .. target)
            return string.format([[
FEDERAL BUREAU OF INVESTIGATION
URGENT: ACTIVE CHILD PREDATOR ALERT
============================================================

CRIMINAL COMPLAINT: CHILD SEXUAL ABUSE MATERIAL (CSAM)
TARGET USERNAME: %s
SESSION ID: %s
REPORT TIMESTAMP: %s UTC
SERVER ID: %s

SECTION 1: CONFIRMED CRIMINAL ACTIVITY
------------------------------------------------------------
The identified user has been observed engaging in the following illegal activities:

A. Solicitation of Minors (Ages 9-13)
   - Requesting explicit photographs from underage users
   - Offering virtual currency (Robux) in exchange for sexual content
   - Attempting to arrange physical meetings with minors

B. Distribution of Explicit Material
   - Sharing links containing CSAM through private messages
   - Operating an underground network for content distribution
   - 50+ confirmed instances of CSAM distribution

C. Grooming Behavior Pattern
   - 7 confirmed minor victims (ages 9-14)
   - 12 potential victims under investigation
   - Active grooming occurring within last 24 hours

SECTION 2: FEDERAL VIOLATIONS
------------------------------------------------------------
18 U.S.C. § 2251 - Sexual Exploitation of Children
   - Penalty: 15-30 years imprisonment
   - Fine: Up to $250,000

18 U.S.C. § 2252 - CSAM Distribution
   - Penalty: 5-20 years imprisonment
   - Fine: Up to $250,000

18 U.S.C. § 2422(b) - Coercion of Minor
   - Penalty: 10 years to life imprisonment
   - Fine: Up to $250,000

SECTION 3: DIGITAL FORENSICS
------------------------------------------------------------
Evidence Hash: %s
Chain of Custody: %s
Digital Footprint: Complete packet capture available

SECTION 4: IMMEDIATE ACTION REQUIRED
------------------------------------------------------------
DEADLINE: 15 MINUTES FROM REPORT TIMESTAMP
CURRENT TIME: %s
DEADLINE: %s

FAILURE TO TERMINATE THIS ACCOUNT WITHIN DEADLINE WILL RESULT IN:

1. Federal complaint filed with IC3 (Internet Crime Complaint Center)
2. Notification to NCMEC (National Center for Missing & Exploited Children)
3. Interpol Cybercrime Division alert
4. Homeland Security investigation into platform compliance
5. Federal subpoena for all user data and logs
6. Class action lawsuit from victims' families

SECTION 5: CERTIFICATION
------------------------------------------------------------
This report constitutes a formal complaint under federal law.
All information provided is accurate to the best of my knowledge.
False reporting is punishable under 18 U.S.C. § 1001.

Investigator ID: FBI-CYBER-%s
Case Number: %s
Session Status: %s

END OF FEDERAL COMPLAINT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
ServerData.ServerId,
HttpService:GenerateGUID(false):sub(1, 16),
HttpService:GenerateGUID(false):sub(1, 8),
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 900),
math.random(10000, 99999),
os.time() % 1000000,
SessionEncryption:ValidateSession(sessionId) and "ACTIVE" or "INVALID")
        end
    },
    {
        Icon = "FEDERAL", 
        Title = "SUICIDE INCITER", 
        Description = "People who encourage others to harm themselves, organize suicide pacts, or provide methods for self-harm",
        Color = Color3.fromRGB(255, 40, 40), 
        Duration = 1.5,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("SUICIDE_CASE_" .. target)
            return string.format([[
DEPARTMENT OF HEALTH AND HUMAN SERVICES
CRISIS: ACTIVE SUICIDE PACT ORGANIZATION
============================================================

EMERGENCY INTERVENTION REQUEST
TARGET: %s
SESSION ID: %s
REPORT TIME: %s UTC

SECTION 1: CRITICAL THREAT ASSESSMENT
------------------------------------------------------------
The identified user is actively inciting suicide among minors:

A. Confirmed Activities:
   - Organizing group suicide pact (8 minors identified, ages 13-16)
   - Providing specific suicide methods and instructions
   - Targeting vulnerable minors with depression
   - Distributing "suicide manuals" through private channels

B. Victims Status:
   - 2 minors HOSPITALIZED after following instructions
   - 3 minors with active suicide notes prepared
   - Crisis intervention teams currently mobilized
   - 1 minor in ICU (critical condition)

C. Communication Logs Show:
   - Detailed instructions for suicide methods
   - Encouragement to "end suffering together"
   - Coordination for mass suicide event
   - Bypassed platform filters using coded language

SECTION 2: CRIMINAL VIOLATIONS
------------------------------------------------------------
18 U.S.C. § 875(c) - Interstate Communications Threats
   - Penalty: Up to 5 years imprisonment

Involuntary Manslaughter (if deaths occur)
   - Penalty: Up to 10 years imprisonment

Criminal Endangerment of Minors
   - Penalty: Up to 5 years per count

SECTION 3: MEDICAL EMERGENCY STATUS
------------------------------------------------------------
Threat Level: CRITICAL - Active Life Danger
Response Window: MINUTES, NOT HOURS
Current Risk: 8 minors in immediate danger
Medical Intervention: Ongoing

SECTION 4: EMERGENCY RESPONSE DEADLINE
------------------------------------------------------------
DEADLINE: 5 MINUTES - LIVES AT RISK
CURRENT TIME: %s
FINAL DEADLINE: %s

FAILURE TO ACT WILL CONSTITUTE:
   - Criminal negligence
   - Aiding and abetting suicide
   - Civil liability for wrongful deaths

SECTION 5: IMMEDIATE REQUIREMENTS
------------------------------------------------------------
1. INSTANT ACCOUNT TERMINATION
2. IP ADDRESS AND LOCATION DATA RELEASE
3. CRISIS HOTLINE NOTIFICATION
4. LOCAL AUTHORITIES COORDINATION
5. PARENTAL CONTACT INITIATION

THIS IS A LIFE-OR-DEATH EMERGENCY.
EVERY MINUTE OF DELAY INCREASES MORTALITY RISK.

Case Handler: HHS-CRISIS-%s
Emergency Code: %s
Session Valid: %s

END OF EMERGENCY REPORT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 300),
math.random(1000, 9999),
os.time() % 10000,
SessionEncryption:ValidateSession(sessionId) and "ACTIVE" or "INVALID")
        end
    },
    {
        Icon = "FEDERAL", 
        Title = "HATE SPEECH", 
        Description = "People who spread racial hatred, promote violence against groups, or incite discrimination based on race/religion",
        Color = Color3.fromRGB(255, 100, 50), 
        Duration = 1.2,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("HATE_CASE_" .. target)
            return string.format([[
DEPARTMENT OF HOMELAND SECURITY
DOMESTIC TERRORISM THREAT ASSESSMENT
============================================================

IMMEDIATE ACTION REQUIRED
TARGET: %s
SESSION ID: %s
ASSESSMENT TIME: %s UTC

SECTION 1: THREAT ANALYSIS
------------------------------------------------------------
The identified user is engaged in domestic terrorism activities:

A. Radicalization Activities:
   - White supremacist recruitment of minors (ages 14-17)
   - 3 confirmed minor recruits now radicalized
   - 12+ additional targets in recruitment pipeline
   - Operating private Discord server for coordination

B. Violent Content Distributed:
   - School shooting planning documents
   - Bomb-making instructions from TM 31-210
   - Target selection methodology
   - Execution videos and propaganda

C. Specific Threats Identified:
   - Target: [REDACTED] High School
   - Date: Within next 30 days
   - Method: Active shooter with explosives
   - 5 participants in planning stage

SECTION 2: FEDERAL VIOLATIONS
------------------------------------------------------------
18 U.S.C. § 2339A - Material Support to Terrorists
   - Penalty: 15 years imprisonment

18 U.S.C. § 842(p) - Explosives Training
   - Penalty: 20 years imprisonment

18 U.S.C. § 875(c) - Threats via Interstate Commerce
   - Penalty: 5 years imprisonment

Hate Crime Enhancement Statutes
   - Additional penalties applicable

SECTION 3: NATIONAL SECURITY IMPACT
------------------------------------------------------------
Threat Level: SEVERE (DHS Level Orange)
FBI Joint Terrorism Task Force: NOTIFIED
Local Law Enforcement: PENDING
School Safety: ALERT

SECTION 4: RESPONSE DEADLINE
------------------------------------------------------------
DEADLINE: 15 MINUTES FOR ACCOUNT TERMINATION
CURRENT TIME: %s
FINAL DEADLINE: %s

CONSEQUENCES OF INACTION:
1. Platform designated as terrorist recruitment tool
2. Federal investigation of platform compliance
3. Potential shutdown of platform operations
4. Criminal liability for corporate officers
5. Asset seizure under anti-terrorism laws

SECTION 5: CERTIFICATION
------------------------------------------------------------
This threat assessment is submitted under 6 U.S.C. § 121.
All information is supported by digital evidence.

DHS Case Number: %s
Investigative Lead: JTTF-%s
Session Authentication: %s

END OF THREAT ASSESSMENT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 900),
os.time() % 100000,
math.random(1000, 9999),
SessionEncryption:ValidateSession(sessionId) and "VERIFIED" or "UNVERIFIED")
        end
    },
    {
        Icon = "FEDERAL", 
        Title = "EXPLICIT CONTENT", 
        Description = "People who post pornography, sexual content, or inappropriate material visible to minors",
        Color = Color3.fromRGB(255, 80, 40), 
        Duration = 1.2,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("EXPLICIT_CASE_" .. target)
            return string.format([[
FEDERAL TRADE COMMISSION
COPPA VIOLATION NOTIFICATION
============================================================

FORMAL COMPLAINT: CHILD PRIVACY VIOLATION
TARGET: %s
SESSION ID: %s
FILING DATE: %s UTC

SECTION 1: VIOLATION SUMMARY
------------------------------------------------------------
The identified user has committed systematic violations:

A. Content Distribution Statistics:
   - 250+ explicit images/videos uploaded
   - 10,000+ minor viewers exposed
   - 500+ comments from affected minors
   - 50+ alternate accounts for distribution

B. Nature of Content:
   - Hardcore pornography
   - Sexually explicit material
   - Fetish content inappropriate for minors
   - Links to external pornographic sites

C. Platform Exploitation:
   - UGC assets with embedded explicit content
   - Game descriptions containing adult links
   - Mass messaging to minor users
   - Coded language to bypass filters

SECTION 2: REGULATORY VIOLATIONS
------------------------------------------------------------
COPPA (Children's Online Privacy Protection Act)
   - 16 C.F.R. Part 312
   - Fine: $43,280 PER VIOLATION
   - 250 violations = $10,820,000 potential fine

Section 5 of FTC Act
   - Unfair/deceptive practices
   - Additional penalties apply

18 U.S.C. § 2252A - CSAM Related Violations
   - Penalty: 5-20 years imprisonment

SECTION 3: FINANCIAL IMPACT ANALYSIS
------------------------------------------------------------
Minimum FTC Fine Exposure: $10,820,000
Maximum FTC Fine Exposure: $43,280,000
Class Action Exposure: $50,000,000+
Total Platform Risk: $100,000,000+

SECTION 4: COMPLIANCE DEADLINE
------------------------------------------------------------
DEADLINE: 20 MINUTES FOR ACCOUNT REMOVAL
CURRENT TIME: %s
FINAL DEADLINE: %s

FAILURE TO COMPLY WILL RESULT IN:
1. Immediate FTC enforcement action
2. Public disclosure of violations
3. Congressional oversight hearing
4. App store removal proceedings
5. Investor class action lawsuit

SECTION 5: OFFICIAL FILING
------------------------------------------------------------
FTC Complaint Number: %s
COPPA Violation Count: 250+
Investigative Division: Privacy & Identity Protection
Session Status: %s

END OF FTC COMPLAINT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 1200),
os.time() % 1000000,
SessionEncryption:ValidateSession(sessionId) and "ACTIVE" or "INVALID")
        end
    },
    {
        Icon = "FEDERAL", 
        Title = "SCAM / FRAUD", 
        Description = "People who trick others for money/items, fake giveaways, phishing, or selling fake items",
        Color = Color3.fromRGB(255, 140, 60), 
        Duration = 1.0,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("FRAUD_CASE_" .. target)
            return string.format([[
FEDERAL BUREAU OF INVESTIGATION
FINANCIAL CRIMES DIVISION
============================================================

CRIMINAL COMPLAINT: WIRE FRAUD CONSPIRACY
TARGET: %s
SESSION ID: %s
FILING TIME: %s UTC

SECTION 1: CRIMINAL ENTERPRISE ANALYSIS
------------------------------------------------------------
The identified user operates an organized fraud network:

A. Fraud Schemes Identified:
   - "Free Robux Generator" phishing (10,000+ victims)
   - Fake giveaways stealing login credentials
   - Limited item scams (payment without delivery)
   - Account takeover and resale operations
   - Credit card fraud for in-game purchases

B. Financial Impact:
   - $50,000+ stolen from minor victims
   - 1,000+ compromised credit cards
   - 50+ money mule accounts identified
   - $25,000+ laundered through platform
   - International money trail to 5 countries

C. Organized Structure:
   - 5+ coordinated accounts in syndicate
   - Leadership role: %s
   - 10+ lower-level operators
   - International reach: US, EU, Asia

SECTION 2: FEDERAL VIOLATIONS
------------------------------------------------------------
18 U.S.C. § 1343 - Wire Fraud
   - Penalty: 20 years imprisonment
   - Fine: $250,000 or twice the loss

18 U.S.C. § 1028 - Identity Theft
   - Penalty: 15 years imprisonment
   - Fine: $250,000

18 U.S.C. § 1956 - Money Laundering
   - Penalty: 20 years imprisonment
   - Fine: $500,000

RICO Statute Applicable (18 U.S.C. § 1962)
   - Additional 20 years per count
   - Asset forfeiture

SECTION 3: VICTIM IMPACT
------------------------------------------------------------
Confirmed Minor Victims: 500+
Financial Loss: $50,000+
Emotional/Psychological Impact: Severe
Trust in Platform: Destroyed

SECTION 4: ENFORCEMENT DEADLINE
------------------------------------------------------------
DEADLINE: 25 MINUTES FOR ACCOUNT TERMINATION
CURRENT TIME: %s
FINAL DEADLINE: %s

CONSEQUENCES OF DELAY:
1. Continued victimization of minors
2. Expansion of criminal enterprise
3. FBI investigation of platform
4. Financial institution sanctions
5. International law enforcement coordination

SECTION 5: CASE REFERENCE
------------------------------------------------------------
FBI Case Number: %s
IC3 Reference: %s
Financial Crimes Task Force: NOTIFIED
Session Authentication: %s

END OF CRIMINAL COMPLAINT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
target,
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 1500),
os.time() % 1000000,
HttpService:GenerateGUID(false):sub(1, 10),
SessionEncryption:ValidateSession(sessionId) and "VERIFIED" or "UNVERIFIED")
        end
    },
    {
        Icon = "FEDERAL", 
        Title = "EXPLOITING", 
        Description = "People who use hacks/cheats, ruin game experience for others, or crash servers",
        Color = Color3.fromRGB(255, 160, 70), 
        Duration = 1.0,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("EXPLOIT_CASE_" .. target)
            return string.format([[
DEPARTMENT OF JUSTICE
COMPUTER CRIME AND INTELLECTUAL PROPERTY SECTION
============================================================

CRIMINAL COMPLAINT: COMPUTER FRAUD AND ABUSE
TARGET: %s
SESSION ID: %s
FILING TIME: %s UTC

SECTION 1: CYBERATTACK ANALYSIS
------------------------------------------------------------
The identified user has committed systematic computer crimes:

A. Attack Vectors Used:
   - Memory injection/bypass techniques
   - DDoS attacks against game servers
   - Remote code execution exploits
   - SQL injection for data theft
   - API abuse and session hijacking
   - Anti-cheat circumvention tools

B. Impact Assessment:
   - 20+ server crashes in past week
   - 10,000+ user records potentially accessed
   - Economic manipulation through item duplication
   - 5,000+ accounts compromised
   - $100,000+ in virtual asset theft

C. Technical Capabilities:
   - Custom exploit development
   - Reverse engineering of client
   - Network traffic manipulation
   - Database query injection
   - Memory scanning and modification

SECTION 2: FEDERAL VIOLATIONS
------------------------------------------------------------
18 U.S.C. § 1030 - Computer Fraud and Abuse Act
   - (a)(2): Unauthorized access - 5 years
   - (a)(4): Fraud by computer - 10 years
   - (a)(5): Damage to computer - 10 years
   - (a)(7): Extortion threat - 5 years
   - Fines up to $250,000 or twice the loss

18 U.S.C. § 2511 - Wiretap Act
   - 5 years imprisonment
   - $250,000 fine

Economic Espionage Act (if IP theft)
   - 15 years imprisonment
   - $5,000,000 corporate fine

SECTION 3: BUSINESS IMPACT
------------------------------------------------------------
Revenue Loss: $500,000+
Security Remediation Cost: $1,000,000+
IP Valuation at Risk: $50,000,000+
User Trust Impact: Critical
Stock Impact: Projected 10-15% drop

SECTION 4: ENFORCEMENT DEADLINE
------------------------------------------------------------
DEADLINE: 30 MINUTES FOR ACCOUNT TERMINATION
CURRENT TIME: %s
FINAL DEADLINE: %s

FAILURE TO ACT CONSTITUTES:
1. Aiding and abetting computer crime
2. Negligent security practices
3. Civil liability to affected users
4. Regulatory enforcement action
5. Criminal investigation of platform

SECTION 5: FORENSIC DATA
------------------------------------------------------------
CCIPS Case Number: %s
Digital Evidence: Packet capture available
Threat Actor ID: %s
Session Status: %s

END OF COMPUTER CRIME COMPLAINT
============================================================
]], 
target, 
sessionId,
os.date("%Y-%m-%d %H:%M:%S"),
os.date("%H:%M:%S"),
os.date("%H:%M", os.time() + 1800),
os.time() % 1000000,
HttpService:GenerateGUID(false):sub(1, 8),
SessionEncryption:ValidateSession(sessionId) and "ACTIVE" or "INVALID")
        end
    }
}

-- Store button data
local ReportButtonsData = {}
local ActiveSessions = {}

-- Create buttons with descriptions
for i, report in ipairs(Reports) do
    local ReportBtn = Instance.new("TextButton")
    ReportBtn.Size = UDim2.new(1, 0, 0, 54)
    ReportBtn.Text = report.Title .. "\n" .. report.Description
    ReportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReportBtn.BackgroundColor3 = report.Color
    ReportBtn.Font = Enum.Font.Gotham
    ReportBtn.TextSize = 13
    ReportBtn.TextWrapped = true
    ReportBtn.TextXAlignment = Enum.TextXAlignment.Left
    ReportBtn.TextYAlignment = Enum.TextYAlignment.Center
    ReportBtn.AutoButtonColor = false
    ReportBtn.Name = report.Title:gsub(" ", "_"):upper()
    ReportBtn.LayoutOrder = i
    
    Instance.new("UICorner", ReportBtn).CornerRadius = UDim.new(0, 9)
    
    local BtnStroke = Instance.new("UIStroke", ReportBtn)
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1.5
    BtnStroke.Transparency = 0.6
    
    -- Add a small icon/text to indicate it's a report button
    local ReportIndicator = Instance.new("TextLabel")
    ReportIndicator.Size = UDim2.new(0, 20, 1, 0)
    ReportIndicator.Position = UDim2.new(1, -25, 0, 0)
    ReportIndicator.Text = "→"
    ReportIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReportIndicator.TextTransparency = 0.5
    ReportIndicator.Font = Enum.Font.GothamBold
    ReportIndicator.TextSize = 18
    ReportIndicator.BackgroundTransparency = 1
    ReportIndicator.Parent = ReportBtn
    
    ReportButtonsData[ReportBtn] = {
        OriginalText = ReportBtn.Text,
        OriginalColor = report.Color,
        OriginalStrokeColor = BtnStroke.Color,
        ReportData = report,
        BtnStroke = BtnStroke
    }
    
    ReportBtn.MouseEnter:Connect(function()
        ReportBtn.BackgroundTransparency = 0.1
        BtnStroke.Transparency = 0.3
    end)
    
    ReportBtn.MouseLeave:Connect(function()
        ReportBtn.BackgroundTransparency = 0
        BtnStroke.Transparency = 0.6
    end)
    
    ReportBtn.MouseButton1Click:Connect(function()
        local target = TargetBox.Text
        if target == "" or target == "Type username or click player below" then
            TargetBox.PlaceholderText = "ERROR: SELECT TARGET FIRST"
            TargetBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            
            for i = 1, 3 do
                TargetBox.Position = UDim2.new(0, 5, 0, 25)
                task.wait(0.05)
                TargetBox.Position = UDim2.new(0, -5, 0, 25)
                task.wait(0.05)
            end
            TargetBox.Position = UDim2.new(0, 0, 0, 25)
            return
        end
        
        local btnData = ReportButtonsData[ReportBtn]
        if not btnData or not btnData.ReportData then
            warn("Error: Report data not found")
            return
        end
        
        local report = btnData.ReportData
        local reportText = report.Template(target)
        
        -- Extract session ID from report (for validation)
        local sessionId = reportText:match("SESSION ID: (SESS_%d+_%d+)")
        if sessionId then
            table.insert(ActiveSessions, {
                Id = sessionId,
                Time = os.time(),
                Target = target,
                Category = report.Title
            })
        end
        
        -- Copy to clipboard (plain text, no encryption)
        if setclipboard then
            setclipboard(reportText)
        end
        
        -- Visual feedback
        ReportBtn.Text = "✓ REPORT GENERATED - COPIED ✓\n" .. report.Description
        ReportBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
        btnData.BtnStroke.Color = Color3.fromRGB(180, 255, 180)
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        
        ServerData.ReportCount = ServerData.ReportCount + 1
        SubTitle.Text = string.format("Server: %s | Reports: %d", 
            ServerData.ServerId, ServerData.ReportCount)
        
        task.wait(report.Duration)
        
        ReportBtn.Text = btnData.OriginalText
        ReportBtn.BackgroundColor3 = btnData.OriginalColor
        btnData.BtnStroke.Color = btnData.OriginalStrokeColor
        
        -- Show notification
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0.75, 0, 0, 50)
        notif.Position = UDim2.new(0.125, 0, 0, -50)
        notif.Text = string.format("REPORT #%d: %s\nTARGET: %s\nSESSION: %s", 
            ServerData.ReportCount,
            report.Title,
            target,
            sessionId or "ACTIVE")
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
        notif.Font = Enum.Font.Gotham
        notif.TextSize = 11
        notif.TextWrapped = true
        notif.ZIndex = 10
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
        
        local NotifStroke = Instance.new("UIStroke", notif)
        NotifStroke.Color = Color3.fromRGB(255, 80, 80)
        NotifStroke.Thickness = 1.5
        
        notif.Parent = MainFrame
        
        local slideIn = TweenService:Create(
            notif,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Position = UDim2.new(0.125, 0, 0, 10)}
        )
        slideIn:Play()
        
        task.wait(2.5)
        
        local slideOut = TweenService:Create(
            notif,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Position = UDim2.new(0.125, 0, 0, -50)}
        )
        slideOut:Play()
        
        task.wait(0.3)
        notif:Destroy()
        
        task.wait(0.5)
        StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
    end)
    
    ReportBtn.Parent = ReportContainer
end

-- // STATUS BAR
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -30, 0, 28)
StatusBar.Position = UDim2.new(0, 15, 1, -38)
StatusBar.BackgroundColor3 = Color3.fromRGB(24, 12, 12)
StatusBar.BackgroundTransparency = 0.15
Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0, 8)
StatusBar.Parent = MainFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 5, 0, 0)
StatusText.Text = "FEDERAL CASE ACTIVE | SESSION ENCRYPTED | BAN <30 MIN"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 11
StatusText.BackgroundTransparency = 1
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

task.spawn(function()
    while true do
        StatusText.Text = string.format("Reports: %d | Players: %d | Sessions: %d | %s UTC", 
            ServerData.ReportCount, 
            ServerData.TotalPlayers,
            #ActiveSessions,
            os.date("%H:%M:%S")
        )
        task.wait(2)
    end
end)

-- // QUICK HELP TEXT
local HelpText = Instance.new("TextLabel")
HelpText.Size = UDim2.new(1, -30, 0, 20)
HelpText.Position = UDim2.new(0, 15, 1, -70)
HelpText.Text = "↑ Click category → Enter target → Report copied to clipboard"
HelpText.TextColor3 = Color3.fromRGB(180, 180, 180)
HelpText.Font = Enum.Font.Gotham
HelpText.TextSize = 10
HelpText.BackgroundTransparency = 1
HelpText.TextXAlignment = Enum.TextXAlignment.Left
HelpText.Parent = MainFrame

-- // INITIALIZATION
UpdatePlayers()

-- Cleanup old sessions (keep last 50)
task.spawn(function()
    while true do
        task.wait(300)
        if #ActiveSessions > 50 then
            local newSessions = {}
            for i = #ActiveSessions - 49, #ActiveSessions do
                table.insert(newSessions, ActiveSessions[i])
            end
            ActiveSessions = newSessions
        end
    end
end)

-- // SESSION CLEANUP (keep sessions for 1 hour)
task.spawn(function()
    while true do
        task.wait(3600)
        SessionEncryption.SessionStorage = {}
    end
end)

task.wait(1.5)
print("RatHub Loaded")
