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
        "⚠️ FEDERAL CASE #" .. math.random(1000,9999) .. " - ACTIVE ⚠️",
        "🔴 DIRECT FBI NOTIFICATION - PRIORITY 1",
        "⚡ DEADLINE: 15 MINUTES FOR ACCOUNT TERMINATION",
        "📋 DIGITAL FORENSICS INCLUDED - EVIDENCE HASHED",
        "🚨 MULTI-AGENCY COORDINATION: FBI, DHS, INTERPOL"
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
TargetLabel.Text = "🎯 TARGET SELECTION:"
TargetLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 14
TargetLabel.BackgroundTransparency = 1
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = TargetSection

local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(1, 0, 0, 36)
TargetBox.Position = UDim2.new(0, 0, 0, 25)
TargetBox.PlaceholderText = "Enter username to report..."
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
ReportLabel.Text = "⚡ FEDERAL REPORT CATEGORIES:"
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

-- // ENHANCED FEDERAL REPORT TEMPLATES - MORE AGGRESSIVE AND DETAILED
local Reports = {
    {
        Icon = "🔴", 
        Title = "CHILD PREDATOR / GROOMING", 
        Description = "Sexual exploitation of minors, CSAM distribution, grooming behavior",
        Color = Color3.fromRGB(255, 20, 20), 
        Duration = 2.0,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("PREDATOR_CASE_" .. target)
            local caseNumber = "FBI-" .. os.date("%y") .. "-" .. math.random(100000, 999999)
            local victimCount = math.random(12, 27)
            local evidenceHash = HttpService:GenerateGUID(false):upper()
            return string.format([[
================================================================================
                            URGENT - PRIORITY 1
                 FEDERAL BUREAU OF INVESTIGATION (FBI)
                 CYBER CRIMES DIVISION - IC3 REFERRAL
================================================================================

CASE NUMBER: %s
SESSION ID: %s
TIMESTAMP: %s UTC
REPORTING PLATFORM: Roblox (Game ID: %s)
TARGET USERNAME: %s
TARGET USER ID: [PENDING PLATFORM VERIFICATION]
INVESTIGATION STATUS: ACTIVE - PRIORITY 1

================================================================================
                          SECTION 1: EXECUTIVE SUMMARY
================================================================================

The subject identified above (%s) is believed to be actively engaged in 
CHILD SEXUAL EXPLOITATION and GROOMING of minors through the Roblox platform. 
This constitutes FEDERAL FELONIES under United States Code Title 18.

Based on observed behavior and digital evidence collected, this individual 
poses an IMMEDIATE THREAT to child safety on this platform and potentially 
in physical communities.

================================================================================
                    SECTION 2: DETAILED CRIMINAL ACTIVITIES
================================================================================

A. SOLICITATION OF MINORS (Ages 8-14):
   • Repeatedly requesting explicit photographs from underage users
   • Offering virtual currency (Robux) and limited items in exchange for sexual content
   • Asking minors to move conversations to Discord, Snapchat, and Instagram
   • Requesting personal information including address, school name, and photos

B. CSAM DISTRIBUTION CONCERNS:
   • Sharing suspicious external links through private messages
   • References to "special photos" and "secret games"
   • Pattern consistent with CSAM network recruitment
   • %d+ suspected instances of inappropriate content sharing

C. GROOMING BEHAVIOR PATTERN:
   • Building false trust with victims through fake persona
   • Isolating victims from friends/family in-game
   • Introducing sexual topics gradually (desensitization)
   • Requesting secret-keeping from parents
   • Discussing meeting in person with multiple victims

D. IDENTIFIED VICTIMS:
   • %d confirmed minor victims (ages 9-14)
   • %d additional potential victims under investigation
   • Victims located across multiple jurisdictions
   • Active grooming occurring within LAST 24 HOURS

================================================================================
                         SECTION 3: FEDERAL VIOLATIONS
================================================================================

The following federal statutes have been violated:

┌──────────────────────────────────────────────────────────────────────────────┐
│ 18 U.S.C. § 2251 - SEXUAL EXPLOITATION OF CHILDREN                           │
│ • Penalty: 15-30 YEARS imprisonment per count                                │
│ • Fine: Up to $250,000                                                        │
│ • Maximum: LIFE IMPRISONMENT if victim under 14                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2252 - CSAM DISTRIBUTION                                         │
│ • Penalty: 5-20 YEARS imprisonment                                           │
│ • Fine: Up to $250,000                                                        │
│ • Enhanced penalties for prior convictions                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2422(b) - COERCION/ENTICEMENT OF MINOR                           │
│ • Penalty: 10 YEARS TO LIFE imprisonment                                     │
│ • Fine: Up to $250,000                                                        │
│ • Mandatory restitution to victims                                           │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 1470 - TRANSFER OF OBSCENE MATERIAL TO MINOR                     │
│ • Penalty: 10 YEARS imprisonment                                             │
│ • Fine: Up to $250,000                                                        │
├──────────────────────────────────────────────────────────────────────────────┤
│ 34 U.S.C. § 20341 - SEX OFFENDER REGISTRATION FAILURE (if applicable)        │
│ • Penalty: 10 YEARS imprisonment                                             │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                     SECTION 4: DIGITAL FORENSICS & EVIDENCE
================================================================================

EVIDENCE PACKAGE FORENSIC HASH: %s
CHAIN OF CUSTODY ID: COC-%s
EVIDENCE INTEGRITY: VERIFIED (SHA-256)

Digital evidence collected includes:
✓ Screenshots of inappropriate conversations (15+ instances)
✓ Chat logs with sexualized content (40+ messages)
✓ Evidence of grooming behavior pattern
✓ External link analysis (suspected CSAM distribution)
✓ Victim statements and identifications
✓ IP connection logs and timestamps
✓ Associated alt account analysis

FORENSIC ANALYSIS CONFIRMS:
• No evidence of tampering - chain of custody maintained
• Metadata consistent with reported timeline
• Digital footprint complete and verifiable
• Evidence package available for immediate transfer to law enforcement

================================================================================
              SECTION 5: IMMEDIATE ACTION REQUIRED & DEADLINE
================================================================================

DEADLINE: 15 MINUTES FROM REPORT TIMESTAMP

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 15 MINUTES

The platform MUST take the following actions IMMEDIATELY:

┌──────────────────────────────────────────────────────────────────────────────┐
│ REQUIRED ACTIONS:                                                            │
│ 1. IMMEDIATE ACCOUNT SUSPENSION (WITHIN 5 MINUTES)                          │
│ 2. PRESERVE ALL ACCOUNT DATA AND CHAT LOGS                                   │
│ 3. DISABLE ACCOUNT'S ABILITY TO COMMUNICATE WITH MINORS                     │
│ 4. FLAG ACCOUNT FOR LAW ENFORCEMENT REQUEST                                  │
│ 5. PREPARE USER DATA PACKAGE (IP, EMAIL, PAYMENT HISTORY)                   │
│ 6. NOTIFY PLATFORM SAFETY TEAM FOR EMERGENCY REVIEW                         │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
            SECTION 6: CONSEQUENCES OF NON-COMPLIANCE / DELAY
================================================================================

FAILURE TO TERMINATE THIS ACCOUNT WITHIN THE 15-MINUTE DEADLINE WILL RESULT IN:

1. IMMEDIATE REFERRAL TO IC3 (Internet Crime Complaint Center) - CASE #%s
2. NOTIFICATION TO NCMEC (National Center for Missing & Exploited Children)
3. FBI CYBER DIVISION ALERT - PRIORITY FLAG
4. INTERPOL CYBERCRIME COORDINATION (if international)
5. HOMELAND SECURITY INVESTIGATIONS (HSI) REFERRAL
6. FEDERAL SUBPOENA FOR ALL PLATFORM USER DATA AND LOGS
7. CRIMINAL INVESTIGATION OF PLATFORM COMPLIANCE OFFICERS
8. CLASS ACTION LAWSUIT ON BEHALF OF ALL IDENTIFIED VICTIMS
9. DOJ INVESTIGATION FOR AIDING AND ABETTING CHILD EXPLOITATION
10. POTENTIAL PLATFORM SHUTDOWN UNDER 18 U.S.C. § 2252A

The PLATFORM and its OFFICERS may face CRIMINAL LIABILITY for:
• Aiding and abetting child exploitation (18 U.S.C. § 2)
• Obstruction of justice (18 U.S.C. § 1505)
• Misprision of felony (18 U.S.C. § 4)
• Criminal negligence resulting in harm to minors

================================================================================
                        SECTION 7: LEGAL CERTIFICATION
================================================================================

I, the reporting party, hereby CERTIFY under penalty of perjury (18 U.S.C. § 1621) 
that the information contained in this report is true, accurate, and complete to 
the best of my knowledge and belief.

This report constitutes a FORMAL CRIMINAL COMPLAINT under:
• Federal Rules of Criminal Procedure Rule 3
• 18 U.S.C. § 3041 (Complaint upon probable cause)
• 28 C.F.R. § 0.85 (FBI jurisdiction)

False reporting is punishable under 18 U.S.C. § 1001 (up to 8 years imprisonment).

================================================================================
                        SECTION 8: OFFICIAL CASE REFERENCE
================================================================================

INVESTIGATOR ID: FBI-CYBER-%s
IC3 REFERRAL: %s
NCMEC CYBERTIP: %s
DOJ TRACKING: %s
SESSION AUTHENTICATION: %s
EVIDENCE LOCKED: %s

This case has been logged in the following systems:
✓ FBI Sentinel (Case Management System)
✓ IC3 Database (Internet Crime Complaint Center)
✓ NCMEC CyberTipline
✓ DHS/HSI Case Tracking
✓ INTERPOL I-24/7 (if international)

================================================================================
                            END OF FEDERAL COMPLAINT
================================================================================
]], 
            caseNumber,
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            ServerData.ServerId,
            target,
            target,
            victimCount,
            victimCount - 3,
            victimCount + 5,
            evidenceHash,
            os.date("%y%m%d") .. math.random(10000, 99999),
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 900),
            "IC3-" .. os.date("%y") .. math.random(1000000, 9999999),
            math.random(10000, 99999),
            "IC3-" .. os.date("%y%m%d") .. math.random(100000, 999999),
            "TIP-" .. os.date("%j") .. math.random(10000, 99999),
            "DOJ-" .. os.date("%y") .. math.random(1000000, 9999999),
            SessionEncryption:ValidateSession(sessionId) and "VERIFIED - ACTIVE" or "CRITICAL - AUTHENTICATION REQUIRED",
            evidenceHash:sub(1, 16))
        end
    },
    {
        Icon = "🆘", 
        Title = "SUICIDE / SELF-HARM INCITER", 
        Description = "Encouraging suicide, self-harm methods, suicide pacts",
        Color = Color3.fromRGB(200, 0, 0), 
        Duration = 2.0,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("SUICIDE_CASE_" .. target)
            return string.format([[
================================================================================
                         MEDICAL EMERGENCY - PRIORITY 1
                    DEPARTMENT OF HEALTH AND HUMAN SERVICES
                SUBSTANCE ABUSE AND MENTAL HEALTH SERVICES (SAMHSA)
                          CRISIS INTERVENTION UNIT
================================================================================

EMERGENCY CASE NUMBER: HHS-CRISIS-%s
SESSION ID: %s
ALERT TIME: %s UTC
PLATFORM: Roblox (Server: %s)
TARGET USER: %s
THREAT LEVEL: CRITICAL - ACTIVE LIFE SAFETY DANGER

⚠️⚠️⚠️ THIS IS A LIFE-OR-DEATH EMERGENCY ⚠️⚠️⚠️

================================================================================
                   SECTION 1: CRITICAL THREAT ASSESSMENT
================================================================================

The identified user (%s) is actively engaged in ORGANIZING SUICIDE PACT(S)
and INCITING SELF-HARM among MINOR users. This is an EXTREME IMMEDIATE THREAT
requiring URGENT INTERVENTION.

CONFIRMED ACTIVITIES:

A. ORGANIZED SUICIDE PACT:
   • Coordinating group suicide involving %d MINORS (ages 13-16)
   • Scheduled date/time: [WITHIN 72 HOURS]
   • Specific method discussed and agreed upon
   • Communication occurring across multiple platforms
   • Pact participants identified and contacted for verification

B. PROVISION OF SELF-HARM METHODS:
   • Detailed instructions on suicide methods provided
   • "Suicide manuals" and instructional content distributed
   • Specific information on lethal doses and methods
   • Bypassed platform filters using coded language
   • Encouraged "painless methods" to vulnerable minors

C. TARGETING VULNERABLE POPULATIONS:
   • Specifically targeting minors with depression/anxiety
   • Searching for and approaching users expressing suicidal thoughts
   • Presenting suicide as "solution" to problems
   • Discouraging professional help or crisis intervention
   • Isolating victims from support systems

D. CURRENT VICTIM STATUS:
   • %d minors HOSPITALIZED following instructions
   • %d minors with ACTIVE SUICIDE NOTES prepared
   • %d minors in CRISIS with immediate intervention needed
   • %d additional minors under observation
   • 1 minor in ICU (CRITICAL CONDITION) - family notified

================================================================================
                 SECTION 2: COMMUNICATION LOG ANALYSIS
================================================================================

RECOVERED COMMUNICATIONS INDICATE:

"Let's do it together, we can end the pain"
"Here's how to do it safely so it doesn't hurt"
"Don't tell anyone, they won't understand"
"Meet here at midnight to say goodbye"
"I found a way that always works"
"Don't call those hotlines, they just want to stop us"

CODED LANGUAGE DETECTED:
• "Game over" - suicide
• "Sleep forever" - death
• "Exit game" - suicide method
• "Secret code" - self-harm instructions

================================================================================
                       SECTION 3: CRIMINAL VIOLATIONS
================================================================================

These actions constitute FEDERAL CRIMES with SEVERE penalties:

┌──────────────────────────────────────────────────────────────────────────────┐
│ 18 U.S.C. § 875(c) - INTERSTATE COMMUNICATIONS THREATS                       │
│ • Penalty: Up to 5 YEARS imprisonment per count                              │
│ • Applicable: 50+ threats communicated                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2261A - STALKING (if targeting specific minors)                  │
│ • Penalty: 5 YEARS to LIFE if death results                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│ INVOLUNTARY MANSLAUGHTER (if deaths occur)                                   │
│ • Penalty: Up to 10 YEARS imprisonment                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│ CRIMINAL ENDANGERMENT OF MINORS                                              │
│ • Penalty: Up to 5 YEARS PER COUNT (per minor endangered)                    │
│ • Applicable: %d+ counts                                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│ AIDING/ABETTING SUICIDE (many states)                                        │
│ • Penalty: 2-10 YEARS imprisonment                                           │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                       SECTION 4: MEDICAL EMERGENCY STATUS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ THREAT LEVEL:          CRITICAL - Active Life Danger                        │
│ RESPONSE WINDOW:       MINUTES, NOT HOURS                                   │
│ IMMEDIATE RISK:        %d minors in ACTIVE DANGER                           │
│ MEDICAL INTERVENTION:  CRISIS TEAMS MOBILIZED                               │
│ PARENTAL NOTIFICATION: IN PROGRESS - SOME ALREADY NOTIFIED                  │
│ LOCAL AUTHORITIES:     ALERTED - WAITING FOR PLATFORM DATA                  │
│ SUICIDE HOTLINES:      ACTIVATED                                            │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                    SECTION 5: EMERGENCY RESPONSE DEADLINE
================================================================================

DEADLINE: 5 MINUTES - LIVES DEPEND ON IMMEDIATE ACTION

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 5 MINUTES

⚠️ EVERY MINUTE OF DELAY INCREASES MORTALITY RISK ⚠️

================================================================================
            SECTION 6: URGENT PLATFORM REQUIREMENTS - ACT NOW
================================================================================

The platform MUST take the following actions IMMEDIATELY:

┌──────────────────────────────────────────────────────────────────────────────┐
│ 1. ACCOUNT TERMINATION - WITHIN 2 MINUTES                                   │
│ 2. IP ADDRESS AND LOCATION DATA RELEASE - IMMEDIATE                         │
│ 3. CRISIS HOTLINE NOTIFICATION - COMPLETED                                   │
│ 4. LOCAL AUTHORITIES COORDINATION - PENDING                                  │
│ 5. PARENTAL CONTACT INITIATION - URGENT                                     │
│ 6. PRESERVE ALL CHAT LOGS AND COMMUNICATIONS                                │
│ 7. IDENTIFY ALL CONTACTED MINORS - PROVIDE LIST                             │
│ 8. LOCK ACCOUNT TO PREVENT EVIDENCE DESTRUCTION                             │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                SECTION 7: CONSEQUENCES OF DELAY / INACTION
================================================================================

FAILURE TO ACT IMMEDIATELY WILL CONSTITUTE:

1. CRIMINAL NEGLIGENCE resulting in DEATHS
2. AIDING AND ABETTING SUICIDE (18 U.S.C. § 2)
3. CIVIL LIABILITY for WRONGFUL DEATHS
4. FEDERAL INVESTIGATION of platform compliance
5. CORPORATE OFFICER CRIMINAL CHARGES
6. ASSET FREEZE pending investigation
7. PLATFORM SHUTDOWN under emergency order

IF DEATHS OCCUR DUE TO DELAY:
• HOMICIDE INVESTIGATION will be opened
• CORPORATE OFFICERS may face MANSLAUGHTER charges
• CRIMINAL NEGLIGENCE prosecution guaranteed
• BILLIONS in civil liability

================================================================================
                         SECTION 8: CERTIFICATION
================================================================================

This EMERGENCY REPORT is filed under:
• 42 U.S.C. § 290aa (SAMHSA authority)
• 34 U.S.C. § 20341 (victim protection)
• Public Health Service Act § 501

ALL INFORMATION IS VERIFIED AND ACCURATE.
FALSE REPORTING IS A FEDERAL CRIME (18 U.S.C. § 1001).

================================================================================
                         SECTION 9: CASE REFERENCE
================================================================================

CRISIS TEAM LEADER: HHS-CRISIS-%s
EMERGENCY CODE: %s
HOTLINE REFERRAL: %s
LOCAL AUTHORITIES: NOTIFIED - CASE #%s
SESSION VALIDATION: %s

NOTIFICATIONS SENT TO:
✓ SAMHSA Crisis Center
✓ National Suicide Prevention Lifeline
✓ Crisis Text Line
✓ Local Emergency Services (jurisdiction pending)
✓ FBI Behavioral Analysis Unit (on standby)

================================================================================
                    THIS IS A LIFE-OR-DEATH EMERGENCY
                       EVERY SECOND COUNTS
================================================================================
]], 
            os.time() % 1000000,
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            ServerData.ServerId,
            target,
            target,
            math.random(6, 12),
            math.random(2, 4),
            math.random(3, 6),
            math.random(4, 7),
            math.random(5, 10),
            math.random(8, 15),
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 300),
            math.random(1000, 9999),
            "CODE-" .. os.date("%j") .. math.random(100, 999),
            "HL-" .. math.random(100000, 999999),
            "LE" .. math.random(10000, 99999),
            SessionEncryption:ValidateSession(sessionId) and "VERIFIED - ACTIVE" or "PRIORITY - VERIFY IMMEDIATELY")
        end
    },
    {
        Icon = "💀", 
        Title = "HATE SPEECH / TERRORISM", 
        Description = "Racial hatred, violence incitement, domestic terrorism",
        Color = Color3.fromRGB(255, 70, 30), 
        Duration = 1.8,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("HATE_CASE_" .. target)
            return string.format([[
================================================================================
                         DEPARTMENT OF HOMELAND SECURITY
                     OFFICE OF INTELLIGENCE & ANALYSIS (I&A)
                   JOINT TERRORISM TASK FORCE (JTTF) REFERRAL
================================================================================

DHS CASE NUMBER: %s
JTTF REFERRAL ID: JTTF-%s-%s
SESSION ID: %s
TIMESTAMP: %s UTC
CLASSIFICATION: UNCLASSIFIED//FOR OFFICIAL USE ONLY
PRIORITY: URGENT - DOMESTIC TERRORISM THREAT

TARGET USERNAME: %s
PLATFORM: Roblox (Server ID: %s)
THREAT LEVEL: SEVERE (DHS Level Orange - High Risk)

================================================================================
                     SECTION 1: THREAT ASSESSMENT SUMMARY
================================================================================

The identified subject (%s) is engaged in DOMESTIC TERRORISM ACTIVITIES
including RADICALIZATION of MINORS, DISTRIBUTION of VIOLENT EXTREMIST MATERIAL,
and PLANNING of TARGETED VIOLENCE. This constitutes a DIRECT THREAT to
public safety and NATIONAL SECURITY.

================================================================================
               SECTION 2: DETAILED THREAT ACTIVITY ANALYSIS
================================================================================

A. RADICALIZATION OF MINORS:
   • White supremacist/nationalist ideology promotion
   • Targeted recruitment of minors (ages 14-17)
   • %d confirmed minor recruits now RADICALIZED
   • %d additional minors in recruitment pipeline
   • Operating coordinated recruitment across multiple games
   • Using coded language to evade detection
   • Private Discord server with %d+ members for coordination

B. VIOLENT EXTREMIST CONTENT DISTRIBUTED:
   • School shooting planning documents ("how-to" guides)
   • Bomb-making instructions from TM 31-210 (Improvised Munitions Handbook)
   • Target selection methodology and vulnerability assessment
   • Execution videos and propaganda material
   • Manifestos of past mass shooters
   • Recruitment materials adapted for minors
   • Weapons training and tactical guides

C. IDENTIFIED THREAT PLANNING:
   • TARGET: [REDACTED] Educational Institution
   • PLANNED DATE: Within next 30-45 days
   • METHOD: Active shooter with explosive devices
   • PARTICIPANTS: %d identified individuals in planning stage
   • RECONNAISSANCE: Target reportedly cased/reviewed
   • COMMUNICATIONS: Encrypted, partially recovered
   • WEAPONS: Discussions of acquisition methods

D. EXTRACTION OF RECOVERED COMMUNICATIONS:
   "The time is coming, we need to be ready"
   "Study the manuals, know the layout"
   "They won't see it coming"
   "Recruit young, they're easier to mold"
   "The system needs to fall"
   "Target selection is critical for maximum impact"

================================================================================
                      SECTION 3: FEDERAL VIOLATIONS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ 18 U.S.C. § 2339A - MATERIAL SUPPORT TO TERRORISTS                          │
│ • Penalty: 15 YEARS imprisonment                                            │
│ • Enhanced: 20 YEARS if death results                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 842(p) - EXPLOSIVES TRAINING                                    │
│ • Penalty: 20 YEARS imprisonment                                            │
│ • Fine: $250,000                                                            │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 875(c) - THREATS VIA INTERSTATE COMMERCE                        │
│ • Penalty: 5 YEARS imprisonment                                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2332b - ACTS OF TERRORISM TRANSCENDING NATIONAL BOUNDARIES      │
│ • Penalty: LIFE IMPRISONMENT if death results                               │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2383 - REBELLION OR INSURRECTION                                │
│ • Penalty: 10 YEARS, disqualified from office                               │
├──────────────────────────────────────────────────────────────────────────────┤
│ HATE CRIME ENHANCEMENT STATUTES (Shepard-Byrd Act)                          │
│ • Additional penalties applicable                                           │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                        SECTION 4: THREAT MATRIX
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ THREAT DIMENSION           │ ASSESSMENT              │ CONFIDENCE           │
├──────────────────────────────────────────────────────────────────────────────┤
│ CAPABILITY                 │ MODERATE-HIGH           │ HIGH                 │
│ INTENT                     │ HIGH                     │ HIGH                │
│ PLANNING                   │ ACTIVE                   │ CONFIRMED           │
│ TARGETING                  │ SPECIFIC                 │ HIGH                │
│ TIMELINE                   │ 30-45 DAYS               │ MODERATE            │
│ RADICALIZATION SUCCESS     │ %d RECRUITS              │ CONFIRMED           │
│ EXTERNAL SUPPORT           │ POSSIBLE                 │ LOW-MODERATE        │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                      SECTION 5: NATIONAL SECURITY IMPACT
================================================================================

AGENCIES NOTIFIED:
┌──────────────────────────────────────────────────────────────────────────────┐
│ ✓ FBI JOINT TERRORISM TASK FORCE - ACTIVE CASE                              │
│ ✓ DHS OFFICE OF INTELLIGENCE & ANALYSIS                                     │
│ ✓ NATIONAL TERRORISM CENTER (NCTC)                                          │
│ ✓ BUREAU OF ALCOHOL, TOBACCO, FIREARMS (ATF) - explosives concern           │
│ ✓ LOCAL LAW ENFORCEMENT - PENDING PLATFORM DATA                             │
│ ✓ EDUCATIONAL INSTITUTION SECURITY - TARGET ALERT                           │
│ ✓ STATE HOMELAND SECURITY OFFICES - AFFECTED REGIONS                        │
└──────────────────────────────────────────────────────────────────────────────┘

CURRENT ACTIONS:
• JTTF investigation OPEN and ACTIVE
• Threat assessment IN PROGRESS
• Intelligence community COORDINATION
• School safety protocols ACTIVATED
• Parental notifications PENDING

================================================================================
                      SECTION 6: RESPONSE DEADLINE
================================================================================

DEADLINE: 15 MINUTES FOR ACCOUNT TERMINATION AND DATA RELEASE

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 15 MINUTES

================================================================================
              SECTION 7: CONSEQUENCES OF DELAY / NON-COMPLIANCE
================================================================================

CONSEQUENCES OF PLATFORM INACTION:

1. PLATFORM DESIGNATION as terrorist recruitment tool under 18 U.S.C. § 2339B
2. FEDERAL INVESTIGATION of platform compliance and cooperation
3. POTENTIAL SHUTDOWN of platform operations under counter-terrorism authority
4. CRIMINAL LIABILITY for corporate officers (aid and abet)
5. ASSET SEIZURE under Anti-Terrorism Act
6. INTERNATIONAL SANCTIONS and INTERPOL coordination
7. CLASS ACTION LAWSUITS from victims' families
8. PERMANENT REPUTATIONAL DAMAGE
9. REMOVAL FROM APP STORES under pressure
10. CONGRESSIONAL OVERSIGHT and PUBLIC HEARINGS

IF ATTACK OCCURS WITH PLATFORM ASSISTANCE:
• CORPORATE MANSLAUGHTER charges
• EXECUTIVE PROSECUTION (officers personally liable)
• COMPLETE ASSET FORFEITURE
• CRIMINAL COMPLICITY findings

================================================================================
                         SECTION 8: CERTIFICATION
================================================================================

This threat assessment is submitted under:
• Homeland Security Act of 2002 (6 U.S.C. § 121)
• Intelligence Reform and Terrorism Prevention Act
• 28 C.F.R. Part 23 (criminal intelligence systems)

All information provided is based on observed evidence and recovered
communications. This report constitutes a FORMAL TERRORISM TIP.

False reporting is a FEDERAL FELONY under 18 U.S.C. § 1001
(punishable by up to 8 years imprisonment).

================================================================================
                      SECTION 9: OFFICIAL CASE REFERENCE
================================================================================

DHS CASE NUMBER: DHS-%s
JTTF INVESTIGATIVE LEAD: JTTF-%s
NCTC TRACKING: NCTC-%s
ATF REFERRAL: ATF-%s
SESSION AUTHENTICATION: %s
THREAT MATRIX ID: TM-%s

EVIDENCE PACKAGE AVAILABLE FOR IMMEDIATE TRANSFER:
• 50+ screenshots of radicalization content
• 25+ recovered messages discussing attack planning
• 10+ documents/materials distributed
• Recruit identities (partial)
• Communication logs with timestamps
• Associated account analysis

================================================================================
                       END OF DHS TERRORISM ASSESSMENT
================================================================================
]], 
            "DHS-" .. os.date("%y") .. math.random(100000, 999999),
            os.date("%y%m%d"),
            math.random(1000, 9999),
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            target,
            ServerData.ServerId,
            target,
            math.random(3, 5),
            math.random(8, 15),
            math.random(20, 50),
            math.random(4, 7),
            math.random(3, 5),
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 900),
            os.date("%y%m%d") .. math.random(10000, 99999),
            math.random(1000, 9999),
            os.date("%y") .. math.random(100000, 999999),
            os.date("%j") .. math.random(10000, 99999),
            SessionEncryption:ValidateSession(sessionId) and "VERIFIED - ACTIVE" or "PENDING VERIFICATION - URGENT",
            os.date("%y%m%d") .. math.random(1000, 9999))
        end
    },
    {
        Icon = "🔞", 
        Title = "EXPLICIT / PORNOGRAPHIC CONTENT", 
        Description = "Pornography, sexual content visible to minors, COPPA violations",
        Color = Color3.fromRGB(255, 60, 30), 
        Duration = 1.8,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("EXPLICIT_CASE_" .. target)
            return string.format([[
================================================================================
                    FEDERAL TRADE COMMISSION (FTC)
               BUREAU OF CONSUMER PROTECTION
          DIVISION OF PRIVACY AND IDENTITY PROTECTION
================================================================================

COPPA VIOLATION NOTIFICATION - FORMAL COMPLAINT
CASE NUMBER: FTC-C-%s
SESSION ID: %s
FILING DATE: %s UTC
PLATFORM: Roblox (Game: %s, Server: %s)
RESPONDENT: %s

================================================================================
                         SECTION 1: EXECUTIVE SUMMARY
================================================================================

This constitutes a FORMAL COMPLAINT regarding SYSTEMATIC VIOLATIONS of:
• Children's Online Privacy Protection Act (COPPA) - 15 U.S.C. §§ 6501-6506
• 16 C.F.R. Part 312 (COPPA Rule)
• Section 5 of the FTC Act (15 U.S.C. § 45) - Unfair/Deceptive Practices

The identified user (%s) has engaged in MASSIVE DISTRIBUTION of SEXUALLY EXPLICIT
MATERIAL accessible to MINORS on the Roblox platform, with an estimated
10,000+ MINOR VIEWERS exposed to inappropriate content.

================================================================================
                    SECTION 2: DETAILED VIOLATION SUMMARY
================================================================================

A. CONTENT DISTRIBUTION STATISTICS:
   • %d+ explicit images/videos uploaded to platform
   • %d+ minor viewers estimated EXPOSED
   • %d+ comments/reactions from affected minors
   • %d alternate/backup accounts identified for distribution
   • Content active for %d+ days without removal
   • Multiple reports IGNORED or not actioned

B. NATURE OF EXPLICIT CONTENT:
   • HARDCORE PORNOGRAPHY (various categories)
   • SEXUALLY EXPLICIT MATERIAL involving adults
   • FETISH CONTENT inappropriate for minors
   • LINKS to external pornographic websites
   • SEXUALLY SUGGESTIVE roleplay scenarios
   • INAPPROPRIATE AUDIO with sexual content
   • SEXUALIZED DEPICTIONS of platform avatars

C. METHOD OF DISTRIBUTION:
   • UGC (User Generated Content) assets with embedded explicit content
   • Game descriptions containing adult links and references
   • Mass messaging campaigns to minor users
   • Decoy games hiding explicit content behind age gates
   • Coded language and symbols to bypass filters
   • Discord/Telegram links for "full content"
   • Rapid account switching to evade bans

D. PLATFORM EXPLOITATION TECHNIQUES:
   • Image filtering bypass using subtle modifications
   • Text filter evasion with Unicode characters
   • Rapid content rotation before manual review
   • Age verification bypass tactics
   • Coordinated network of accounts for distribution
   • Use of decoy content to mask violations

================================================================================
                   SECTION 3: REGULATORY AND CRIMINAL VIOLATIONS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ COPPA VIOLATIONS (Children's Online Privacy Protection Act)                 │
│ • 16 C.F.R. Part 312 - COPPA Rule                                           │
│ • FINE: $43,280 PER VIOLATION                                               │
│ • %d+ violations = $%s MILLION potential fine                               │
├──────────────────────────────────────────────────────────────────────────────┤
│ SECTION 5 of FTC ACT (15 U.S.C. § 45)                                       │
│ • Unfair/deceptive practices                                                │
│ • Additional civil penalties apply                                          │
│ • Separate fines per deceptive practice                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2252A - CSAM RELATED VIOLATIONS (if applicable)                 │
│ • Penalty: 5-20 YEARS imprisonment                                          │
│ • Fine: Up to $250,000                                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│ 47 U.S.C. § 223 - OBSCENE/ HARASSING COMMUNICATIONS                         │
│ • Penalty: Up to 2 YEARS imprisonment                                       │
│ • Fine: Up to $100,000                                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│ STATE LAWS - CHILD ENDANGERMENT                                             │
│ • Varies by jurisdiction                                                    │
│ • Additional penalties applicable                                           │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                     SECTION 4: FINANCIAL IMPACT ANALYSIS
================================================================================

POTENTIAL FTC FINES:
┌──────────────────────────────────────────────────────────────────────────────┐
│ COPPA Violation Fines:                                                       │
│ • Minimum: %d violations × $43,280 = $%s MILLION                            │
│ • Maximum: %d violations × $43,280 = $%s MILLION                            │
│                                                                              │
│ Section 5 FTC Act Penalties:                                                 │
│ • Additional fines: $%s MILLION (estimated)                                 │
│                                                                              │
│ CLASS ACTION EXPOSURE:                                                       │
│ • Minor victims: %d+ affected                                               │
│ • Per victim damages: $1,000 - $10,000                                      │
│ • Total class action exposure: $%s MILLION                                  │
│                                                                              │
│ INVESTOR LAWSUIT EXPOSURE:                                                   │
│ • Stock impact: 10-25% decline projected                                    │
│ • Shareholder lawsuits: $%s MILLION                                         │
│                                                                              │
│ TOTAL PLATFORM FINANCIAL RISK: $%s MILLION                                  │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                   SECTION 5: PLATFORM COMPLIANCE FAILURES
================================================================================

The platform has FAILED to adequately address this issue despite:

• %d+ previous reports filed by various users (IGNORED)
• %d days of continuous violation without action
• %d alternate accounts continuing same behavior
• Pattern of non-response to explicit content reports
• Inadequate filtering systems allowing bypass
• Insufficient moderation resources
• Failure to protect minor users as required by COPPA

These failures constitute SYSTEMIC NON-COMPLIANCE with federal regulations.

================================================================================
                      SECTION 6: COMPLIANCE DEADLINE
================================================================================

DEADLINE: 20 MINUTES FOR ACCOUNT REMOVAL AND CONTENT DELETION

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 20 MINUTES

================================================================================
              SECTION 7: CONSEQUENCES OF NON-COMPLIANCE
================================================================================

FAILURE TO COMPLY WITHIN DEADLINE WILL RESULT IN:

1. IMMEDIATE FTC ENFORCEMENT ACTION filed in federal court
2. PUBLIC DISCLOSURE of all violations (press release)
3. CONGRESSIONAL OVERSIGHT HEARING on platform safety
4. APP STORE REMOVAL PROCEEDINGS (Apple/Google)
5. INVESTOR CLASS ACTION LAWSUIT filing
6. DOJ REFERRAL for criminal violations
7. STATE ATTORNEYS GENERAL investigation (multi-state)
8. ADVERTISER BOYCOTT coordination
9. PARENT ORGANIZATION lawsuits
10. POTENTIAL PLATFORM SHUTDOWN under court order

ADDITIONAL CONSEQUENCES:
• Permanent damage to brand reputation
• Loss of user trust and platform exodus
• International regulatory action (GDPR, UK Online Safety Bill)
• Executive testimony under oath
• Document discovery revealing internal knowledge
• Personal liability for compliance officers

================================================================================
                         SECTION 8: CERTIFICATION
================================================================================

I certify under penalty of perjury (28 U.S.C. § 1746) that:

1. This complaint is submitted in good faith
2. The information provided is accurate and complete
3. Evidence has been preserved and documented
4. I am authorized to file this complaint

False statements are punishable under 18 U.S.C. § 1001
(up to 5 years imprisonment) and 15 U.S.C. § 50 (FTC Act).

================================================================================
                       SECTION 9: OFFICIAL FILING
================================================================================

FTC COMPLAINT NUMBER: %s
COPPA VIOLATION COUNT: %d+
EVIDENCE PACKAGE: %s
INVESTIGATIVE DIVISION: Privacy & Identity Protection
SESSION STATUS: %s
PRESERVATION ORDER: AUTO-GENERATED - PRESERVE ALL DATA

This complaint has been logged in:
✓ FTC Consumer Sentinel Network
✓ COPPA Safe Harbor Program database
✓ State AG consumer protection networks
✓ Better Business Bureau (notification)

================================================================================
                          END OF FTC COMPLAINT
================================================================================
]], 
            os.date("%y") .. math.random(10000, 99999),
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            ServerData.GameName,
            ServerData.ServerId,
            target,
            target,
            math.random(150, 300),
            math.random(8000, 12000),
            math.random(300, 600),
            math.random(10, 30),
            math.random(20, 40),
            math.random(150, 300),
            string.format("%.1f", math.random(650, 1300)/10),
            math.random(8000, 12000),
            string.format("%.1f", math.random(350, 520)/10),
            string.format("%.1f", math.random(10, 25)),
            math.random(300, 600),
            string.format("%.1f", math.random(50, 100)),
            string.format("%.1f", math.random(25, 75)),
            string.format("%.1f", math.random(100, 250)),
            math.random(5, 15),
            math.random(20, 40),
            math.random(10, 30),
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 1200),
            "FTC-" .. os.date("%y%m%d") .. "-" .. math.random(10000, 99999),
            math.random(200, 400),
            "EP-" .. os.date("%y%m%d") .. "-" .. math.random(1000, 9999),
            SessionEncryption:ValidateSession(sessionId) and "ACTIVE - VERIFIED" or "PENDING VERIFICATION")
        end
    },
    {
        Icon = "💰", 
        Title = "SCAM / FRAUD / PHISHING", 
        Description = "Financial fraud, identity theft, organized scam networks",
        Color = Color3.fromRGB(255, 120, 30), 
        Duration = 1.5,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("FRAUD_CASE_" .. target)
            return string.format([[
================================================================================
                         FEDERAL BUREAU OF INVESTIGATION
                         FINANCIAL CRIMES DIVISION
                    INTERNET CRIME COMPLAINT CENTER (IC3)
================================================================================

CRIMINAL COMPLAINT: WIRE FRAUD CONSPIRACY / IDENTITY THEFT
IC3 REFERRAL: %s
SESSION ID: %s
FILING DATE: %s UTC
PLATFORM: Roblox (Server: %s)
PRINCIPAL SUBJECT: %s
INVESTIGATION STATUS: ACTIVE - PRIORITY

================================================================================
              SECTION 1: ORGANIZED CRIMINAL ENTERPRISE ANALYSIS
================================================================================

The identified subject (%s) operates an ORGANIZED FRAUD NETWORK targeting
MINOR VICTIMS through the Roblox platform. This constitutes a CRIMINAL
ENTERPRISE under RICO statute with international reach.

================================================================================
                    SECTION 2: FRAUD SCHEMES IDENTIFIED
================================================================================

A. "FREE ROBUX GENERATOR" PHISHING:
   • %d+ confirmed victims (primarily ages 8-14)
   • Victims directed to fraudulent websites stealing login credentials
   • Accounts compromised and stripped of virtual items
   • Personal information harvested for identity theft
   • Credit cards linked to accounts used fraudulently
   • Average loss per victim: %s worth of items/Robux

B. FAKE GIVEAWAYS AND CONTESTS:
   • "Win rare limiteds" scams with fake winners
   • Victims required to "verify" with login credentials
   • Discord/Telegram groups for "prize claiming" - actually phishing
   • Social engineering tactics to obtain 2FA codes
   • Impersonation of popular YouTubers/influencers

C. LIMITED ITEM SCAMS:
   • Fake trading sites claiming to offer better values
   • Middleman scams with fake escrow services
   • Item duplication promises (impossible, yet victims believe)
   • Payment sent but item never delivered
   • Chargeback fraud on legitimate sales

D. ACCOUNT TAKEOVER AND RESALE:
   • Stolen accounts cleaned of items and resold
   • Bulk account credential trading on dark web
   • Email compromise through phishing
   • SIM swapping attempts on high-value accounts
   • Black market valuation of compromised accounts

E. CREDIT CARD FRAUD:
   • %d+ compromised credit cards used for purchases
   • Stolen cards used to buy Robux/gift cards
   • Money laundering through item flipping
   • Gift card resale on third-party sites
   • Fraudulent chargebacks on legitimate purchases

================================================================================
                     SECTION 3: FINANCIAL IMPACT ANALYSIS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ FINANCIAL HARM ASSESSMENT:                                                   │
│ • Direct theft from minors: $%s+                                            │
│ • Compromised credit cards: %d+                                             │
│ • Money mule accounts identified: %d+                                       │
│ • Funds laundered through platform: $%s+                                    │
│ • International money trail: %d COUNTRIES                                   │
│ • Platform revenue loss from fraud: $%s+                                    │
│ • Total estimated fraud ring revenue: $%s+                                  │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                      SECTION 4: ORGANIZATIONAL STRUCTURE
================================================================================

CRIMINAL ENTERPRISE ORGANIZATION:
┌──────────────────────────────────────────────────────────────────────────────┐
│ LEADERSHIP (Tier 1):                                                         │
│ • Primary coordinator: %s (identified subject)                              │
│ • Role: Scheme design, network management, profit distribution              │
│ • Technical skills: HIGH - phishing site creation, automation               │
│ • Location indicators: [REDACTED] - under investigation                     │
│                                                                              │
│ OPERATORS (Tier 2): %d+ identified accounts                                 │
│ • Role: Victim recruitment, scam execution, item collection                 │
│ • Methods: Mass messaging, fake social media presence                       │
│ • Geographic distribution: Multiple countries                                │
│                                                                              │
│ MULES (Tier 3): %d+ accounts                                                │
│ • Role: Item storage, Robux consolidation, cashing out                      │
│ • Often compromised or willingly participating for small fees               │
│ • Difficult to trace to primary operators                                   │
│                                                                              │
│ AFFILIATES (External):                                                       │
│ • Discord server operators (%d+ servers)                                    │
│ • Telegram channels for stolen data                                         │
│ • Dark web market connections                                               │
│ • Payment processors and crypto exchanges                                   │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                       SECTION 5: FEDERAL VIOLATIONS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ 18 U.S.C. § 1343 - WIRE FRAUD                                                │
│ • Penalty: 20 YEARS imprisonment                                            │
│ • Fine: $250,000 or twice the gross loss                                    │
│ • Enhanced: 30 YEARS if affecting financial institution                     │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 1028 - IDENTITY THEFT                                           │
│ • Penalty: 15 YEARS imprisonment                                            │
│ • Fine: $250,000                                                            │
│ • Mandatory restitution to victims                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 1029 - ACCESS DEVICE FRAUD                                      │
│ • Penalty: 10-20 YEARS imprisonment                                         │
│ • Fine: $250,000                                                            │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 1956 - MONEY LAUNDERING                                         │
│ • Penalty: 20 YEARS imprisonment                                            │
│ • Fine: $500,000 or twice the value                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 1962 - RICO (Racketeering)                                      │
│ • Penalty: 20 YEARS ADDITIONAL per count                                    │
│ • Asset forfeiture (ALL proceeds)                                           │
│ • Criminal fines up to $250,000                                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ 15 U.S.C. § 1644 - CREDIT CARD FRAUD                                        │
│ • Penalty: 10-20 YEARS imprisonment                                         │
│ • Fine: $250,000                                                            │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                         SECTION 6: VICTIM IMPACT
================================================================================

VICTIM DEMOGRAPHICS:
┌──────────────────────────────────────────────────────────────────────────────┐
│ Confirmed Minor Victims:      %d+                                           │
│ Age Range:                    8-17 years                                    │
│ Geographic Distribution:      USA, Canada, UK, Australia, EU                │
│ Financial Loss - Minors:      $%s+                                          │
│ Emotional/Psychological Impact: SEVERE - ongoing counseling needed          │
│ Trust in Platform:            DESTROYED                                     │
│ Families affected:            %d+                                           │
│ Reports to local police:      %d+ filed                                      │
└──────────────────────────────────────────────────────────────────────────────┘

VICTIM STATEMENTS (EXCERPTS):
"I thought it was real, they took all my Robux and then my mom's credit card"
"They said I won but needed to login first, now I can't get into my account"
"I saved for months for that limited and they just took it"

================================================================================
                     SECTION 7: ENFORCEMENT DEADLINE
================================================================================

DEADLINE: 25 MINUTES FOR ACCOUNT TERMINATION AND DATA PRESERVATION

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 25 MINUTES

================================================================================
                  SECTION 8: CONSEQUENCES OF DELAY/INACTION
================================================================================

CONTINUED OPERATION OF THIS FRAUD NETWORK WILL RESULT IN:

1. CONTINUED VICTIMIZATION OF MINORS (estimated %d+ additional victims per day)
2. EXPANSION OF CRIMINAL ENTERPRISE to new platforms
3. FBI INVESTIGATION of platform for aiding fraud
4. FINANCIAL INSTITUTION SANCTIONS (credit card processors)
5. INTERNATIONAL LAW ENFORCEMENT COORDINATION (INTERPOL)
6. STATE ATTORNEYS GENERAL investigation for consumer fraud
7. CIVIL LAWSUITS by victims' families
8. REGULATORY FINES from FTC and CFPB
9. CRIMINAL REFERRAL of platform compliance officers
10. POTENTIAL ASSET FREEZE of platform accounts

PLATFORM LIABILITY THEORIES:
• Negligent security practices
• Aiding and abetting fraud
• Unjust enrichment
• Violation of consumer protection laws
• Failure to report known fraud (financial crimes reporting)

================================================================================
                         SECTION 9: CERTIFICATION
================================================================================

This criminal complaint is filed under:
• 18 U.S.C. § 3041 (Criminal complaint)
• Federal Rules of Criminal Procedure Rule 3
• IC3 referral protocol (FBI-DOJ)

I certify under penalty of perjury that this information is accurate.

False reporting is a FEDERAL OFFENSE (18 U.S.C. § 1001)
punishable by up to 8 years imprisonment.

================================================================================
                      SECTION 10: CASE REFERENCE
================================================================================

FBI CASE NUMBER: %s
IC3 REFERRAL: %s
FINANCIAL CRIMES TASK FORCE: NOTIFIED
SECRET SERVICE (Cyber Division): ALERTED
INTERPOL NOTIFICATION: %s
SESSION AUTHENTICATION: %s
EVIDENCE PRESERVATION: %s

EVIDENCE PACKAGE INCLUDES:
• %d+ scam URLs/screenshots
• %d+ victim communications
• Financial trail analysis
• Associated account list (%d+ accounts)
• Phishing kit analysis (if recovered)
• Discord/Telegram evidence

================================================================================
                          END OF CRIMINAL COMPLAINT
================================================================================
]], 
            "IC3-" .. os.date("%y") .. math.random(1000000, 9999999),
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            ServerData.ServerId,
            target,
            target,
            math.random(8000, 12000),
            "$" .. math.random(50, 200),
            math.random(300, 700),
            string.format("%.0f", math.random(40000, 80000)),
            math.random(500, 1200),
            math.random(20, 50),
            string.format("%.0f", math.random(15000, 35000)),
            math.random(5, 12),
            string.format("%.0f", math.random(50000, 150000)),
            string.format("%.0f", math.random(100000, 300000)),
            target,
            math.random(8, 20),
            math.random(30, 80),
            math.random(10, 30),
            math.random(5000, 8000),
            string.format("%.0f", math.random(40000, 80000)),
            math.random(3000, 5000),
            math.random(50, 150),
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 1500),
            math.random(200, 500),
            "FBI-" .. os.date("%y") .. "-" .. math.random(100000, 999999),
            "IC3-" .. os.date("%y%m%d") .. "-" .. math.random(100000, 999999),
            SessionEncryption:ValidateSession(sessionId) and "NOTIFIED - ACTIVE" or "PENDING",
            SessionEncryption:ValidateSession(sessionId) and "VERIFIED - ACTIVE" or "PENDING VERIFICATION",
            "EP-" .. os.date("%y%m%d") .. "-" .. math.random(10000, 99999),
            math.random(200, 400),
            math.random(500, 1000),
            math.random(50, 150))
        end
    },
    {
        Icon = "💻", 
        Title = "EXPLOITING / CHEATING", 
        Description = "Hacks, cheats, server crashes, game disruption",
        Color = Color3.fromRGB(255, 140, 30), 
        Duration = 1.5,
        Template = function(target)
            local sessionId = SessionEncryption:CreateSession("EXPLOIT_CASE_" .. target)
            return string.format([[
================================================================================
                         DEPARTMENT OF JUSTICE
              COMPUTER CRIME AND INTELLECTUAL PROPERTY SECTION (CCIPS)
                    COMPUTER FRAUD AND ABUSE ACT (CFAA)
================================================================================

CRIMINAL COMPLAINT: COMPUTER FRAUD AND ABUSE (18 U.S.C. § 1030)
CCIPS CASE NUMBER: %s
SESSION ID: %s
FILING DATE: %s UTC
PLATFORM: Roblox (Server: %s, Game: %s)
TARGET USERNAME: %s
THREAT CLASSIFICATION: CYBERCRIME - SYSTEMATIC ATTACK

================================================================================
                     SECTION 1: CYBERATTACK ANALYSIS
================================================================================

The identified subject (%s) has committed SYSTEMATIC COMPUTER CRIMES
against the Roblox platform and its users, causing SIGNIFICANT DAMAGE
and FINANCIAL LOSS through sophisticated exploitation techniques.

================================================================================
                    SECTION 2: ATTACK VECTORS AND METHODS
================================================================================

A. MEMORY INJECTION / BYPASS TECHNIQUES:
   • Custom cheat client bypassing anti-cheat systems
   • Memory manipulation for aimbot/wallhack functionality
   • Speed hacks modifying player movement parameters
   • Fly hacks enabling out-of-bounds access
   • No-clip through collision barriers
   • ESP (Extra Sensory Perception) revealing hidden players/items

B. DDOS ATTACKS AGAINST SERVERS:
   • %d+ server crashes in past %d days attributed to this user
   • Coordinated attacks causing lag spikes
   • IP flooding targeting specific game servers
   • Exploitation of network protocol vulnerabilities
   • Server resource exhaustion attacks

C. REMOTE CODE EXECUTION EXPLOITS:
   • Attempted RCE through chat/input systems
   • Exploitation of game engine vulnerabilities
   • Custom script injection in vulnerable games
   • Cross-server scripting attacks
   • Potential for user data compromise

D. DATABASE / API EXPLOITATION:
   • SQL injection attempts against game data stores
   • API abuse for mass data scraping
   • Session hijacking and token theft
   • Data exfiltration of user information
   • Leaderboard manipulation through API calls

E. ANTI-CHEAT CIRCUMVENTION:
   • Custom drivers to bypass kernel-level detection
   • Memory encryption to hide cheat signatures
   • Rapid iteration of cheat versions to evade bans
   • Shared cheat infrastructure with other users
   • Development of undetectable techniques

================================================================================
                      SECTION 3: IMPACT ASSESSMENT
================================================================================

TECHNICAL IMPACT:
┌──────────────────────────────────────────────────────────────────────────────┐
│ Server Crashes:                 %d+ in past 30 days                         │
│ User Disruptions:               %d+ affected players                        │
│ Data Records Potentially Accessed: %d+                                      │
│ Compromised User Accounts:      %d+                                         │
│ Exploit Tools Distributed:      %d+ users received                          │
│ Detection Evasion Success Rate: HIGH - undetected for extended period       │
└──────────────────────────────────────────────────────────────────────────────┘

ECONOMIC IMPACT:
┌──────────────────────────────────────────────────────────────────────────────┐
│ Virtual Asset Theft:            $%s+                                        │
│ Economic Manipulation:          $%s+ through item duplication               │
│ Security Remediation Cost:      $%s+ (estimated)                            │
│ IP Valuation at Risk:           $%s+ (game engine/IP)                       │
│ User Trust Impact:              CRITICAL - player exodus observed           │
│ Stock Impact:                   15-25%% projected decline                    │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                         SECTION 4: FEDERAL VIOLATIONS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ 18 U.S.C. § 1030 - COMPUTER FRAUD AND ABUSE ACT (CFAA)                      │
│                                                                              │
│ • (a)(2): Unauthorized Access to Computer                                   │
│   - Penalty: 5 YEARS imprisonment (first offense)                           │
│   - Penalty: 10 YEARS (subsequent offense)                                  │
│                                                                              │
│ • (a)(4): Fraud by Computer                                                 │
│   - Penalty: 10 YEARS imprisonment                                          │
│   - Fine: $250,000 or twice the loss                                        │
│                                                                              │
│ • (a)(5)(A): Damage to Protected Computer                                   │
│   - Loss threshold: $5,000+ (MET: $%s+ loss)                                │
│   - Penalty: 10 YEARS imprisonment                                          │
│   - Enhanced: 20 YEARS if attempted death/injury                            │
│                                                                              │
│ • (a)(7): Extortion Involving Computers                                     │
│   - Penalty: 5 YEARS imprisonment                                           │
│   - Fine: $250,000                                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2511 - WIRETAP ACT                                              │
│ • Interception of electronic communications                                 │
│ • Penalty: 5 YEARS imprisonment                                             │
│ • Fine: $250,000                                                            │
├──────────────────────────────────────────────────────────────────────────────┤
│ 18 U.S.C. § 2701 - STORED COMMUNICATIONS ACT                               │
│ • Unauthorized access to stored communications                             │
│ • Penalty: 5 YEARS imprisonment                                            │
├──────────────────────────────────────────────────────────────────────────────┤
│ ECONOMIC ESPIONAGE ACT (18 U.S.C. § 1831-1839)                              │
│ • Theft of trade secrets (game code/assets)                                 │
│ • Penalty: 15 YEARS imprisonment                                            │
│ • Fine: $5,000,000 corporate                                                │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                  SECTION 5: EVIDENCE AND DIGITAL FORENSICS
================================================================================

DIGITAL EVIDENCE COLLECTED:
┌──────────────────────────────────────────────────────────────────────────────┐
│ EVIDENCE TYPE                    │ QUANTITY        │ FORENSIC VALUE         │
├──────────────────────────────────────────────────────────────────────────────┤
│ Cheat client executables         │ %d variants     │ HIGH - contains signatures│
│ Memory dump analysis             │ %d samples      │ HIGH - injection proof  │
│ Network traffic captures          │ %d packets      │ MEDIUM - DDoS evidence │
│ Screenshots of exploits           │ %d+ images      │ HIGH - visual proof    │
│ Video recordings                  │ %d+ clips       │ HIGH - timestamped     │
│ API abuse logs                    │ %d+ entries     │ MEDIUM - pattern proof │
│ Associated account list           │ %d accounts     │ HIGH - network mapping │
└──────────────────────────────────────────────────────────────────────────────┘

FORENSIC HASH: %s
CHAIN OF CUSTODY: COC-%s
EVIDENCE INTEGRITY: VERIFIED (SHA-384)

================================================================================
                    SECTION 6: BUSINESS IMPACT ANALYSIS
================================================================================

┌──────────────────────────────────────────────────────────────────────────────┐
│ REVENUE IMPACT:                                                              │
│ • Direct revenue loss:              $%s+                                    │
│ • Player churn (estimated):         %d+ users quit                          │
│ • Lost microtransaction revenue:    $%s+ monthly                            │
│ • Developer tool licensing impact:  15%% reduction                           │
│                                                                              │
│ SECURITY COSTS:                                                              │
│ • Emergency patch deployment:       $%s+                                    │
│ • Anti-cheat upgrade required:      $%s+                                    │
│ • Security audit expenses:          $%s+                                    │
│ • Legal/compliance review:          $%s+                                    │
│                                                                              │
│ LONG-TERM IMPACT:                                                            │
│ • Brand damage:                      SEVERE                                  │
│ • Investor confidence:                REDUCED                                │
│ • Partnership opportunities:          DELAYED                                │
│ • Regulatory scrutiny:                INCREASED                              │
│ • Insurance premium increase:         25-40%%                                │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
                        SECTION 7: PLATFORM VULNERABILITIES
================================================================================

EXPLOITED VULNERABILITIES IDENTIFIED:

1. MEMORY INTEGRITY:
   • Anti-cheat bypass via unsigned drivers
   • Memory scanning detection evasion
   • Heap spraying techniques successful
   • Recommended: Implement kernel-level protection

2. NETWORK PROTOCOL:
   • Packet manipulation possible
   • Server-authoritative checks missing
   • Rate limiting insufficient
   • Recommended: Encrypt and validate all game packets

3. CLIENT-SIDE TRUST:
   • Over-reliance on client-side validation
   • Critical game logic executed locally
   • State synchronization vulnerabilities
   • Recommended: Move critical logic server-side

4. API SECURITY:
   • No rate limiting on sensitive endpoints
   • Insufficient authentication checks
   • Data exposure through verbose errors
   • Recommended: Implement OAuth 2.0 with scope restrictions

================================================================================
                      SECTION 8: ENFORCEMENT DEADLINE
================================================================================

DEADLINE: 30 MINUTES FOR ACCOUNT TERMINATION AND SECURITY PATCHING

CURRENT TIME: %s UTC
FINAL DEADLINE: %s UTC
TIME REMAINING: 30 MINUTES

REQUIRED ACTIONS WITHIN DEADLINE:
┌──────────────────────────────────────────────────────────────────────────────┐
│ 1. IMMEDIATE ACCOUNT TERMINATION (5 minutes)                                │
│ 2. IP BAN OF ASSOCIATED CONNECTIONS (10 minutes)                            │
│ 3. PRESERVE ALL EVIDENCE (ongoing)                                          │
│ 4. NOTIFY AFFECTED USERS OF DATA BREACH (15 minutes)                        │
│ 5. DEPLOY EMERGENCY PATCH FOR EXPLOITS (30 minutes)                         │
│ 6. SUBMIT BREACH NOTIFICATION TO REGULATORS (if applicable)                 │
└──────────────────────────────────────────────────────────────────────────────┘

================================================================================
              SECTION 9: CONSEQUENCES OF NON-COMPLIANCE
================================================================================

FAILURE TO ACT WITHIN DEADLINE CONSTITUTES:

1. AIDING AND ABETTING COMPUTER CRIME (18 U.S.C. § 2)
2. NEGLIGENT SECURITY PRACTICES (FTC Act violation)
3. CIVIL LIABILITY TO ALL AFFECTED USERS (class action)
4. REGULATORY ENFORCEMENT ACTION (FTC, SEC if public)
5. CRIMINAL INVESTIGATION OF PLATFORM (DOJ/CCIPS)
6. PCI DSS VIOLATIONS (if payment data involved)
7. GDPR/PRIVACY REGULATION FINES (if EU users affected)
8. INSURANCE COVERAGE VOID (negligence exclusion)
9. EXECUTIVE PERSONAL LIABILITY (derivative lawsuits)
10. PLATFORM SHUTDOWN UNDER COURT ORDER

ADDITIONAL CONSEQUENCES:
• SEC investigation for material misrepresentations to investors
• Insurance denial for all cyber claims
• Credit card processor termination (Visa/Mastercard)
• App store removal pending security audit
• Congressional inquiry and public hearings

================================================================================
                         SECTION 10: CERTIFICATION
================================================================================

This criminal complaint is filed under:
• 18 U.S.C. § 3041 (Criminal complaint)
• Federal Rules of Criminal Procedure Rule 3
• CCIPS referral protocol (DOJ)

I CERTIFY UNDER PENALTY OF PERJURY (18 U.S.C. § 1621) that:

1. I have personal knowledge of the facts stated herein
2. The evidence has been preserved with chain of custody
3. This report is submitted in good faith
4. The information is accurate and complete to my knowledge

FALSE REPORTING IS A FEDERAL OFFENSE (18 U.S.C. § 1001)
punishable by up to 8 YEARS IMPRISONMENT and fines.

================================================================================
                      SECTION 11: OFFICIAL CASE REFERENCE
================================================================================

CCIPS CASE NUMBER: %s
DOJ TRACKING ID: DOJ-CYBER-%s
FBI CYBER CASE: %s
IC3 REFERRAL: %s
CISA NOTIFICATION: %s
SESSION AUTHENTICATION: %s

NOTIFICATIONS SENT TO:
✓ FBI Cyber Division (CyWatch)
✓ DOJ Computer Crime Section (CCIPS)
✓ CISA (Cybersecurity Infrastructure Security Agency)
✓ Secret Service (Cyber Intelligence Section)
✓ INTERPOL Cybercrime Directorate
✓ National Cyber Forensic Training Alliance

EVIDENCE PACKAGE AVAILABLE:
• Full packet capture analysis
• Malware/cheat client samples
• Exploit chain documentation
• Timeline of attacks
• Financial impact assessment
• User notification templates

================================================================================
                    END OF COMPUTER CRIME COMPLAINT
================================================================================
]], 
            -- Section 1
            "CCIPS-" .. os.date("%y") .. "-" .. math.random(100000, 999999),
            sessionId,
            os.date("%Y-%m-%d %H:%M:%S"),
            ServerData.ServerId,
            ServerData.GameName,
            target,
            target,
            -- Section 2
            math.random(30, 80),
            math.random(15, 45),
            -- Section 3
            math.random(50, 120),
            math.random(5000, 15000),
            math.random(10000, 50000),
            math.random(2000, 8000),
            math.random(500, 2000),
            math.random(1000, 5000),
            string.format("%.0f", math.random(50000, 200000)),
            string.format("%.0f", math.random(25000, 100000)),
            string.format("%.0f", math.random(100000, 500000)),
            string.format("%.0f", math.random(1000000, 5000000)),
            -- Section 4
            string.format("%.0f", math.random(50000, 200000)),
            -- Section 5
            math.random(3, 10),
            math.random(20, 60),
            math.random(5000, 20000),
            math.random(30, 100),
            math.random(10, 40),
            math.random(1000, 5000),
            math.random(10, 50),
            HttpService:GenerateGUID(false):upper(),
            os.date("%y%m%d") .. math.random(10000, 99999),
            -- Section 6
            string.format("%.0f", math.random(50000, 200000)),
            math.random(1000, 10000),
            string.format("%.0f", math.random(20000, 100000)),
            string.format("%.0f", math.random(25000, 150000)),
            string.format("%.0f", math.random(50000, 300000)),
            string.format("%.0f", math.random(15000, 75000)),
            string.format("%.0f", math.random(25000, 125000)),
            -- Section 8
            os.date("%H:%M:%S"),
            os.date("%H:%M:%S", os.time() + 1800),
            -- Section 11
            "CCIPS-" .. os.date("%y") .. "-" .. math.random(100000, 999999),
            "DOJ-" .. os.date("%y%m%d") .. "-" .. math.random(100000, 999999),
            "FBI-CYBER-" .. os.date("%y") .. "-" .. math.random(1000000, 9999999),
            "IC3-" .. os.date("%y%m%d") .. "-" .. math.random(1000000, 9999999),
            "CISA-" .. os.date("%j") .. "-" .. math.random(10000, 99999),
            SessionEncryption:ValidateSession(sessionId) and "VERIFIED - ACTIVE - EVIDENCE LOCKED" or "CRITICAL - VERIFICATION REQUIRED")
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
    ReportBtn.Text = report.Icon .. " " .. report.Title .. "\n" .. report.Description
    ReportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReportBtn.BackgroundColor3 = report.Color
    ReportBtn.Font = Enum.Font.Gotham
    ReportBtn.TextSize = 13
    ReportBtn.TextWrapped = true
    ReportBtn.TextXAlignment = Enum.TextXAlignment.Left
    ReportBtn.TextYAlignment = Enum.TextYAlignment.Center
    ReportBtn.AutoButtonColor = false
    ReportBtn.Name = "Report_" .. i
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
        BtnStroke.Thickness = 2
    end)
    
    ReportBtn.MouseLeave:Connect(function()
        ReportBtn.BackgroundTransparency = 0
        BtnStroke.Transparency = 0.6
        BtnStroke.Thickness = 1.5
    end)
    
    ReportBtn.MouseButton1Click:Connect(function()
        local target = TargetBox.Text
        if target == "" or target == "Enter username to report..." then
            TargetBox.PlaceholderText = "❌ ERROR: SELECT TARGET FIRST ❌"
            TargetBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            
            -- Shake animation
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
        
        -- Copy to clipboard
        if setclipboard then
            setclipboard(reportText)
        end
        
        -- Visual feedback
        ReportBtn.Text = "✅ REPORT GENERATED & COPIED ✅\n" .. report.Description
        ReportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        btnData.BtnStroke.Color = Color3.fromRGB(0, 255, 0)
        btnData.BtnStroke.Transparency = 0
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        
        ServerData.ReportCount = ServerData.ReportCount + 1
        SubTitle.Text = string.format("Server: %s | Reports: %d | ⚡ ACTIVE", 
            ServerData.ServerId, ServerData.ReportCount)
        
        task.wait(report.Duration)
        
        ReportBtn.Text = btnData.OriginalText
        ReportBtn.BackgroundColor3 = btnData.OriginalColor
        btnData.BtnStroke.Color = btnData.OriginalStrokeColor
        btnData.BtnStroke.Transparency = 0.6
        
        -- Show notification
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0.75, 0, 0, 60)
        notif.Position = UDim2.new(0.125, 0, 0, -60)
        notif.Text = string.format("⚡ FEDERAL REPORT #%d ⚡\n%s\nTarget: %s\nSession: %s", 
            ServerData.ReportCount,
            report.Title,
            target,
            sessionId or "ACTIVE")
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.BackgroundColor3 = Color3.fromRGB(139, 0, 0) -- Dark red
        notif.Font = Enum.Font.GothamBold
        notif.TextSize = 11
        notif.TextWrapped = true
        notif.ZIndex = 10
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
        
        local NotifStroke = Instance.new("UIStroke", notif)
        NotifStroke.Color = Color3.fromRGB(255, 215, 0) -- Gold
        NotifStroke.Thickness = 2
        
        notif.Parent = MainFrame
        
        local slideIn = TweenService:Create(
            notif,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Position = UDim2.new(0.125, 0, 0, 10)}
        )
        slideIn:Play()
        
        task.wait(3)
        
        local slideOut = TweenService:Create(
            notif,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Position = UDim2.new(0.125, 0, 0, -60)}
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
StatusText.Text = "⚡ FEDERAL CASE ACTIVE | SESSION ENCRYPTED | FBI NOTIFIED ⚡"
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 11
StatusText.BackgroundTransparency = 1
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

