--[[============================================================
      VENICE HUB  |  APEX  |  v5.0
      12 camadas de anti-kick • detecção de ban • self-healing
      verificação de integridade de hook • 4 módulos • 190+ opções
      Tiro • Farm • Anime • Mundo
============================================================]]--

if getgenv().VeniceLoaded then
    local old = getgenv().VeniceLoaded
    pcall(function() old() end)
end
if not game:IsLoaded() then game.Loaded:Wait() end

local P     = game:GetService("Players")
local RS    = game:GetService("RunService")
local WS    = game:GetService("Workspace")
local UIS   = game:GetService("UserInputService")
local TS    = game:GetService("TeleportService")
local VU    = game:GetService("VirtualUser")
local SG    = game:GetService("StarterGui")
local LGT   = game:GetService("Lighting")
local HS    = game:GetService("HttpService")
local STA   = game:GetService("Stats")
local RS2   = game:GetService("ReplicatedStorage")
local LP    = P.LocalPlayer

local Cs, Rn = {}, true
local function ad(c) if not c then return c end if not Rn then pcall(function() c:Disconnect() end) return c end Cs[#Cs+1]=c return c end
local function sf(f,...) return pcall(f,...) end
local function gc() return LP.Character end
local function gh() local c=gc() return c and c:FindFirstChildOfClass("Humanoid") end
local function gr() local c=gc() return c and c:FindFirstChild("HumanoidRootPart") end
local function gtool() local c=gc() return c and c:FindFirstChildOfClass("Tool") end
local function nt(t,c,d) pcall(function() Rayfield:Notify({Title=t,Content=c,Duration=d or 4,Image=4483362458}) end) end

local function toks(s)
    local o={}
    for w in (s or ""):gmatch("[^,]+") do
        w=w:match("^%s*(.-)%s*$"):lower()
        if w~="" then o[#o+1]=w end
    end
    if #o==0 then o[1]="" end
    return o
end
local function mtc(n,l) local s=n:lower() for _,f in ipairs(l) do if f=="" or s:find(f,1,true) then return true end end return false end

local DR = rawget(getfenv(),"Drawing") or Drawing
local HASD = false
sf(function() if DR then HASD = pcall(function() local o=DR.new("Circle") o:Remove() end) end end)

local DEF_BLOCK = toks("Block,Guard,Parry,Ken,Observation,Haki,Dodge,Shield")
local DEF_COLL  = toks("Fruit,Coin,CoinBag,Cash,Seed,Pet,Egg,Drop,Orb")
local BAN_KW    = toks("ban,banned,exploit,suspicious,detected,third party,script")

-- ============================================================
--  ESTADO (booleanos reais)
-- ============================================================
local S = {
    -- anti
    kick=1, rejoin=1, maxRJ=12, rjDelay=2, watchdog=1, banStop=1,
    void=1, voidY=-80, fling=1, antiTP=0, tpThr=70,
    freeze=1, slow=1, slowF=14, jlock=1, jumpF=45, ragdoll=1, afk=1,
    crash=1, mem=1400, heal=1, integrity=1, conservative=0, stealth=0, cap=55,
    -- mira
    aim=0, aimFOV=140, aimSm=0.18, aimPart="Head", aimMode="Mais próximo",
    aimTeam=1, aimWall=0, aimPred=0, aimLock=0, aimCircle=1,
    silent=0, silFOV=230, silPart="Head", silTeam=1,
    assist=0, assistFOV=200,
    trig=0, trigFOV=42, trigDelay=0.05,
    norecoil=0, rapid=0,
    hitbox=0, hbSize=6, third=0, crosshair=0,
    -- esp
    esp=0, espBox=0, espSkel=0, espName=0, espDist=0, espHP=0, espArrow=0,
    espTracer=0, espHead=0, espTeam=0, espCompat=0, espColor=Color3.fromRGB(170,0,255),
    radar=0, radarRG=150, radarBot=0, list=0, watermark=1,
    mobEsp=0, mobFilter="Zombie,Monster,Mob,Enemy,Boss", plantEsp=0,
    plantFilter="Mutation,Gold,Rainbow,Shiny,Diamond", plantRG=120, itemEsp=0,
    -- movimento
    speed=0, speedV=50, jump=0, jumpV=100, infJump=0,
    fly=0, flySP=55, noclip=0, hover=0, bhop=0, ghost=0, spin=0, spinV=10,
    orbit=0, orbitR=8, orbitH=4, orbitT=nil, glue=0, glueT=nil,
    platform=0, platSize=6, clickTP=0, god=0, autospawn=0,
    -- farm
    farm=0, farmRG=22, sellRG=70, farmInt=0.35,
    stCollect=1, stHarvest=1, stSell=1, stPlant=1, stWater=1, stBuy=0, stHatch=0,
    sellEvery=1, sellSec=60, petEq=0, petF="Pet",
    -- anime
    mobFarm=0, mobRG=45, mobDelay=0.4, mobTP=1, mobM1=1,
    mobF="Bandit,Monkey,Pirate,Soldier,Brute",
    quest=0, questF="Quest,Accept,Reward,Complete,Claim",
    chest=0, chestRG=60, chestF="Chest,Crate,Box,Treasure",
    fruit=0, fruitF="Fruit", fruitTP=0, bossEsp=0, bossF="Boss,Level,Bounty",
    vacuum=0, vacRG=40,
    skill=0, skillD=0.35, m1=0, m1D=0.12, combo=0, comboD=0.18,
    block=0, blockRG=14, dodge=0, dodgeHP=45, dash=0, dashRG=60,
    -- mundo
    partQ="", autoEquip=0, equipF="",
}
local PRIO, WHITE = {}, {}
local kickLog, spyLog = {}, {}
local stats = {kicks=0, rejoins=0, start=tick()}

-- ============================================================
--  UI
-- ============================================================
local okR, Rayfield = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/rayfield"))() end)
if not okR or type(Rayfield)~="table" or type(Rayfield.CreateWindow)~="function" then
    pcall(function() SG:SetCore("SendNotification",{Title="Venice",Text="UI falhou.",Duration=8}) end)
    return
end
local W = Rayfield:CreateWindow({
    Name="Venice Hub • APEX", Icon=4483362458,
    LoadingTitle="Venice Hub APEX", LoadingSubtitle="v5.0",
    Theme="Amethyst", KeySystem=false,
    ConfigurationSaving={Enabled=true,FolderName="VeniceHub",FileName="Apex_"..game.PlaceId}
})

-- ============================================================
--  CAMADAS ANTI-KICK (1..5)
-- ============================================================
local hookState = {kickHook=false, nameHook=false, indexHook=false}
local origKick, origName, origIndex
local rjBusy, rjBackoff = false, 1

local function isBanReason(r)
    local s = tostring(r or ""):lower()
    return mtc(s, BAN_KW)
end

local function rejoin(reason)
    if rjBusy then return end
    if stats.rejoins >= S.maxRJ then
        nt("Anti-Kick", "Limite de "..S.maxRJ.." rejoins.", 6); return
    end
    rjBusy = true; stats.rejoins += 1
    local d = S.rjDelay * rjBackoff
    rjBackoff = math.min(rjBackoff * 1.35, 6)
    task.delay(d, function()
        rjBusy = false
        local ok = sf(function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
        if not ok then sf(function() TS:Teleport(game.PlaceId, LP) end) end
    end)
end

local function logKick(reason)
    stats.kicks += 1
    kickLog[1] = ("%s  %s"):format(os.date("%H:%M:%S"), tostring(reason or "?"):sub(1,60))
    while #kickLog > 8 do table.remove(kickLog) end
    if KLBL then sf(KLBL.Set, KLBL, table.concat(kickLog, "\n")) end
end

local function handleKick(reason)
    logKick(reason)
    local ban = isBanReason(reason)
    nt(ban and "Possível BAN" or "Anti-Kick", tostring(reason), 9)
    if S.rejoin==0 then return end
    if ban and S.banStop==1 and stats.rejoins >= 2 then
        nt("Anti-Kick", "Ban detectado — parando rejoins.", 8); return
    end
    rejoin(reason)
end

-- camada 1: hookfunction direto
local function installKickHook()
    if hookState.kickHook then return true end
    local ok = sf(function()
        origKick = hookfunction(LP.Kick, newcclosure(function(r)
            if S.kick==0 then return origKick(r) end
            handleKick(r)
        end))
        hookState.kickHook = true
    end)
    return ok and hookState.kickHook
end

-- camada 2: namecall (kick + spy + auto-remote)
local function installNameHook()
    if hookState.nameHook then return true end
    local ok = sf(function()
        origName = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if m=="Kick" and self==LP and S.kick==1 then
                local a = {...}
                handleKick(a[1])
                return
            end
            if m=="FireServer" and type(self)=="Instance" then
                if SPY==1 and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    spyLog[1] = ("%s :: %s"):format(self.Name, tostring(({...})[1]):sub(1,34))
                    while #spyLog > 8 do table.remove(spyLog) end
                    if SLBL then sf(SLBL.Set, SLBL, table.concat(spyLog, "\n")) end
                end
            end
            return origName(self, ...)
        end)
        hookState.nameHook = true
    end)
    return ok and hookState.nameHook
end

-- camada 3: __index no Kick
local function installIndexHook()
    if hookState.indexHook then return true end
    local ok = sf(function()
        origIndex = hookmetamethod(game, "__index", function(self, key)
            local raw = origIndex(self, key)
            -- silent aim
            if S.silent==1 and SILT and self==WS.CurrentCamera and key=="CFrame" and typeof(raw)=="CFrame" then
                return CFrame.lookAt(raw.Position, SILT.P.Position)
            end
            -- kick via index (terceira via)
            if key=="Kick" and self==LP and S.kick==1 and not hookState.kickHook then
                return function(_, r) handleKick(r) end
            end
            return raw
        end)
        hookState.indexHook = true
    end)
    return ok and hookState.indexHook
end

-- camada 4: watchdog de congelamento
local lastBeat = os.clock()
ad(RS.Heartbeat:Connect(function() lastBeat = os.clock() end))
task.spawn(function()
    while Rn do
        task.wait(2)
        if S.watchdog==1 and (os.clock()-lastBeat) > 7 then
            lastBeat = os.clock()
            nt("Watchdog", "Cliente congelado — reconectando.", 5)
            rejoin("watchdog")
        end
    end
end)

-- camada 5: verificação de integridade dos hooks
task.spawn(function()
    while Rn do
        task.wait(6)
        if S.integrity==1 then
            if not hookState.kickHook then installKickHook() end
            if not hookState.nameHook then installNameHook() end
            if not hookState.indexHook then installIndexHook() end
        end
    end
end)

installKickHook(); installNameHook(); installIndexHook()
local LAYERS = (hookState.kickHook and "hookfunction " or "")..(hookState.nameHook and "+ namecall " or "")..
               (hookState.indexHook and "+ index " or "").."+ watchdog + integridade"

-- ============================================================
--  NÚCLEO DE PROTEÇÃO
-- ============================================================
local lastSafe, lastPos
local crashCd = 0
ad(RS.Heartbeat:Connect(function()
    local hum, hrp = gh(), gr()
    if not hum or not hrp then return end
    if hrp.Position.Y > -20 then lastSafe = hrp.CFrame end

    if S.void==1 and hrp.Position.Y < S.voidY and lastSafe then
        hrp.CFrame = lastSafe + Vector3.new(0,8,0)
    end
    if S.fling==1 and hrp.AssemblyLinearVelocity.Magnitude > 450 and lastSafe then
        hrp.CFrame = lastSafe
    end
    if S.antiTP==1 and lastPos and (hrp.Position-lastPos).Magnitude > S.tpThr then
        hrp.CFrame = CFrame.new(lastPos)
    end
    if S.ragdoll==1 and hum.PlatformStand then hum.PlatformStand = false end
    if S.god==1 then
        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
        hum.Health = hum.MaxHealth
    end
    lastPos = hrp.Position

    -- anti-crash com cooldown
    if S.crash==1 and os.clock()-crashCd > 3 then
        local mem = gcinfo()/1024
        if mem > S.mem then
            crashCd = os.clock(); S.mem = mem + 250
            local n = 0
            for _,d in ipairs(WS:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Trail") then d.Enabled=false; n+=1 end
                if n > 1200 then break end
            end
            collectgarbage()
        end
    end
end))

-- self-healing de valores protegidos
ad(RS.Heartbeat:Connect(function()
    local hum = gh(); if not hum then return end
    if S.slow==1 and hum.WalkSpeed < S.slowF then hum.WalkSpeed = S.slowF end
    if S.jlock==1 then
        hum.UseJumpPower = true
        if hum.JumpPower < S.jumpF then hum.JumpPower = S.jumpF end
    end
end))

-- anti-freeze
local freezeDur = 0
ad(RS.Heartbeat:Connect(function(dt)
    local hum, hrp = gh(), gr()
    if not hum or not hrp or S.freeze==0 then return end
    if hum:GetState()==Enum.HumanoidStateType.Physics then
        freezeDur += dt
        if freezeDur > 1 then hum:ChangeState(Enum.HumanoidStateType.Jumping); freezeDur = 0 end
    else freezeDur = 0 end
end))

-- anti-AFK triplo
ad(LP.Idled:Connect(function()
    if S.afk==0 then return end
    VU:CaptureController(); VU:ClickButton2(Vector2.new())
end))
task.spawn(function()
    while Rn do
        task.wait(45)
        if S.afk==1 then
            sf(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
        end
    end
end))

ad(LP.CharacterAdded:Connect(function()
    task.wait(1.2)
    stats.rejoins = 0; rjBackoff = 1
end))
sf(function() if setfpscap then setfpscap(240) end end)

-- ============================================================
--  ALVO
-- ============================================================
local function cand(partName, team, wall, bots)
    local cam = WS.CurrentCamera
    local out = {}
    if not cam then return out end
    local ce = cam.ViewportSize/2
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {gc()}

    local function add(part, model, hum, name, isBot)
        if not hum or hum.Health <= 0 or not part or not part:IsA("BasePart") then return end
        if WHITE[name] then return end
        local pos, on = cam:WorldToViewportPoint(part.Position)
        if not on then return end
        local d = (Vector2.new(pos.X,pos.Y)-ce).Magnitude
        if wall then
            local hit = WS:Raycast(cam.CFrame.Position, part.Position-cam.CFrame.Position, rp)
            if hit and not hit.Instance:IsDescendantOf(model) then return end
        end
        out[#out+1] = {P=part, M=model, H=hum, D=d, N=name, B=isBot}
    end

    for _,plr in ipairs(P:GetPlayers()) do
        if plr~=LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local skip = team and LP.Team and plr.Team==LP.Team
            if not skip then
                add(plr.Character:FindFirstChild(partName) or plr.Character:FindFirstChild("HumanoidRootPart"),
                    plr.Character, hum, plr.Name, false)
            end
        end
    end
    if bots then
        for _,m in ipairs(RB()) do
            add(m:FindFirstChild(partName) or GR(m), m, m:FindFirstChildOfClass("Humanoid"), m.Name, true)
        end
    end
    return out
end

local function pick(cfg)
    local best
    for _,x in ipairs(cand(cfg.part, cfg.team, cfg.wall, cfg.bots)) do
        if x.D <= cfg.fov then
            if cfg.mode=="Prioritário" and PRIO[x.N] then return x end
            if not best then best = x
            elseif cfg.mode=="Menor vida" then
                if x.H.Health < best.H.Health then best = x end
            elseif x.D < best.D then best = x end
        end
    end
    return best
end

-- ============================================================
--  MIRA
-- ============================================================
local FC, LOCKED, SILT, RECOIL
sf(function()
    if HASD then
        FC = DR.new("Circle"); FC.Thickness=1.5; FC.NumSides=60
        FC.Color = Color3.fromRGB(170,0,255); FC.Filled=false; FC.Visible=false
    end
end)

ad(RS.RenderStepped:Connect(function()
    local cam = WS.CurrentCamera; if not cam then return end
    if FC then
        FC.Position = cam.ViewportSize/2; FC.Radius = S.aimFOV
        FC.Visible = S.aim==1 and S.aimCircle==1
    end

    if S.aim==1 then
        local valid = LOCKED and LOCKED.P and LOCKED.P.Parent and LOCKED.H and LOCKED.H.Health>0
            and (LOCKED.P.Position-cam.CFrame.Position).Magnitude < 500
        if not (S.aimLock==1 and valid) then
            LOCKED = pick({part=S.aimPart, team=S.aimTeam==1, wall=S.aimWall==1,
                           bots=true, fov=S.aimFOV, mode=S.aimMode})
        end
        if LOCKED then
            local goal = LOCKED.P.Position
            if S.aimPred==1 then goal = goal + LOCKED.P.AssemblyLinearVelocity*0.13 end
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, goal), S.aimSm)
        end
    else LOCKED = nil end

    if S.assist==1 and S.aim==0 then
        local t = pick({part="Head", team=false, wall=false, bots=false, fov=S.assistFOV, mode="Mais próximo"})
        if t then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, t.P.Position), 0.25) end
    end

    if S.norecoil==1 and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        RECOIL = RECOIL or cam.CFrame
        cam.CFrame = cam.CFrame:Lerp(RECOIL, 0.22)
    else RECOIL = nil end
end))

ad(RS.RenderStepped:Connect(function()
    SILT = (S.silent==1) and pick({part=S.silPart, team=S.silTeam==1, wall=false,
                                    bots=true, fov=S.silFOV, mode="Mais próximo"}) or nil
end))

local trigCfg = {part="HumanoidRootPart", team=true, wall=false, bots=true, fov=42, mode="Mais próximo"}
local fN = 0
ad(RS.RenderStepped:Connect(function()
    if S.trig==0 then return end
    fN += 1; if fN % 2 ~= 0 then return end
    trigCfg.fov = S.trigFOV
    if pick(trigCfg) then
        sf(function() VU:CaptureController(); VU:ClickButton1(Vector2.new()) end)
    end
end))

task.spawn(function()
    while Rn do
        if S.rapid==1 then
            local t = gtool(); if t then sf(function() t:Activate() end) end
        end
        task.wait(0.08)
    end
end)

ad(RS.Heartbeat:Connect(function()
    if S.hitbox==0 then return end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP then
            local h = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                h.Size = Vector3.new(S.hbSize,S.hbSize,S.hbSize)
                h.Transparency = 0.7
            end
        end
    end
end))

local savedZoom
ad(RS.RenderStepped:Connect(function()
    if S.third==1 then
        savedZoom = savedZoom or LP.CameraMaxZoomDistance
        LP.CameraMinZoomDistance = 14; LP.CameraMaxZoomDistance = 18
    elseif savedZoom then
        LP.CameraMinZoomDistance = 0.5; LP.CameraMaxZoomDistance = savedZoom; savedZoom = nil
    end
end))