task.spawn(function()
    while true do
        StatusText.Text = string.format("⚡ Reports: %d | Players: %d | Sessions: %d | %s UTC | FBI CASE ACTIVE", 
            ServerData.ReportCount, 
            ServerData.TotalPlayers,
            #ActiveSessions,
            os.date("%H:%M:%S")
        )
        task.wait(1)
    end
end)

-- // QUICK HELP TEXT
local HelpText = Instance.new("TextLabel")
HelpText.Size = UDim2.new(1, -30, 0, 20)
HelpText.Position = UDim2.new(0, 15, 1, -70)
HelpText.Text = "⚡ Click category → Enter target → Federal report copied to clipboard ⚡"
HelpText.TextColor3 = Color3.fromRGB(255, 200, 100)
HelpText.Font = Enum.Font.GothamBold
HelpText.TextSize = 10
HelpText.BackgroundTransparency = 1
HelpText.TextXAlignment = Enum.TextXAlignment.Left
HelpText.Parent = MainFrame

-- // WATERMARK / CREDITS (small)
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, -30, 0, 16)
Watermark.Position = UDim2.new(0, 15, 1, -20)
Watermark.Text = "RatHub Federal Reporting System v2.0 | DOJ/FBI Compliant"
Watermark.TextColor3 = Color3.fromRGB(100, 100, 100)
Watermark.Font = Enum.Font.Gotham
Watermark.TextSize = 8
Watermark.BackgroundTransparency = 1
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = MainFrame

-- // INITIALIZATION
UpdatePlayers()

-- Cleanup old sessions (keep last 100)
task.spawn(function()
    while true do
        task.wait(300) -- 5 minutes
        if #ActiveSessions > 100 then
            local newSessions = {}
            for i = #ActiveSessions - 99, #ActiveSessions do
                table.insert(newSessions, ActiveSessions[i])
            end
            ActiveSessions = newSessions
        end
    end
end)

-- // SESSION CLEANUP (keep sessions for 2 hours)
task.spawn(function()
    while true do
        task.wait(7200) -- 2 hours
        SessionEncryption.SessionStorage = {}
    end
end)

-- // AUTO-UPDATE STATUS WITH PULSE EFFECT
task.spawn(function()
    while true do
        StatusText.TextTransparency = 0
        task.wait(0.5)
        StatusText.TextTransparency = 0.3
        task.wait(0.5)
    end
end)

task.wait(1.5)
print("RatHub Loaded") -- Fixed: removed extra closing parenthesis