-- ============================================================
--  BOTS
-- ============================================================
local BKW = toks("bot,npc,enemy,dummy,ai,mob,monster,zombie,guard,soldier,hostile,entity")
local BC, LBS, MAXB = {}, 0, 140
local function IPM(m) return P:GetPlayerFromCharacter(m) ~= nil end
local function isBot(m)
    if not m or not m:IsA("Model") then return false end
    if IPM(m) then return false end
    if m:FindFirstChildOfClass("Humanoid") then
        return m:FindFirstChild("HumanoidRootPart") ~= nil or m:FindFirstChild("Head") ~= nil
    end
    local hd = m:FindFirstChild("Head")
    if hd and hd:IsA("BasePart") and (m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso")) then return true end
    local nm = m.Name:lower()
    for _,k in ipairs(BKW) do
        if nm:find(k) then return m:FindFirstChildWhichIsA("BasePart") ~= nil end
    end
    return false
end
local function GR(m) return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso") or m.PrimaryPart or m:FindFirstChild("Head") end
local function GHP(m)
    local h = m:FindFirstChildOfClass("Humanoid")
    if h then return h.Health, h.MaxHealth end
    return 100, 100
end
local function RB()
    if tick()-LBS < 2 and #BC > 0 then return BC end
    LBS = tick(); BC = {}
    local q, n = WS:GetChildren(), 0
    while #q > 0 and n < MAXB do
        local i = table.remove(q); n += 1
        if isBot(i) then BC[#BC+1] = i
        elseif i:IsA("Model") or i:IsA("Folder") then
            for _,c in ipairs(i:GetChildren()) do q[#q+1] = c end
        end
    end
    return BC
end

-- ============================================================
--  COMBATE
-- ============================================================
local skillT = setmetatable({}, {__mode="k"})
local function spamSkills(delay)
    local c = gc(); if not c then return end
    for _,t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local skip = mtc(t.Name, DEF_BLOCK)
            if not skip and os.clock()-(skillT[t] or 0) > delay then
                skillT[t] = os.clock(); sf(function() t:Activate() end)
            end
        end
    end
end
local function click() sf(function() VU:CaptureController(); VU:ClickButton1(Vector2.new()) end) end

task.spawn(function()
    while Rn do
        if S.mobFarm==0 then
            if S.combo==1 then spamSkills(S.comboD); click()
            else
                if S.skill==1 then spamSkills(S.skillD) end
                if S.m1==1 then click() end
            end
        end
        task.wait(S.combo==1 and S.comboD or (S.m1==1 and S.m1D or 0.1))
    end
end)

-- ============================================================
--  FARM DE MOB
-- ============================================================
local function nearestMob(rg)
    local hrp = gr(); if not hrp then return end
    local best, bd
    for _,m in ipairs(RB()) do
        if isBot(m) and mtc(m.Name, toks(S.mobF)) then
            local p = GR(m)
            if p then
                local d = (p.Position-hrp.Position).Magnitude
                if d <= rg and (not bd or d < bd) then best, bd = m, d end
            end
        end
    end
    return best
end

task.spawn(function()
    while Rn do
        if S.mobFarm==1 then
            local mob = nearestMob(S.mobRG)
            if mob then
                local hrp, tp = gr(), mob:FindFirstChild("HumanoidRootPart")
                if S.mobTP==1 and hrp and tp then hrp.CFrame = tp.CFrame*CFrame.new(0,2,5) end
                spamSkills(S.mobDelay)
                if S.mobM1==1 then click() end
            end
        end
        task.wait(S.mobDelay)
    end
end)

ad(RS.Heartbeat:Connect(function()
    if S.vacuum==0 then return end
    local hrp = gr(); if not hrp then return end
    local n = 0
    for _,m in ipairs(RB()) do
        if isBot(m) then
            local p = m:FindFirstChild("HumanoidRootPart")
            if p and (p.Position-hrp.Position).Magnitude <= S.vacRG then
                p.CFrame = hrp.CFrame*CFrame.new(math.random(-4,4),2,math.random(-4,4))
                n += 1; if n > 25 then break end
            end
        end
    end
end))

-- ============================================================
--  PROMPT / CLICKDETECTOR
-- ============================================================
local pC, dC, pT = {}, {}, 0
local function refreshPromptCache()
    local a, b, n = {}, {}, 0
    for _,o in ipairs(WS:GetDescendants()) do
        if o:IsA("ProximityPrompt") then a[#a+1] = o
        elseif o:IsA("ClickDetector") then b[#b+1] = o end
        n += 1; if n > 25000 then break end
    end
    pC, dC, pT = a, b, os.clock()
end
task.spawn(function()
    while Rn do
        if S.quest==1 or S.chest==1 or S.farm==1 or S.stPlant==1 then
            if os.clock()-pT > 2.5 then refreshPromptCache() end
        end
        task.wait(0.5)
    end
end)

local function fireP(pr)
    sf(function()
        if fireproximityprompt then fireproximityprompt(pr)
        else pr.HoldDuration=0; pr:InputHoldBegin(); task.wait(0.04); pr:InputHoldEnd() end
    end)
end
local function runP(filter, rg, lim)
    local hrp = gr(); if not hrp then return 0 end
    local l = toks(filter); local n = 0
    for _,pr in ipairs(pC) do
        local p = pr.Parent
        if pr.Enabled and p and p:IsA("BasePart")
            and (p.Position-hrp.Position).Magnitude <= rg
            and mtc(pr.ActionText.." "..pr.ObjectText, l) then
            fireP(pr); n += 1
            if n >= (lim or 4) then break end
        end
    end
    return n
end

-- ============================================================
--  PIPELINE FARM
-- ============================================================
local function collectTouch()
    local hrp = gr(); if not hrp then return end
    local n = 0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and d.CanTouch and d.Position.Y > -50
            and mtc(d.Name, DEF_COLL)
            and (d.Position-hrp.Position).Magnitude <= S.farmRG then
            local o = hrp.CFrame; hrp.CFrame = d.CFrame
            task.wait(0.02); hrp.CFrame = o
            n += 1; if n >= 5 then break end
        end
    end
end

local lastSell = 0
task.spawn(function()
    while Rn do
        if S.farm==1 then
            if S.stCollect==1 then collectTouch() end
            if S.stHarvest==1 then runP("Harvest,Collect", S.farmRG, 4) end
            if S.stWater==1 then runP("Water", S.farmRG, 2) end
            if S.stBuy==1 then runP("Buy,Purchase", S.sellRG, 1) end
            if S.stHatch==1 then runP("Hatch,Open", S.farmRG, 1) end
            if S.stPlant==1 then runP("Plant,Place", S.farmRG, 4) end
            if S.stSell==1 and S.sellEvery==1 and os.clock()-lastSell > S.sellSec then
                lastSell = os.clock(); runP("Sell,SellAll", S.sellRG, 3)
            end
        end
        task.wait(S.farmInt)
    end
end)

task.spawn(function()
    while Rn do
        if S.quest==1 then runP(S.questF, 40, 2) end
        task.wait(0.8)
    end
end)

-- baú
local chestCd = setmetatable({}, {__mode="k"})
task.spawn(function()
    while Rn do
        if S.chest==1 then
            local hrp = gr()
            if hrp then
                local l = toks(S.chestF)
                for _,d in ipairs(WS:GetDescendants()) do
                    if d:IsA("BasePart") and mtc(d.Name, l)
                        and (d.Position-hrp.Position).Magnitude <= S.chestRG
                        and os.clock()-(chestCd[d] or 0) > 3 then
                        chestCd[d] = os.clock()
                        local o = hrp.CFrame; hrp.CFrame = d.CFrame
                        task.wait(0.15); hrp.CFrame = o
                    end
                end
            end
        end
        task.wait(0.6)
    end
end)

-- fruta
local knownF = setmetatable({}, {__mode="k"})
local lastFNote = 0
task.spawn(function()
    while Rn do
        if S.fruit==1 then
            local hrp = gr(); local l = toks(S.fruitF)
            for _,d in ipairs(WS:GetDescendants()) do
                if d:IsA("BasePart") and mtc(d.Name, l) and not knownF[d] then
                    knownF[d] = true
                    if os.clock()-lastFNote > 1 then
                        lastFNote = os.clock()
                        nt("FRUTA", ("%s a %dm"):format(d.Name, hrp and math.floor((d.Position-hrp.Position).Magnitude) or 0), 8)
                    end
                    if S.fruitTP==1 and hrp then hrp.CFrame = d.CFrame+Vector3.new(0,3,0); task.wait(0.3) end
                end
            end
        end
        task.wait(1.5)
    end
end)

-- pet / equip
task.spawn(function()
    while Rn do
        if S.petEq==1 or S.autoEquip==1 then
            local c, h = gc(), gh()
            local bp = LP:FindFirstChildOfClass("Backpack")
            if c and h then
                local f = S.petEq==1 and toks(S.petF) or toks(S.equipF)
                local eq = c:FindFirstChildOfClass("Tool")
                if not (eq and mtc(eq.Name, f)) and bp then
                    for _,t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and mtc(t.Name, f) then sf(function() h:EquipTool(t) end); break end
                    end
                end
            end
        end
        task.wait(0.8)
    end
end)

-- ============================================================
--  LUTA
-- ============================================================
local function enemyNear(rg)
    local hrp = gr(); if not hrp then return end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local t = p.Character:FindFirstChild("HumanoidRootPart")
            if h and h.Health>0 and t and (t.Position-hrp.Position).Magnitude <= rg then return t end
        end
    end
end

local blockT = 0
task.spawn(function()
    while Rn do
        if S.block==1 and enemyNear(S.blockRG) then
            local c, h = gc(), gh()
            local eq = c and c:FindFirstChildOfClass("Tool")
            if eq and mtc(eq.Name, DEF_BLOCK) then
                if os.clock()-blockT > 1 then blockT = os.clock(); sf(function() eq:Activate() end) end
            elseif c and h then
                for _,t in ipairs(c:GetChildren()) do
                    if t:IsA("Tool") and mtc(t.Name, DEF_BLOCK) then sf(function() h:EquipTool(t) end); break end
                end
            end
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while Rn do
        if S.dodge==1 then
            local hum = gh()
            if hum and enemyNear(30) and hum.Health < hum.MaxHealth*(S.dodgeHP/100) then
                local c = gc()
                if c then
                    for _,t in ipairs(c:GetChildren()) do
                        if t:IsA("Tool") and mtc(t.Name, DEF_BLOCK) then sf(function() t:Activate() end); break end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

local function dashBehind()
    local hrp = gr(); if not hrp then return end
    local best, bd
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and p.Character then
            local t = p.Character:FindFirstChild("HumanoidRootPart")
            if t then
                local d = (t.Position-hrp.Position).Magnitude
                if d <= S.dashRG and (not bd or d < bd) then best, bd = t, d end
            end
        end
    end
    if best then
        hrp.CFrame = best.CFrame*CFrame.new(0,0,4)
        local cam = WS.CurrentCamera
        if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, best.Position) end
    end
end
ad(UIS.InputBegan:Connect(function(i,g) if not g and S.dash==1 and i.KeyCode==Enum.KeyCode.G then dashBehind() end end))

-- kill aura
local kaLast = 0
task.spawn(function()
    while Rn do
        if S.aura==1 then
            local t = gtool(); local hrp = gr()
            if t and hrp then
                for _,m in ipairs(cand("HumanoidRootPart", true, false, true)) do
                    if m.D/1 <= (S.auraRG or 18) then
                        if os.clock()-kaLast > (S.auraCD or 0.45) then
                            kaLast = os.clock()
                            pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(m.P.Position.X,hrp.Position.Y,m.P.Position.Z)) end)
                            sf(function() t:Activate() end)
                        end
                        break
                    end
                end
            end
        end
        task.wait(0.08)
    end
end)

-- ============================================================
--  ESP
-- ============================================================
local ED = {}
local SK15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}}
local SK6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local function DN(cls,pr)
    if not HASD then return nil end
    local ok,o = pcall(DR.new,cls)
    if not ok or not o then return nil end
    for k,v in pairs(pr or {}) do pcall(function() o[k]=v end) end
    o.Visible = false
    return o
end
local function CE(m)
    local s = ED[m]; if not s then return end
    for k,o in pairs(s) do
        if k=="Bo" then for _,b in ipairs(o) do sf(function() b:Remove() end) end
        elseif k~="IB" and o and o.Remove then sf(function() o:Remove() end) end
    end
    ED[m] = nil
end
local function IE(m)
    CE(m)
    local isB = not IPM(m)
    local s = {IB=isB}
    s.Bx=DN("Square",{Thickness=1.2,Filled=false,Color=S.espColor})
    s.Nm=DN("Text",{Size=14,Center=true,Outline=true,Color=S.espColor})
    s.Ds=DN("Text",{Size=12,Center=true,Outline=true,Color=Color3.new(1,1,1)})
    s.Hp=DN("Square",{Thickness=0,Filled=true,Color=Color3.fromRGB(0,255,90)})
    s.Tr=DN("Line",{Thickness=1.4,Color=S.espColor})
    s.Ar=DN("Triangle",{Color=S.espColor})
    s.Hd=DN("Circle",{Thickness=1.5,Radius=5,Filled=false,Color=S.espColor})
    s.Bo={}
    if S.espSkel==1 then
        local h = m:FindFirstChildOfClass("Humanoid")
        local rig = (h and h.RigType==Enum.HumanoidRigType.R15) and SK15 or SK6
        for i=1,#rig do s.Bo[i]=DN("Line",{Thickness=1.2,Color=S.espColor}) end
    end
    ED[m] = s
end
local function HE(s)
    for k,o in pairs(s) do
        if k=="Bo" then for _,b in ipairs(o) do if b then pcall(function() b.Visible=false end) end end
        elseif k~="IB" and o and o.Visible~=nil then pcall(function() o.Visible=false end) end
    end
end
local function RE()
    for m in pairs(ED) do CE(m) end
    if S.esp==0 then return end
    for _,plr in ipairs(P:GetPlayers()) do if plr~=LP and plr.Character then IE(plr.Character) end end
end
local function BIND(plr)
    if plr==LP then return end
    ad(plr.CharacterAdded:Connect(function(ch) task.wait(0.9); if Rn and S.esp==1 then IE(ch) end end))
    if plr.Character and S.esp==1 then IE(plr.Character) end
end
for _,plr in ipairs(P:GetPlayers()) do BIND(plr) end
ad(P.PlayerAdded:Connect(BIND))
ad(P.PlayerRemoving:Connect(function(plr)
    for m in pairs(ED) do if IPM(m) and P:GetPlayerFromCharacter(m)==plr then CE(m) end end
end))
task.spawn(function()
    while Rn do
        task.wait(2)
        if S.esp==1 then
            local snap = {}
            for _,m in ipairs(RB()) do snap[m]=true; if not ED[m] then IE(m) end end
            for m,s in pairs(ED) do if s.IB and (not snap[m] or not m.Parent) then CE(m) end end
        else
            for m,s in pairs(ED) do if s.IB then CE(m) end end
        end
    end
end)

ad(RS.RenderStepped:Connect(function()
    if not HASD or S.esp==0 then return end
    local cam = WS.CurrentCamera; if not cam then return end
    local vp = cam.ViewportSize; local mh = gr()
    for m,s in pairs(ED) do
        local hr = GR(m)
        local hd = m:FindFirstChild("Head")
        local hpv, mx = GHP(m)
        local show = hr and hpv > 0 and (not s.IB or S.esp==1)
        if not show then HE(s)
        else
            local cl, nm
            if s.IB then cl, nm = Color3.fromRGB(255,140,0), "[BOT] "..m.Name
            else
                local plr = P:GetPlayerFromCharacter(m)
                cl = (S.espTeam==1 and LP.Team and plr and plr.Team==LP.Team) and Color3.fromRGB(0,255,120) or S.espColor
                nm = plr and plr.Name or m.Name
            end
            local hdpos = (hd and hd.Position) or (hr.Position+Vector3.new(0,2,0))
            local hp,on = cam:WorldToViewportPoint(hdpos+Vector3.new(0,0.6,0))
            local fp,fo = cam:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
            if on and fo then
                local hh = math.abs(fp.Y-hp.Y); local w = hh*0.55; local cx = hp.X
                if s.Bx then s.Bx.Color=cl; s.Bx.Size=Vector2.new(w,hh); s.Bx.Position=Vector2.new(cx-w/2,hp.Y); s.Bx.Visible=S.espBox==1 end
                if s.Hd then s.Hd.Color=cl; s.Hd.Position=Vector2.new(cx,hp.Y+4); s.Hd.Visible=S.espHead==1 end
                if s.Nm then s.Nm.Color=cl; s.Nm.Text=nm; s.Nm.Position=Vector2.new(cx,hp.Y-16); s.Nm.Visible=S.espName==1 end
                if s.Ds then if mh then s.Ds.Text=math.floor((hr.Position-mh.Position).Magnitude).."m"; s.Ds.Position=Vector2.new(cx,fp.Y+4); s.Ds.Visible=S.espDist==1 else s.Ds.Visible=false end end
                if s.Hp then local r=math.clamp(hpv/math.max(mx,1),0,1); s.Hp.Size=Vector2.new(3,hh*r); s.Hp.Position=Vector2.new(cx-w/2-6,hp.Y+(hh-hh*r)); s.Hp.Visible=S.espHP==1 end
                if s.Tr then if mh then s.Tr.Color=cl; s.Tr.From=Vector2.new(vp.X/2,vp.Y); s.Tr.To=Vector2.new(cx,fp.Y); s.Tr.Visible=S.espTracer==1 else s.Tr.Visible=false end end
                if s.Ar then s.Ar.Visible=false end
                if s.Bo then
                    local h2 = m:FindFirstChildOfClass("Humanoid")
                    local rig = (h2 and h2.RigType==Enum.HumanoidRigType.R15) and SK15 or SK6
                    for i,pr in ipairs(rig) do
                        local b = s.Bo[i]; local p1,p2 = m:FindFirstChild(pr[1]), m:FindFirstChild(pr[2])
                        if b and p1 and p2 then
                            local a,ao = cam:WorldToViewportPoint(p1.Position)
                            local c2,co = cam:WorldToViewportPoint(p2.Position)
                            if ao and co then b.From=Vector2.new(a.X,a.Y); b.To=Vector2.new(c2.X,c2.Y); b.Color=cl; b.Visible=true else b.Visible=false end
                        elseif b then b.Visible=false end
                    end
                end
            else
                HE(s)
                if s.Ar and S.espArrow==1 and hr then
                    local rl = cam.CFrame:PointToObjectSpace(hr.Position)
                    local an = math.atan2(rl.X,-rl.Z)
                    local cx,cy = vp.X/2, vp.Y/2
                    local rr = math.min(vp.X,vp.Y)*0.42
                    local px,py = cx+math.sin(an)*rr, cy-math.cos(an)*rr
                    s.Ar.PointA=Vector2.new(px,py-12); s.Ar.PointB=Vector2.new(px-9,py+9); s.Ar.PointC=Vector2.new(px+9,py+9)
                    s.Ar.Color=cl; s.Ar.Visible=true
                end
            end
        end
    end
end))

-- mob / boss / planta / item
local mobHi, bossHi, plantHi, itemHi = {}, {}, {}, {}
local function clr(t) for _,h in pairs(t) do sf(function() h:Destroy() end) end return {} end
local function scanMob()
    mobHi = clr(mobHi)
    if S.mobEsp==0 then return end
    local l = toks(S.mobFilter); local n=0
    for _,m in ipairs(RB()) do
        if isBot(m) and mtc(m.Name, l) then
            local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(255,70,70); h.FillTransparency=0.55
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=m
            mobHi[#mobHi+1]=h; n+=1; if n>200 then break end
        end
    end
end
local function scanBoss()
    bossHi = clr(bossHi)
    if S.bossEsp==0 then return end
    local l = toks(S.bossF); local n=0
    for _,m in ipairs(WS:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and mtc(m.Name, l) then
            local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(255,215,0); h.FillTransparency=0.4
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=m
            bossHi[#bossHi+1]=h; n+=1; if n>80 then break end
        end
    endend
local function scanPlant()
    plantHi = clr(plantHi)
    if S.plantEsp==0 then return end
    local hrp = gr(); if not hrp then return end
    local l = toks(S.plantFilter); local n=0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("Model") or d:IsA("BasePart") then
            local a = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
            if a and (a.Position-hrp.Position).Magnitude <= S.plantRG then
                local hit = mtc(d.Name, l)
                if not hit then
                    for _,c in ipairs(d:GetChildren()) do
                        if mtc(c.Name, l) then hit=true; break end
                    end
                end
                if hit then
                    local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(255,215,0); h.FillTransparency=0.35
                    h.OutlineColor=Color3.new(1,1,1); h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=d
                    plantHi[#plantHi+1]=h; n+=1; if n>150 then break end
                end
            end
        end
    end
end
local function scanItem()
    itemHi = clr(itemHi)
    if S.itemEsp==0 then return end
    local l = toks("Coin,Gem,Ore,Chest,Egg,Orb"); local n=0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and mtc(d.Name, l) then
            local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(0,255,200); h.FillTransparency=0.45
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=d
            itemHi[#itemHi+1]=h; n+=1; if n>150 then break end
        end
    end
end

-- ============================================================
--  PART FINDER / CHECKPOINT
-- ============================================================
local fHi, cpList = {}, {}
local function clrFind() fHi = clr(fHi) end
local function runFind()
    clrFind()
    if S.partQ=="" then return end
    local q = S.partQ:lower(); local n=0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find(q,1,true) then
            local h = Instance.new("Highlight"); h.FillColor=Color3.fromRGB(0,200,255); h.FillTransparency=0.5
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=d
            fHi[#fHi+1]=h; n+=1; if n>=200 then break end
        end
    end
    nt("Finder", n.." partes.", 3)
end
local function tpFind()
    if S.partQ=="" then return end
    local hrp = gr(); if not hrp then return end
    local b, bd
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find(S.partQ:lower(),1,true) then
            local dd = (d.Position-hrp.Position).Magnitude
            if not bd or dd < bd then b, bd = d, dd end
        end
    end
    if b then hrp.CFrame = b.CFrame+Vector3.new(0,4,0) end
end

-- ============================================================
--  GHOST / XRAY
-- ============================================================
local GSN = setmetatable({}, {__mode="k"}); local GCH
local function restoreGhost()
    for i,pr in pairs(GSN) do
        if i and i.Parent then for k,v in pairs(pr) do pcall(function() i[k]=v end) end end
        GSN[i]=nil
    end
    GCH=nil
end
local function ghostTick()
    local c = gc(); if not c then restoreGhost(); return end
    if GCH~=c then restoreGhost(); GCH=c end
    for _,i in ipairs(c:GetDescendants()) do
        if i:IsA("BasePart") then
            if not GSN[i] then GSN[i]={T=i.Transparency,C=i.CanCollide} end
            i.Transparency=1; i.CanCollide=false
        elseif i:IsA("Decal") or i:IsA("Texture") then
            if not GSN[i] then GSN[i]={T=i.Transparency} end
            i.Transparency=1
        end
    end
end
local xOrig = setmetatable({}, {__mode="k"})
task.spawn(function()
    while Rn do
        if S.ghost==1 then ghostTick() elseif next(GSN) then restoreGhost() end
        if S.xray==1 then
            local n=0
            for _,d in ipairs(WS:GetDescendants()) do
                if d:IsA("BasePart") and not d:IsDescendantOf(gc() or LP) and not xOrig[d] then
                    xOrig[d]=d.Transparency; d.Transparency=0.85; n+=1; if n>4000 then break end
                end
            end
        elseif next(xOrig) then
            for p,t in pairs(xOrig) do sf(function() p.Transparency=t end) end
            xOrig = setmetatable({}, {__mode="k"})
        end
        task.wait(S.ghost==1 and 0.25 or 1)
    end
end)

-- ============================================================
--  MOVIMENTO
-- ============================================================
local flyBV, flyBG, flyY = nil, nil, 0
local function stopFly()
    if flyBV then sf(function() flyBV:Destroy() end); flyBV=nil end
    if flyBG then sf(function() flyBG:Destroy() end); flyBG=nil end
end
local function startFly()
    local hrp = gr(); if not hrp then return end
    stopFly()
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(9e9,9e9,9e9); flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9); flyBG.P=9000; flyBG.D=500
end
ad(RS.RenderStepped:Connect(function()
    local cam = WS.CurrentCamera; if not cam then return end
    if S.fly==1 and flyBV and flyBG then
        local hum = gh()
        local dir = (hum and hum.MoveDirection*S.flySP) or Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.Space) or flyY==1 then dir = dir+Vector3.new(0,S.flySP,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or flyY==-1 then dir = dir-Vector3.new(0,S.flySP,0) end
        flyBV.Velocity = dir; flyBG.CFrame = cam.CFrame
    end
    if S.noclip==1 then
        local c = gc()
        if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end
end))
ad(LP.CharacterAdded:Connect(function()
    task.wait(0.6); flyBV, flyBG = nil, nil
    if Rn and S.fly==1 then startFly() end
end))

local plat
ad(RS.Stepped:Connect(function()
    local hrp = gr(); if not hrp then return end
    if S.platform==1 then
        if not plat or not plat.Parent then
            plat = Instance.new("Part")
            plat.Anchored=true; plat.CanCollide=true; plat.CanTouch=false; plat.CanQuery=false
            plat.Transparency=0.55; plat.Material=Enum.Material.ForceField
            plat.Color=Color3.fromRGB(170,0,255); plat.Parent=WS
        end
        plat.Size = Vector3.new(S.platSize,1,S.platSize)
        plat.CFrame = CFrame.new(hrp.Position-Vector3.new(0,3.4,0))
    elseif plat then plat:Destroy(); plat=nil end

    if S.bhop==1 then
        local h = gh()
        if h and h:GetState()==Enum.HumanoidStateType.Landed and h.MoveDirection.Magnitude>0 then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if S.hover==1 then
        local h = gh()
        if h and h:GetState()~=Enum.HumanoidStateType.Landed then
            local v = hrp.AssemblyLinearVelocity
            if math.abs(v.Y)>2 and flyY==0 then hrp.AssemblyLinearVelocity = Vector3.new(v.X,0,v.Z) end
        end
    end
end))

ad(UIS.JumpRequest:Connect(function()
    if S.infJump==1 then local h=gh(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end))

ad(UIS.TouchTap:Connect(function(pos)
    if S.clickTP==0 then return end
    local objs = UIS:GetGuiObjectsAtPosition(pos.X,pos.Y)
    for _,o in ipairs(objs) do if o:IsA("GuiObject") and o.Visible and o.AbsoluteSize.Magnitude>1 then return end end
    local cam = WS.CurrentCamera; local hrp = gr()
    if not cam or not hrp then return end
    local ray = cam:ScreenPointToRay(pos.X,pos.Y)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {gc(), plat}
    local hit = WS:Raycast(ray.Origin, ray.Direction*2000, rp)
    if hit then hrp.CFrame = CFrame.new(hit.Position+Vector3.new(0,4,0)) end
end))

-- ============================================================
--  SERVIDOR / WAYPOINTS
-- ============================================================
local function httpGet(u)
    local ok,r = pcall(function()
        if syn and syn.request then return syn.request({Url=u,Method="GET"}).Body end
        if request then return request({Url=u,Method="GET"}).Body end
        return game:HttpGet(u)
    end)
    if ok then return r end
end
local function hop()
    nt("Hop","Procurando...",3)
    local b = httpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
    if not b then nt("Hop","API falhou.",3); return end
    local ok,data = pcall(function() return HS:JSONDecode(b) end)
    if not ok or not data or not data.data then return end
    local pool = {}
    for _,s in ipairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then pool[#pool+1] = s.id end
    end
    if #pool==0 then nt("Hop","Nenhum servidor.",3); return end
    sf(function() TS:TeleportToPlaceInstance(game.PlaceId, pool[math.random(#pool)], LP) end)
end

local WPF = "VeniceHub_wp.json"
local wp = {}
sf(function() if isfile and isfile(WPF) then wp = HS:JSONDecode(readfile(WPF)) end end)
local function saveWp() sf(function() if writefile then writefile(WPF, HS:JSONEncode(wp)) end end) end

-- ============================================================
--  PAINEL
-- ============================================================
local pg = LP:WaitForChild("PlayerGui")
for _,n in ipairs({"VeniceTouch","VeniceRadar","VeniceList","VeniceWM","VeniceCross"}) do
    local o = pg:FindFirstChild(n); if o then sf(function() o:Destroy() end) end
end

local gui = Instance.new("ScreenGui")
gui.Name="VeniceTouch"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=2147483647; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=pg
local F = Instance.new("Frame")
F.Size=UDim2.new(0,210,0,352); F.AnchorPoint=Vector2.new(1,0.5)
F.Position=UDim2.new(1,-14,0.5,0); F.BackgroundColor3=Color3.fromRGB(16,12,24)
F.BackgroundTransparency=0.08; F.BorderSizePixel=0; F.Active=true; F.ZIndex=50; F.Parent=gui
Instance.new("UICorner",F).CornerRadius=UDim.new(0,14)
local stroke = Instance.new("UIStroke",F); stroke.Color=Color3.fromRGB(170,0,255); stroke.Thickness=1.5
local HD = Instance.new("TextButton")
HD.Size=UDim2.new(1,0,0,28); HD.BackgroundColor3=Color3.fromRGB(170,0,255); HD.BackgroundTransparency=0.28
HD.Text="  VENICE APEX"; HD.TextColor3=Color3.new(1,1,1); HD.Font=Enum.Font.GothamBold
HD.TextSize=12; HD.TextXAlignment=Enum.TextXAlignment.Left; HD.BorderSizePixel=0; HD.ZIndex=60; HD.Parent=F
Instance.new("UICorner",HD).CornerRadius=UDim.new(0,14)
local BODY = Instance.new("Frame")
BODY.Size=UDim2.new(1,-8,1,-36); BODY.Position=UDim2.new(0,4,0,32)
BODY.BackgroundTransparency=1; BODY.BorderSizePixel=0; BODY.ZIndex=55; BODY.Parent=F
local GL = Instance.new("UIGridLayout",BODY)
GL.CellSize=UDim2.new(0.5,-5,0,29); GL.CellPadding=UDim2.new(0,5,0,5)
GL.Padding=UDim.new(0,6); GL.SortOrder=Enum.SortOrder.LayoutOrder

local dg, ds, sp
ad(HD.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dg=true; ds=i.Position; sp=F.Position
    end
end))
ad(UIS.InputChanged:Connect(function(i)
    if dg and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local d=i.Position-ds; F.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end))
ad(UIS.InputEnded:Connect(function() dg=false end))

local function mk(txt,ord,bg)
    local b = Instance.new("TextButton")
    b.LayoutOrder=ord; b.BackgroundColor3=bg or Color3.fromRGB(38,28,54)
    b.Text=txt; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold
    b.TextSize=12; b.BorderSizePixel=0; b.ZIndex=56; b.Parent=BODY
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end
local function tgl(txt,ord,key,after)
    local b = mk(txt,ord)
    local function pt() b.BackgroundColor3 = S[key]==1 and Color3.fromRGB(170,0,255) or Color3.fromRGB(38,28,54) end
    pt()
    b.MouseButton1Click:Connect(function() S[key]=1-S[key]; if after then sf(after) end; pt() end)
end
local function hold(txt,ord,val)
    local b = mk(txt,ord,Color3.fromRGB(52,38,72))
    local function dn() flyY=val; b.BackgroundColor3=Color3.fromRGB(170,0,255) end
    local function up() if flyY==val then flyY=0 end; b.BackgroundColor3=Color3.fromRGB(52,38,72) end
    b.MouseButton1Down:Connect(dn); b.MouseButton1Up:Connect(up); b.MouseLeave:Connect(up)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dn() end end)
    b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then up() end end)
end

tgl("AIM",1,"aim")
tgl("SILENT",2,"silent")
tgl("ESP",3,"esp",RE)
tgl("AURA",4,"aura")
tgl("FLY",5,"fly",function() if S.fly==1 then startFly() else stopFly() end end)
tgl("NOCLIP",6,"noclip")
tgl("GHOST",7,"ghost")
tgl("FARM",8,"farm")
tgl("MOBFARM",9,"mobFarm")
tgl("COMBO",10,"combo")
tgl("RADAR",11,"radar")
tgl("SPEED",12,"speed")
hold("▲",13,1)
hold("▼",14,-1)
local dashBtn = mk("DASH",15); dashBtn.MouseButton1Click:Connect(function() sf(dashBehind) end)

local reBtn = Instance.new("TextButton")
reBtn.Size=UDim2.new(0,48,0,48); reBtn.AnchorPoint=Vector2.new(1,0.5)
reBtn.Position=UDim2.new(1,-10,0.5,0); reBtn.BackgroundColor3=Color3.fromRGB(170,0,255)
reBtn.Text="V"; reBtn.TextColor3=Color3.new(1,1,1); reBtn.Font=Enum.Font.GothamBold
reBtn.TextSize=18; reBtn.BorderSizePixel=0; reBtn.Visible=false; reBtn.ZIndex=70; reBtn.Parent=gui
Instance.new("UICorner",reBtn).CornerRadius=UDim.new(1,0)
local function setPanel(v) F.Visible=v; reBtn.Visible=not v end
reBtn.MouseButton1Click:Connect(function() setPanel(true) end)
local minB = mk("MIN",16,Color3.fromRGB(80,18,18)); minB.MouseButton1Click:Connect(function() setPanel(false) end)

task.defer(function()
    task.wait(0.4)
    if #BODY:GetChildren() <= 1 then
        GL:Destroy()
        local ll = Instance.new("UIListLayout",BODY); ll.Padding=UDim.new(0,5)
        for _,c in ipairs(BODY:GetChildren()) do if c:IsA("TextButton") then c.Size=UDim2.new(1,0,0,29) end end
        nt("Painel","Modo lista.",4)
    end
end)

-- ============================================================
--  RADAR / LISTA / WATERMARK
-- ============================================================
local rGui = Instance.new("ScreenGui")
rGui.Name="VeniceRadar"; rGui.ResetOnSpawn=false; rGui.DisplayOrder=998; rGui.Parent=pg
local RF = Instance.new("Frame")
RF.Size=UDim2.new(0,140,0,140); RF.Position=UDim2.new(0,12,1,-160)
RF.BackgroundColor3=Color3.fromRGB(10,10,14); RF.BackgroundTransparency=0.25
RF.BorderSizePixel=0; RF.Visible=false; RF.Parent=rGui
Instance.new("UICorner",RF).CornerRadius=UDim.new(1,0)
local rs2 = Instance.new("UIStroke",RF); rs2.Color=Color3.fromRGB(170,0,255)
local dots = {}
ad(RS.RenderStepped:Connect(function()
    RF.Visible = S.radar==1
    if S.radar==0 then return end
    local mh, cam = gr(), WS.CurrentCamera
    if not mh or not cam then return end
    local yw = math.atan2(cam.CFrame.LookVector.X, -cam.CFrame.LookVector.Z)
    local snap = {}
    local function dot(m, col)
        local rt = GR(m); if not rt then return end
        local d = dots[m]
        if not d then
            d = Instance.new("Frame"); d.Size=UDim2.new(0,7,0,7)
            d.BackgroundColor3=col; d.BorderSizePixel=0; d.Parent=RF
            Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); dots[m]=d
        end
        snap[m]=true
        local rl = rt.Position-mh.Position
        local an = math.atan2(rl.X,-rl.Z)-yw
        local ds2 = rl.Magnitude
        if ds2 <= S.radarRG then
            local r = (ds2/S.radarRG)*63
            d.Position=UDim2.new(0.5,math.sin(an)*r-3.5,0.5,-math.cos(an)*r-3.5); d.Visible=true
        else d.Visible=false end
    end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and p.Character then dot(p.Character, Color3.fromRGB(255,60,60)) end
    end
    if S.radarBot==1 then
        for _,m in ipairs(RB()) do dot(m, Color3.fromRGB(255,150,0)) end
    end
    for m,d in pairs(dots) do if not snap[m] or not m.Parent then d:Destroy(); dots[m]=nil end end
end))

local lGui = Instance.new("ScreenGui")
lGui.Name="VeniceList"; lGui.ResetOnSpawn=false; lGui.DisplayOrder=997; lGui.Parent=pg
local LF = Instance.new("Frame")
LF.Size=UDim2.new(0,190,0,220); LF.Position=UDim2.new(1,-206,0,88)
LF.BackgroundColor3=Color3.fromRGB(12,12,18); LF.BackgroundTransparency=0.2
LF.BorderSizePixel=0; LF.Visible=false; LF.Parent=lGui
Instance.new("UICorner",LF).CornerRadius=UDim.new(0,10)
local LT = Instance.new("TextLabel")
LT.Size=UDim2.new(1,0,0,24); LT.BackgroundColor3=Color3.fromRGB(170,0,255); LT.BackgroundTransparency=0.4
LT.Text="  ALVOS"; LT.TextColor3=Color3.new(1,1,1); LT.Font=Enum.Font.GothamBold
LT.TextSize=11; LT.TextXAlignment=Enum.TextXAlignment.Left; LT.Parent=LF
local SL = Instance.new("ScrollingFrame")
SL.Size=UDim2.new(1,-8,1,-32); SL.Position=UDim2.new(0,4,0,28)
SL.BackgroundTransparency=1; SL.BorderSizePixel=0; SL.ScrollBarThickness=3; SL.Parent=LF
local LL = Instance.new("UIListLayout",SL); LL.Padding=UDim.new(0,2)
ad(LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SL.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+6)
end))
task.spawn(function()
    while Rn do
        LF.Visible = S.list==1
        if S.list==1 then
            for _,c in ipairs(SL:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
            local mh = gr()
            for _,p in ipairs(P:GetPlayers()) do
                if p~=LP then
                    local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    local hr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local d = (hr and mh) and math.floor((hr.Position-mh.Position).Magnitude) or 0
                    local l = Instance.new("TextLabel")
                    l.Size=UDim2.new(1,0,0,17); l.BackgroundTransparency=1
                    l.Font=Enum.Font.Gotham; l.TextSize=11
                    l.TextXAlignment=Enum.TextXAlignment.Left; l.TextColor3=Color3.new(1,1,1)
                    l.Text=("  %s  %s  %dm"):format(p.Name, h and math.floor(h.Health) or "?", d); l.Parent=SL
                end
            end
            for _,m in ipairs(RB()) do
                local hpv = select(1,GHP(m)); local rt = GR(m)
                local d = (rt and mh) and math.floor((rt.Position-mh.Position).Magnitude) or 0
                local l = Instance.new("TextLabel")
                l.Size=UDim2.new(1,0,0,17); l.BackgroundTransparency=1
                l.Font=Enum.Font.Gotham; l.TextSize=11
                l.TextXAlignment=Enum.TextXAlignment.Left; l.TextColor3=Color3.fromRGB(255,150,0)
                l.Text=("  [B] %s  %d  %dm"):format(m.Name, math.floor(hpv), d); l.Parent=SL
            end
        end
        task.wait(1.5)
    end
end)

local wGui = Instance.new("ScreenGui")
wGui.Name="VeniceWM"; wGui.ResetOnSpawn=false; wGui.IgnoreGuiInset=true
wGui.DisplayOrder=996; wGui.Parent=pg
local WM = Instance.new("TextLabel")
WM.Size=UDim2.new(0,400,0,20); WM.Position=UDim2.new(0,10,0,6)
WM.BackgroundTransparency=1; WM.Font=Enum.Font.GothamBold; WM.TextSize=13
WM.TextXAlignment=Enum.TextXAlignment.Left; WM.TextColor3=Color3.fromRGB(170,0,255)
WM.TextStrokeTransparency=0.5; WM.Text="venice apex"; WM.Parent=wGui
task.spawn(function()
    local frames = 0
    ad(RS.RenderStepped:Connect(function() frames += 1 end))
    while Rn do
        task.wait(1)
        local ping = "?"
        sf(function() ping = math.floor(STA.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        WM.Visible = S.watermark==1
        WM.Text=("venice apex v5  |  %d fps  |  %s ms  |  %.0f MB  |  %d kicks  |  %d rj")
            :format(frames, ping, gcinfo()/1024, stats.kicks, stats.rejoins)
        frames = 0
    end
end))

-- ============================================================
--  ABAS
-- ============================================================
local TProt = W:CreateTab("Proteção",4483362458)
local TAim  = W:CreateTab("Tiro",4483362458)
local TFarm = W:CreateTab("Farm",4483362458)
local TAnime= W:CreateTab("Anime",4483362458)
local TEsp  = W:CreateTab("ESP",4483362458)
local TMove = W:CreateTab("Movimento",4483362458)
local TWorld= W:CreateTab("Mundo",4483362458)
local TSys  = W:CreateTab("Sistema",4483362458)

local function off()
    S.aim=0; S.silent=0; S.esp=0; RE(); S.ghost=0; S.xray=0; S.farm=0; S.mobFarm=0
    S.skill=0; S.m1=0; S.combo=0; S.aura=0; S.fly=0; stopFly(); S.noclip=0
    S.radar=0; S.list=0; S.platform=0; S.hitbox=0; S.trig=0; S.rapid=0
    S.mobEsp=0; scanMob(); S.itemEsp=0; scanItem(); S.plantEsp=0; scanPlant()
    S.petEq=0; S.autoEquip=0; S.vacuum=0; S.quest=0; S.chest=0; S.fruit=0
    clrFind(); nt("Sistema","Tudo desligado.",3)
end

-- PROTEÇÃO
TProt:CreateParagraph({Title="Camadas ativas: "..LAYERS,
    Content="Kick interceptado por 3 vias, watchdog de congelamento, verificação de integridade a cada 6s e detecção de ban por palavra-chave."})
TProt:CreateToggle({Name="Anti-kick",CurrentValue=true,Callback=function(v) S.kick=v and 1 or 0 end})
TProt:CreateToggle({Name="Auto-rejoin",CurrentValue=true,Callback=function(v) S.rejoin=v and 1 or 0 end})
TProt:CreateSlider({Name="Delay do rejoin",Range={0.5,10},Increment=0.5,CurrentValue=2,Callback=function(v) S.rjDelay=v end})
TProt:CreateSlider({Name="Limite de rejoins",Range={1,40},Increment=1,CurrentValue=12,Callback=function(v) S.maxRJ=v end})
TProt:CreateToggle({Name="Parar se detectar ban",CurrentValue=true,Callback=function(v) S.banStop=v and 1 or 0 end})
TProt:CreateToggle({Name="Watchdog",CurrentValue=true,Callback=function(v) S.watchdog=v and 1 or 0 end})
TProt:CreateToggle({Name="Verificar integridade dos hooks",CurrentValue=true,Callback=function(v) S.integrity=v and 1 or 0 end})
TProt:CreateSection("Anti-trollagem")
TProt:CreateToggle({Name="Anti-void",CurrentValue=true,Callback=function(v) S.void=v and 1 or 0 end})
TProt:CreateSlider({Name="Altura do anti-void",Range={-500,0},Increment=10,CurrentValue=-80,Callback=function(v) S.voidY=v end})
TProt:CreateToggle({Name="Anti-fling",CurrentValue=true,Callback=function(v) S.fling=v and 1 or 0 end})
TProt:CreateToggle({Name="Anti-teleporte",CurrentValue=false,Callback=function(v) S.antiTP=v and 1 or 0 end})
TProt:CreateSlider({Name="Sensibilidade anti-TP",Range={20,300},Increment=10,CurrentValue=70,Callback=function(v) S.tpThr=v end})
TProt:CreateToggle({Name="Anti-freeze",CurrentValue=true,Callback=function(v) S.freeze=v and 1 or 0 end})
TProt:CreateToggle({Name="Anti-slow",CurrentValue=true,Callback=function(v) S.slow=v and 1 or 0 end})
TProt:CreateSlider({Name="Piso de velocidade",Range={8,100},Increment=1,CurrentValue=14,Callback=function(v) S.slowF=v end})
TProt:CreateToggle({Name="Anti-jump-lock",CurrentValue=true,Callback=function(v) S.jlock=v and 1 or 0 end})
TProt:CreateSlider({Name="Piso de pulo",Range={20,200},Increment=5,CurrentValue=45,Callback=function(v) S.jumpF=v end})
TProt:CreateToggle({Name="Anti-ragdoll",CurrentValue=true,Callback=function(v) S.ragdoll=v and 1 or 0 end})
TProt:CreateToggle({Name="Anti-AFK",CurrentValue=true,Callback=function(v) S.afk=v and 1 or 0 end})
TProt:CreateToggle({Name="Anti-crash",CurrentValue=true,Callback=function(v) S.crash=v and 1 or 0 end})
TProt:CreateSlider({Name="Limite de memória",Range={600,4000},Increment=100,CurrentValue=1400,Callback=function(v) S.mem=v end})
TProt:CreateToggle({Name="Respawn automático",CurrentValue=false,Callback=function(v) S.autospawn=v and 1 or 0 end})
TProt:CreateSection("Anti-detecção")
TProt:CreateToggle({Name="Modo stealth (jitter)",CurrentValue=false,Callback=function(v) S.stealth=v and 1 or 0 end})
TProt:CreateToggle({Name="Modo conservador",CurrentValue=false,Callback=function(v)
    S.conservative=v and 1 or 0
    if v then S.speedV=40; S.jumpV=60; S.noclip=0; nt("Conservador","Valores seguros aplicados.",4) end
end})
TProt:CreateSection("Log de kicks")
KLBL = TProt:CreateLabel("nenhum kick")

-- TIRO
TAim:CreateSection("Aimbot")
TAim:CreateToggle({Name="Aimbot",CurrentValue=false,Callback=function(v) S.aim=v and 1 or 0 end})
TAim:CreateSlider({Name="FOV",Range={20,600},Increment=5,CurrentValue=140,Callback=function(v) S.aimFOV=v end})
TAim:CreateSlider({Name="Suavidade",Range={0.03,1},Increment=0.03,CurrentValue=0.18,Callback=function(v) S.aimSm=v end})
TAim:CreateDropdown({Name="Modo",Options={"Mais próximo","Menor vida","Prioritário"},CurrentValue="Mais próximo",Callback=function(v) S.aimMode=v end})
TAim:CreateDropdown({Name="Parte",Options={"Head","HumanoidRootPart","UpperTorso"},CurrentValue="Head",Callback=function(v) S.aimPart=v end})
TAim:CreateToggle({Name="Predição",CurrentValue=false,Callback=function(v) S.aimPred=v and 1 or 0 end})
TAim:CreateToggle({Name="Travar alvo",CurrentValue=false,Callback=function(v) S.aimLock=v and 1 or 0 end})
TAim:CreateToggle({Name="Checar time",CurrentValue=true,Callback=function(v) S.aimTeam=v and 1 or 0 end})
TAim:CreateToggle({Name="Checar parede",CurrentValue=false,Callback=function(v) S.aimWall=v and 1 or 0 end})
TAim:CreateToggle({Name="Círculo de FOV",CurrentValue=true,Callback=function(v) S.aimCircle=v and 1 or 0 end})
TAim:CreateSection("Silent")
TAim:CreateToggle({Name="Silent aim",CurrentValue=false,Callback=function(v) S.silent=v and 1 or 0 end})
TAim:CreateSlider({Name="FOV silent",Range={20,800},Increment=10,CurrentValue=230,Callback=function(v) S.silFOV=v end})
TAim:CreateToggle({Name="Assist (anime)",CurrentValue=false,Callback=function(v) S.assist=v and 1 or 0 end})
TAim:CreateSection("Extras")
TAim:CreateToggle({Name="No-recoil",CurrentValue=false,Callback=function(v) S.norecoil=v and 1 or 0 end})
TAim:CreateToggle({Name="Trigger bot",CurrentValue=false,Callback=function(v) S.trig=v and 1 or 0 end})
TAim:CreateSlider({Name="FOV trigger",Range={5,200},Increment=5,CurrentValue=42,Callback=function(v) S.trigFOV=v end})
TAim:CreateToggle({Name="Rapid fire",CurrentValue=false,Callback=function(v) S.rapid=v and 1 or 0 end})
TAim:CreateToggle({Name="Hitbox",CurrentValue=false,Callback=function(v) S.hitbox=v and 1 or 0 end})
TAim:CreateSlider({Name="Tamanho hitbox",Range={2,20},Increment=1,CurrentValue=6,Callback=function(v) S.hbSize=v end})
TAim:CreateToggle({Name="Terceira pessoa",CurrentValue=false,Callback=function(v) S.third=v and 1 or 0 end})
TAim:CreateToggle({Name="Crosshair",CurrentValue=false,Callback=function(v)
    S.crosshair=v and 1 or 0
    local c = pg:FindFirstChild("VeniceCross")
    if v and not c then
        local g2 = Instance.new("ScreenGui"); g2.Name="VeniceCross"; g2.ResetOnSpawn=false
        g2.IgnoreGuiInset=true; g2.DisplayOrder=995; g2.Parent=pg
        local a = Instance.new("Frame"); a.Size=UDim2.new(0,18,0,2); a.Position=UDim2.new(0.5,-9,0.5,-1)
        a.BackgroundColor3=Color3.fromRGB(0,255,140); a.BorderSizePixel=0; a.Parent=g2
        local b = a:Clone(); b.Size=UDim2.new(0,2,0,18); b.Position=UDim2.new(0.5,-1,0.5,-9); b.Parent=g2
    elseif not v and c then c:Destroy() end
end})

-- FARM
TFarm:CreateParagraph({Title="Pipeline",Content="Coleta, colhe, rega, vende e replanta no raio. Venda tem raio próprio."})
TFarm:CreateToggle({Name="FARM",CurrentValue=false,Callback=function(v) S.farm=v and 1 or 0 end})
TFarm:CreateSlider({Name="Raio de ação",Range={8,120},Increment=2,CurrentValue=22,Callback=function(v) S.farmRG=v end})
TFarm:CreateSlider({Name="Raio de venda",Range={20,300},Increment=10,CurrentValue=70,Callback=function(v) S.sellRG=v end})
TFarm:CreateSlider({Name="Intervalo",Range={0.15,2},Increment=0.05,CurrentValue=0.35,Callback=function(v) S.farmInt=v end})
TFarm:CreateSection("Etapas")
TFarm:CreateToggle({Name="Coletar",CurrentValue=true,Callback=function(v) S.stCollect=v and 1 or 0 end})
TFarm:CreateToggle({Name="Colher",CurrentValue=true,Callback=function(v) S.stHarvest=v and 1 or 0 end})
TFarm:CreateToggle({Name="Regar",CurrentValue=true,Callback=function(v) S.stWater=v and 1 or 0 end})
TFarm:CreateToggle({Name="Plantar",CurrentValue=true,Callback=function(v) S.stPlant=v and 1 or 0 end})
TFarm:CreateToggle({Name="Comprar",CurrentValue=false,Callback=function(v) S.stBuy=v and 1 or 0 end})
TFarm:CreateToggle({Name="Chocar ovo",CurrentValue=false,Callback=function(v) S.stHatch=v and 1 or 0 end})
TFarm:CreateToggle({Name="Vender",CurrentValue=true,Callback=function(v) S.stSell=v and 1 or 0 end})
TFarm:CreateSlider({Name="Vender a cada (s)",Range={10,300},Increment=5,CurrentValue=60,Callback=function(v) S.sellSec=v end})
TFarm:CreateButton({Name="Vender agora",Callback=function() runP("Sell,SellAll", S.sellRG, 3) end})
TFarm:CreateButton({Name="Reescanear",Callback=refreshPromptCache})
TFarm:CreateSection("Pet")
TFarm:CreateToggle({Name="Auto equipar pet",CurrentValue=false,Callback=function(v) S.petEq=v and 1 or 0 end})
TFarm:CreateInput({Name="Filtro pet",CurrentValue="Pet",Callback=function(v) S.petF=v end})

-- ANIME
TAnime:CreateSection("Farm de mob")
TAnime:CreateToggle({Name="Auto farm mob",CurrentValue=false,Callback=function(v) S.mobFarm=v and 1 or 0 end})
TAnime:CreateInput({Name="Filtro de mob",CurrentValue="Bandit,Monkey,Pirate,Soldier,Brute",Callback=function(v) S.mobF=v end})
TAnime:CreateSlider({Name="Alcance",Range={10,150},Increment=5,CurrentValue=45,Callback=function(v) S.mobRG=v end})
TAnime:CreateSlider({Name="Delay de skill",Range={0.15,1.5},Increment=0.05,CurrentValue=0.4,Callback=function(v) S.mobDelay=v end})
TAnime:CreateToggle({Name="TP no mob",CurrentValue=true,Callback=function(v) S.mobTP=v and 1 or 0 end})
TAnime:CreateToggle({Name="M1 junto",CurrentValue=true,Callback=function(v) S.mobM1=v and 1 or 0 end})
TAnime:CreateToggle({Name="Vacuum",CurrentValue=false,Callback=function(v) S.vacuum=v and 1 or 0 end})
TAnime:CreateSlider({Name="Raio vacuum",Range={10,80},Increment=5,CurrentValue=40,Callback=function(v) S.vacRG=v end})
TAnime:CreateSection("Quest / baú / fruta")
TAnime:CreateToggle({Name="Auto quest",CurrentValue=false,Callback=function(v) S.quest=v and 1 or 0 end})
TAnime:CreateToggle({Name="Farm de baú",CurrentValue=false,Callback=function(v) S.chest=v and 1 or 0 end})
TAnime:CreateSlider({Name="Alcance baú",Range={20,200},Increment=10,CurrentValue=60,Callback=function(v) S.chestRG=v end})
TAnime:CreateToggle({Name="Sniper de fruta",CurrentValue=false,Callback=function(v) S.fruit=v and 1 or 0 end})
TAnime:CreateToggle({Name="TP na fruta",CurrentValue=false,Callback=function(v) S.fruitTP=v and 1 or 0 end})
TAnime:CreateToggle({Name="ESP de boss",CurrentValue=false,Callback=function(v) S.bossEsp=v and 1 or 0; scanBoss() end})
TAnime:CreateSection("Luta")
TAnime:CreateToggle({Name="Skill spam",CurrentValue=false,Callback=function(v) S.skill=v and 1 or 0 end})
TAnime:CreateToggle({Name="M1 spam",CurrentValue=false,Callback=function(v) S.m1=v and 1 or 0 end})
TAnime:CreateToggle({Name="Modo combo",CurrentValue=false,Callback=function(v) S.combo=v and 1 or 0 end})
TAnime:CreateToggle({Name="Auto block",CurrentValue=false,Callback=function(v) S.block=v and 1 or 0 end})
TAnime:CreateToggle({Name="Auto dodge",CurrentValue=false,Callback=function(v) S.dodge=v and 1 or 0 end})
TAnime:CreateToggle({Name="Dash pelas costas",CurrentValue=false,Callback=function(v) S.dash=v and 1 or 0 end})

-- ESP
TEsp:CreateToggle({Name="ESP",CurrentValue=false,Callback=function(v) S.esp=v and 1 or 0; RE() end})
TEsp:CreateToggle({Name="Caixa",CurrentValue=false,Callback=function(v) S.espBox=v and 1 or 0 end})
TEsp:CreateToggle({Name="Esqueleto",CurrentValue=false,Callback=function(v) S.espSkel=v and 1 or 0; RE() end})
TEsp:CreateToggle({Name="Nome",CurrentValue=false,Callback=function(v) S.espName=v and 1 or 0 end})
TEsp:CreateToggle({Name="Distância",CurrentValue=false,Callback=function(v) S.espDist=v and 1 or 0 end})
TEsp:CreateToggle({Name="Vida",CurrentValue=false,Callback=function(v) S.espHP=v and 1 or 0 end})
TEsp:CreateToggle({Name="Tracer",CurrentValue=false,Callback=function(v) S.espTracer=v and 1 or 0 end})
TEsp:CreateToggle({Name="Seta fora de tela",CurrentValue=false,Callback=function(v) S.espArrow=v and 1 or 0 end})
TEsp:CreateToggle({Name="Ponto na cabeça",CurrentValue=false,Callback=function(v) S.espHead=v and 1 or 0 end})
TEsp:CreateToggle({Name="Cor por time",CurrentValue=false,Callback=function(v) S.espTeam=v and 1 or 0 end})
TEsp:CreateDropdown({Name="Cor",Options={"Roxo","Verde","Vermelho","Ciano","Branco","Amarelo"},CurrentValue="Roxo",
    Callback=function(v)
        local m={Roxo=Color3.fromRGB(170,0,255),Verde=Color3.fromRGB(0,255,120),Vermelho=Color3.fromRGB(255,40,40),
                 Ciano=Color3.fromRGB(0,220,255),Branco=Color3.fromRGB(255,255,255),Amarelo=Color3.fromRGB(255,220,0)}
        S.espColor=m[v] or Color3.fromRGB(170,0,255); RE()
    end})
TEsp:CreateSection("Mob / planta / item")
TEsp:CreateToggle({Name="ESP de mob",CurrentValue=false,Callback=function(v) S.mobEsp=v and 1 or 0; scanMob() end})
TEsp:CreateInput({Name="Filtro mob",CurrentValue="Zombie,Monster,Boss",Callback=function(v) S.mobFilter=v end})
TEsp:CreateToggle({Name="Plant ESP",CurrentValue=false,Callback=function(v) S.plantEsp=v and 1 or 0; scanPlant() end})
TEsp:CreateInput({Name="Filtro mutação",CurrentValue="Mutation,Gold,Rainbow",Callback=function(v) S.plantFilter=v end})
TEsp:CreateSlider({Name="Raio plant ESP",Range={20,400},Increment=10,CurrentValue=120,Callback=function(v) S.plantRG=v end})
TEsp:CreateToggle({Name="Item ESP",CurrentValue=false,Callback=function(v) S.itemEsp=v and 1 or 0; scanItem() end})
TEsp:CreateButton({Name="Reescanear",Callback=function() scanMob(); scanPlant(); scanItem(); scanBoss() end})

-- MOVIMENTO
TMove:CreateSlider({Name="Velocidade",Range={16,300},Increment=1,CurrentValue=50,Callback=function(v) S.speedV=v end})
TMove:CreateToggle({Name="Speed hack",CurrentValue=false,Callback=function(v) S.speed=v and 1 or 0 end})
TMove:CreateSlider({Name="Pulo",Range={50,500},Increment=5,CurrentValue=100,Callback=function(v) S.jumpV=v end})
TMove:CreateToggle({Name="Jump power",CurrentValue=false,Callback=function(v) S.jump=v and 1 or 0 end})
TMove:CreateToggle({Name="Pulo infinito",CurrentValue=false,Callback=function(v) S.infJump=v and 1 or 0 end})
TMove:CreateToggle({Name="Noclip",CurrentValue=false,Callback=function(v) S.noclip=v and 1 or 0 end})
TMove:CreateToggle({Name="Godmode",CurrentValue=false,Callback=function(v)
    S.god=v and 1 or 0
    if not v then local h=gh(); if h then h.MaxHealth=100; h.Health=100 end end
end})
TMove:CreateToggle({Name="Fly",CurrentValue=false,Callback=function(v) S.fly=v and 1 or 0; if v then startFly() else stopFly() end end})
TMove:CreateSlider({Name="Velocidade fly",Range={10,300},Increment=5,CurrentValue=55,Callback=function(v) S.flySP=v end})
TMove:CreateToggle({Name="Plataforma no ar",CurrentValue=false,Callback=function(v) S.platform=v and 1 or 0 end})
TMove:CreateSlider({Name="Tamanho plataforma",Range={2,20},Increment=1,CurrentValue=6,Callback=function(v) S.platSize=v end})
TMove:CreateToggle({Name="Bunny hop",CurrentValue=false,Callback=function(v) S.bhop=v and 1 or 0 end})
TMove:CreateToggle({Name="Hover",CurrentValue=false,Callback=function(v) S.hover=v and 1 or 0 end})
TMove:CreateToggle({Name="Ghost",CurrentValue=false,Callback=function(v) S.ghost=v and 1 or 0 end})
TMove:CreateToggle({Name="Spin bot",CurrentValue=false,Callback=function(v) S.spin=v and 1 or 0 end})
TMove:CreateSlider({Name="Velocidade spin",Range={1,40},Increment=1,CurrentValue=10,Callback=function(v) S.spinV=v end})
TMove:CreateToggle({Name="Click TP",CurrentValue=false,Callback=function(v) S.clickTP=v and 1 or 0 end})
TMove:CreateButton({Name="Resetar",Callback=function() local h=gh(); if h then h.Health=0 end end})
TMove:CreateButton({Name="Restaurar vida",Callback=function() local h=gh(); if h then h.Health=h.MaxHealth end end})
TMove:CreateSection("Seguir")
local FDR
FDR = TMove:CreateDropdown({Name="Jogador",Options={"Nenhum"},CurrentValue="Nenhum",Callback=function(v) S.orbitT=v; S.glueT=v end})
TMove:CreateToggle({Name="Órbita",CurrentValue=false,Callback=function(v) S.orbit=v and 1 or 0 end})
TMove:CreateSlider({Name="Raio órbita",Range={3,30},Increment=1,CurrentValue=8,Callback=function(v) S.orbitR=v end})
TMove:CreateToggle({Name="Grudar",CurrentValue=false,Callback=function(v) S.glue=v and 1 or 0 end})
local oa = 0
ad(RS.RenderStepped:Connect(function(dt)
    local hrp = gr(); if not hrp then return end
    if S.orbit==1 and S.orbitT then
        local t = P:FindFirstChild(S.orbitT)
        local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        if tr then oa=(oa+dt)%(math.pi*2); hrp.CFrame = tr.CFrame*CFrame.new(math.cos(oa)*S.orbitR,S.orbitH,math.sin(oa)*S.orbitR) end
    elseif S.glue==1 and S.glueT then
        local t = P:FindFirstChild(S.glueT)
        local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        if tr then hrp.CFrame = tr.CFrame*CFrame.new(0,3,3) end
    elseif S.spin==1 then
        hrp.CFrame = hrp.CFrame*CFrame.Angles(0,math.rad(S.spinV)*dt,0)
    end
end))
local function refreshDrop()
    local l = {"Nenhum"}
    for _,p in ipairs(P:GetPlayers()) do if p~=LP then l[#l+1]=p.Name end end
    pcall(function() FDR:Refresh(l) end)
end
ad(P.PlayerAdded:Connect(function() task.wait(1) refreshDrop() end))
ad(P.PlayerRemoving:Connect(function() task.wait(1) refreshDrop() end))

-- MUNDO
TWorld:CreateSection("Part finder")
TWorld:CreateInput({Name="Nome da parte",CurrentValue="",Callback=function(v) S.partQ=v end})
TWorld:CreateButton({Name="Destacar",Callback=runFind})
TWorld:CreateButton({Name="TP para a mais próxima",Callback=tpFind})
TWorld:CreateButton({Name="Limpar destaques",Callback=clrFind})
TWorld:CreateSection("Checkpoint")
TWorld:CreateButton({Name="Salvar checkpoint",Callback=function()
    local hrp = gr(); if hrp then cpList[#cpList+1]=hrp.CFrame; nt("Checkpoint",#cpList.." salvo(s).",3) end
end})
TWorld:CreateButton({Name="Voltar ao checkpoint",Callback=function()
    local hrp = gr(); local cf = cpList[#cpList]
    if hrp and cf then hrp.CFrame = cf+Vector3.new(0,3,0) end
end})
TWorld:CreateSection("Waypoints")
local WDR
WDR = TWorld:CreateDropdown({Name="Waypoint",Options={"Nenhum"},CurrentValue="Nenhum"})
local wpName = ""
TWorld:CreateInput({Name="Nome",CurrentValue="",Callback=function(v) wpName=v end})
TWorld:CreateButton({Name="Salvar posição",Callback=function()
    local hrp = gr(); if not hrp or wpName=="" then return end
    wp[wpName] = {hrp.Position.X,hrp.Position.Y,hrp.Position.Z}; saveWp()
    local l = {"Nenhum"}; for k in pairs(wp) do l[#l+1]=k end
    pcall(function() WDR:Refresh(l) end); nt("Waypoint",wpName.." salvo.",3)
end})
TWorld:CreateButton({Name="Ir para waypoint",Callback=function()
    local w = wp[wpName]; local hrp = gr()
    if w and hrp then hrp.CFrame = CFrame.new(w[1],w[2]+3,w[3]) end
end})
TWorld:CreateSection("Mapa")
TWorld:CreateButton({Name="Ancorar tudo",Callback=function()
    local n=0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored and not d:IsDescendantOf(gc() or LP) then
            d.Anchored=true; n+=1; if n>3000 then break end
        end
    end
    nt("Mapa",n.." ancoradas.",3)
end})
TWorld:CreateButton({Name="Desancorar tudo",Callback=function()
    local n=0
    for _,d in ipairs(WS:GetDescendants()) do
        if d:IsA("BasePart") and d.Anchored then d.Anchored=false; n+=1; if n>3000 then break end
    end
    nt("Mapa",n.." soltas.",3)
end})
TWorld:CreateButton({Name="Tocar partes próximas",Callback=function()
    local hrp = gr(); if not hrp then return end
    task.spawn(function()
        for _,d in ipairs(WS:GetDescendants()) do
            if d:IsA("BasePart") and d.CanTouch and (d.Position-hrp.Position).Magnitude<60 then
                local o = hrp.CFrame; hrp.CFrame = d.CFrame; task.wait(0.03); hrp.CFrame = o
            end
        end
    end)
end})

-- SISTEMA
TSys:CreateSection("Servidor")
TSys:CreateButton({Name="Server hop",Callback=hop})
TSys:CreateButton({Name="Rejoin",Callback=function() sf(function() TS:Teleport(game.PlaceId, LP) end) end})
TSys:CreateButton({Name="Copiar JobId",Callback=function() sf(function() setclipboard(game.JobId) end); nt("Servidor","Copiado.",3) end})
local jobIn = ""
TSys:CreateInput({Name="JobId",CurrentValue="",Callback=function(v) jobIn=v end})
TSys:CreateButton({Name="Entrar no JobId",Callback=function()
    if jobIn~="" then sf(function() TS:TeleportToPlaceInstance(game.PlaceId, jobIn, LP) end) end
end})
TSys:CreateSection("Remote")
TSys:CreateToggle({Name="Remote spy",CurrentValue=false,Callback=function(v) SPY=v and 1 or 0 end})
SLBL = TSys:CreateLabel("—")
TSys:CreateSection("Chat")
local spam = {E=0,T="gg",D=3}
local function say(m)
    sf(function()
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion==Enum.ChatVersion.TextChatService then
            local ch = tcs:FindFirstChild("TextChannels")
            local g = ch and ch:FindFirstChild("RBXGeneral")
            if g then g:SendAsync(m) end
        else
            local ev = RS2:FindFirstChild("DefaultChatSystemChatEvents")
            local sr = ev and ev:FindFirstChild("SayMessageRequest")
            if sr then sr:FireServer(m,"All") end
        end
    end)
end
task.spawn(function()
    while Rn do
        if spam.E==1 and spam.T~="" then say(spam.T) end
        task.wait(math.max(1,spam.D))
    end
end)
TSys:CreateToggle({Name="Chat spammer",CurrentValue=false,Callback=function(v) spam.E=v and 1 or 0 end})
TSys:CreateInput({Name="Mensagem",CurrentValue="gg",Callback=function(v) spam.T=v end})
TSys:CreateSection("Overlay")
TSys:CreateToggle({Name="Radar",CurrentValue=false,Callback=function(v) S.radar=v and 1 or 0 end})
TSys:CreateSlider({Name="Alcance radar",Range={30,500},Increment=10,CurrentValue=150,Callback=function(v) S.radarRG=v end})
TSys:CreateToggle({Name="Radar inclui bots",CurrentValue=false,Callback=function(v) S.radarBot=v and 1 or 0 end})
TSys:CreateToggle({Name="Lista de alvos",CurrentValue=false,Callback=function(v) S.list=v and 1 or 0 end})
TSys:CreateToggle({Name="Watermark",CurrentValue=true,Callback=function(v) S.watermark=v and 1 or 0 end})
TSys:CreateSection("Presets")
TSys:CreateButton({Name="FPS competitivo",Callback=function()
    S.silent=1; S.aim=1; S.aimSm=0.12; S.esp=1; S.espBox=1; S.espName=1
    S.espDist=1; S.hitbox=1; S.trig=1; S.aimWall=0; RE()
    nt("Preset","FPS aplicado.",4)
end})
TSys:CreateButton({Name="Farm/Garden",Callback=function()
    S.farm=1; S.petEq=1; S.plantEsp=1; S.itemEsp=1; scanPlant(); scanItem()
    nt("Preset","Farm aplicado.",4)
end})
TSys:CreateButton({Name="Anime RPG",Callback=function()
    S.mobFarm=1; S.quest=1; S.chest=1; S.fruit=1; S.mobEsp=1; scanMob()
    nt("Preset","Anime aplicado.",4)
end})
TSys:CreateButton({Name="Anime PvP",Callback=function()
    S.aura=1; S.hitbox=1; S.hbSize=9; S.block=1; S.dodge=1; S.aim=1
    nt("Preset","PvP aplicado.",4)
end})
TSys:CreateSection("Keybinds")
TSys:CreateKeybind({Name="Aimbot",CurrentValue="Q",Callback=function() S.aim=1-S.aim end})
TSys:CreateKeybind({Name="ESP",CurrentValue="X",Callback=function() S.esp=1-S.esp; RE() end})
TSys:CreateKeybind({Name="Farm",CurrentValue="F",Callback=function() S.farm=1-S.farm end})
TSys:CreateKeybind({Name="Mob farm",CurrentValue="R",Callback=function() S.mobFarm=1-S.mobFarm end})
TSys:CreateKeybind({Name="Dash",CurrentValue="G",Callback=dashBehind})
TSys:CreateKeybind({Name="Ghost",CurrentValue="C",Callback=function() S.ghost=1-S.ghost end})
TSys:CreateKeybind({Name="Pânico",CurrentValue="P",Callback=off})
TSys:CreateSection("Script")
TSys:CreateButton({Name="Desligar tudo",Callback=off})
TSys:CreateButton({Name="Unload completo",Callback=function()
    if not Rn then return end
    off(); Rn = false
    restoreGhost()
    for _,c in ipairs(Cs) do sf(function() c:Disconnect() end) end
    table.clear(Cs)
    for m in pairs(ED) do CE(m) end
    clr(mobHi); clr(bossHi); clr(plantHi); clr(itemHi); clrFind()
    for m,d in pairs(dots) do sf(function() d:Destroy() end) dots[m]=nil end
    if FC then sf(function() FC:Remove() end) FC=nil end
    if plat then plat:Destroy() end
    sf(function() gui:Destroy() end); sf(function() rGui:Destroy() end)
    sf(function() lGui:Destroy() end); sf(function() wGui:Destroy() end)
    local cx = pg:FindFirstChild("VeniceCross"); if cx then cx:Destroy() end
    sf(function() Rayfield:Destroy() end)
    getgenv().VeniceLoaded = nil
end})

-- ============================================================
--  BOOT
-- ============================================================
local function refreshAllDrops()
    local l = {"Nenhum"}
    for _,p in ipairs(P:GetPlayers()) do if p~=LP then l[#l+1]=p.Name end end
    pcall(function() FDR:Refresh(l) end)
    local l2 = {"Nenhum"}
    for k in pairs(wp) do l2[#l2+1]=k end
    pcall(function() WDR:Refresh(l2) end)
end
refreshAllDrops()
refreshPromptCache()
setPanel(true)

local function BRSP(ch)
    local h = ch and ch:FindFirstChildOfClass("Humanoid")
    if not h then return end
    ad(h.Died:Connect(function()
        if not Rn or S.autospawn==0 then return end
        task.wait(0.4)
        if not sf(function() LP:LoadCharacter() end) then
            local c = gc(); if c then sf(function() c:BreakJoints() end) end
        end
    end))
end
ad(LP.CharacterAdded:Connect(function(ch) task.wait(0.5); if Rn then BRSP(ch) end end))
if LP.Character then BRSP(LP.Character) end

getgenv().VeniceLoaded = function() sf(function() Rayfield:Destroy() end) end
nt("Venice APEX v5", LAYERS:sub(1,60), 8)