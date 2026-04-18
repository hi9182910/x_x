getgenv().LPH_NO_VIRTUALIZE = function(f) return f end


    local Players = game:GetService("Players")
    local rs = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local localPlayer = Players.LocalPlayer
    local camera = Workspace.CurrentCamera
    local mouse = localPlayer:GetMouse()

    local GunHandler = require(ReplicatedStorage.Modules.GunHandler)
    local OriginalGetAim = GunHandler.getAim
    local targetPlayer = nil
    local camLockActive = false
    local camLockHold = false
    local camLockTarget = nil
    local triggerBotActive = false
    local triggerHold = false
    local camFOVCircle = nil
    local deadzoneCircle = nil
    local leftCtrlHeld = false
    local rightClickHeld = false
    local selectPressed = false
    local camPressed = false
    local triggerPressed = false
    local speedPressed = false
    local silentBox = nil      
    local triggerBox = nil    


    local ShotgunNames = { ["Double-Barrel SG"]=true, ["TacticalShotgun"]=true, ["Shotgun"]=true, ["DrumShotgun"]=true }
    local PistolNames = { ["Revolver"]=true, ["Silencer"]=true, ["Glock"]=true }

    local knifeData = {}

    local knifeSkins = {
        ["Golden Age Tanto"] = {soundid = "rbxassetid://5917819099", animationid = "rbxassetid://13473404819", positionoffset = Vector3.new(0, -0.20, -1.2), rotationoffset = Vector3.new(90, 263.7, 180)},
        ["GPO-Knife"] = {soundid = "rbxassetid://4604390759", animationid = "rbxassetid://14014278925", positionoffset = Vector3.new(0.00, -0.32, -1.07), rotationoffset = Vector3.new(90, -97.4, 90)},
        ["GPO-Knife Prestige"] = {soundid = "rbxassetid://4604390759", animationid = "rbxassetid://14014278925", positionoffset = Vector3.new(0.00, -0.32, -1.07), rotationoffset = Vector3.new(90, -97.4, 90)},
        ["Heaven"] = {soundid = "rbxassetid://14489860007", animationid = "rbxassetid://14500266726", positionoffset = Vector3.new(-0.02, -0.82, 0.20), rotationoffset = Vector3.new(64.42, 3.79, 0.00)},
        ["Love Kukri"] = {soundid = "", animationid = "", positionoffset = Vector3.new(-0.14, 0.14, -1.62), rotationoffset = Vector3.new(-90.00, 180.00, -4.97), particle = true, textureid = "rbxassetid://12124159284"},
        ["Purple Dagger"] = {soundid = "rbxassetid://17822743153", animationid = "rbxassetid://17824999722", positionoffset = Vector3.new(-0.13, -0.24, -1.80), rotationoffset = Vector3.new(89.05, 96.63, 180.00)},
        ["Blue Dagger"] = {soundid = "rbxassetid://17822737046", animationid = "rbxassetid://17824995184", positionoffset = Vector3.new(-0.13, -0.24, -1.80), rotationoffset = Vector3.new(89.05, 96.63, 180.00)},
        ["Green Dagger"] = {soundid = "rbxassetid://17822741762", animationid = "rbxassetid://17825004320", positionoffset = Vector3.new(-0.13, -0.24, -1.07), rotationoffset = Vector3.new(89.05, 96.63, 180.00)},
        ["Red Dagger"] = {soundid = "rbxassetid://17822952417", animationid = "rbxassetid://17825008844", positionoffset = Vector3.new(-0.13, -0.24, -1.07), rotationoffset = Vector3.new(89.05, 96.63, 180.00)},
        ["Portal"] = {soundid = "rbxassetid://16058846352", animationid = "rbxassetid://16058633881", positionoffset = Vector3.new(-0.13, -0.35, -0.57), rotationoffset = Vector3.new(89.05, 96.63, 180.00)},
        ["Emerald Butterfly"] = {soundid = "rbxassetid://14931902491", animationid = "rbxassetid://14918231706", positionoffset = Vector3.new(-0.02, -0.30, -0.65), rotationoffset = Vector3.new(180.00, 90.95, 180.00)},
        ["Boy"] = {soundid = "rbxassetid://18765078331", animationid = "rbxassetid://18789158908", positionoffset = Vector3.new(-0.02, -0.09, -0.73), rotationoffset = Vector3.new(89.05, -88.11, 180.00)},
        ["Girl"] = {soundid = "rbxassetid://18765078331", animationid = "rbxassetid://18789162944", positionoffset = Vector3.new(-0.02, -0.16, -0.73), rotationoffset = Vector3.new(89.05, -88.11, 180.00)},
        ["Dragon"] = {soundid = "rbxassetid://14217789230", animationid = "rbxassetid://14217804400", positionoffset = Vector3.new(-0.02, -0.32, -0.98), rotationoffset = Vector3.new(89.05, 90.95, 180.00)},
        ["Void"] = {soundid = "rbxassetid://14756591763", animationid = "rbxassetid://14774699952", positionoffset = Vector3.new(-0.02, -0.22, -0.85), rotationoffset = Vector3.new(180.00, 90.95, 180.00)},
        ["Wild West"] = {soundid = "rbxassetid://16058689026", animationid = "rbxassetid://16058148839", positionoffset = Vector3.new(-0.02, -0.24, -1.15), rotationoffset = Vector3.new(-91.89, 90.95, 180.00)},
        ["Iced Out"] = {soundid = "rbxassetid://14924261405", animationid = "rbxassetid://18465353361", positionoffset = Vector3.new(0.02, -0.08, 0.99), rotationoffset = Vector3.new(180.00, -90.95, -180.00)},
        ["Reptile"] = {soundid = "rbxassetid://18765103349", animationid = "rbxassetid://18788955930", positionoffset = Vector3.new(-0.03, -0.06, -0.92), rotationoffset = Vector3.new(168.63, 90.00, -180.00)},
        ["Emerald"] = {soundid = "", animationid = "", positionoffset = Vector3.new(-0.14, -0.06, -0.92), rotationoffset = Vector3.new(168.63, 90.00, 108.00)},
        ["Ribbon"] = {soundid = "rbxassetid://130974579277249", animationid = "rbxassetid://124102609796063", positionoffset = Vector3.new(0.02, -0.25, -0.05), rotationoffset = Vector3.new(90.00, 0.00, 180.00)},
        ["Red Tiger"] = {soundid = "", animationid = "", positionoffset = Vector3.new(-0.13, -0.25, -1.14), rotationoffset = Vector3.new(168.63, 90.00, 108.00)},
        ["Golden"] = {soundid = "", animationid = "", positionoffset = Vector3.new(-0.13, -0.25, -1.14), rotationoffset = Vector3.new(-90.00, 180.00, -4.97), particle = true},
    }

    local r15 = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }

    local function getPredictedPosition(character, hitPoint)
        return hitPoint and hitPoint.Position or Vector3.zero
    end



    local function applyFakeHeadless(character)
        if not character then return end
        local head = character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
            if face then
                face:Destroy()
            end
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh:Destroy()
            end
        end
    end

    local function applyFakeKorblox(character)
        if not character then return end
        
        local rightUpper = character:FindFirstChild("RightUpperLeg")
        local rightLower = character:FindFirstChild("RightLowerLeg")
        local rightFoot = character:FindFirstChild("RightFoot")

        local function createMeshPart(parent, meshId, textureId)
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Transparency = 0
            part.CanCollide = false
            part.Anchored = true
            part.Parent = character

            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = meshId
            if textureId then mesh.TextureId = textureId end
            mesh.Scale = Vector3.new(0.69, 1.2, 0.69)
            mesh.Offset = Vector3.new(0, 0.25, 0)
            mesh.Parent = part

            rs.RenderStepped:Connect(function()
                if parent and part then
                    part.CFrame = parent.CFrame
                end
            end)

            return part
        end

        if rightUpper then
            rightUpper.Transparency = 1
            createMeshPart(rightUpper, "http://www.roblox.com/asset/?id=902942096", "http://www.roblox.com/asset/?id=902843398")
        end

        if rightLower then
            rightLower.Transparency = 1
        end

        if rightFoot then
            rightFoot.Transparency = 1
        end
    end

    local function applyFakeCosmetics(character)
        if not character then return end
        
        if shared['x_x'].Extras['Headless'] then
            applyFakeHeadless(character)
        end
        
        if shared['x_x'].Extras['Korblox'] then
            applyFakeKorblox(character)
        end
    end

    if localPlayer.Character then
        applyFakeCosmetics(localPlayer.Character)
    end

    localPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head", 10)
        char:WaitForChild("HumanoidRootPart", 10)
        applyFakeCosmetics(char)
    end)


    task.spawn(LPH_NO_VIRTUALIZE(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local CommunityID = 17215700  

        local function checkMod(Player)
            if shared['x_x']   and shared['x_x']  .Extras and shared['x_x']  .Extras["Mod Detector"] then
                if Player ~= LocalPlayer and Player:IsInGroup(CommunityID) then
                    LocalPlayer:Kick("A moderator has joined the game!")
                    return true
                end
            end
            return false
        end

        for _, Player in ipairs(Players:GetPlayers()) do
            if checkMod(Player) then break end
        end

        Players.PlayerAdded:Connect(function(Player)
            task.wait() 
            checkMod(Player)
        end)
    end))


    local function getWeaponCategory()
        local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool then return "Others" end
        local name = tool.Name:gsub("[%[%]]", "")
        if ShotgunNames[name] then return "Shotguns"
        elseif PistolNames[name] then return "Pistols"
        else return "Others" end
    end

    local function getCameraSmoothness(distance)
        local camCfg = shared['x_x']['Camera Aimbot']
        if not camCfg then
            return 0.5, 0.5  
        end

        local smoothing = camCfg['Smoothing']
        if not smoothing or not smoothing['Range Smoothing'] or not smoothing['Range Smoothing'].Enabled then
            return smoothing and smoothing.X or 0.5, smoothing and smoothing.Y or 0.5
        end

        local rangeCfg = smoothing['Range Smoothing']

        if distance <= 30 then
            return rangeCfg.Close.X, rangeCfg.Close.Y
        elseif distance <= 80 then
            return rangeCfg.Medium.X, rangeCfg.Medium.Y
        else
            return rangeCfg.Far.X, rangeCfg.Far.Y
        end
    end

    local function getSplitFOV(section)
        local fovData = shared['x_x'][section].FOV
        local mode = fovData['FOV Mode'] or "Advanced"

        local result = { simple = (mode == "Simple") }

        local base = mode == "Simple" and fovData.Simple or fovData.Advanced

        local wc = fovData["Weapon Configuration"]
        local useWC = wc and wc.Enabled
        local cat = useWC and getWeaponCategory() or nil
        local weapon = useWC and (wc[cat] or wc.Others) or nil

        if mode == "Simple" then
            local simpleBase = base or { ['X'] = 6, ['Y'] = 6, ['Z'] = 6 }
            local simpleWeapon = weapon and weapon.Simple

            result.x = (simpleWeapon and simpleWeapon['X']) or simpleBase['X']
            result.y = (simpleWeapon and simpleWeapon['Y']) or simpleBase['Y']
            result.z = (simpleWeapon and simpleWeapon['Z']) or simpleBase['Z']
        else
            local advBase = base or { ["X Left"]=6, ["X Right"]=6, ["Y Upper"]=6, ["Y Lower"]=6, ["Z Left"]=6, ["Z Right"]=6 }
            local advWeapon = weapon and weapon.Advanced

            result.xLeft  = (advWeapon and advWeapon["X Right"])  or advBase["X Right"]
            result.xRight = (advWeapon and advWeapon["X Left"]) or advBase["X Left"]
            result.yUpper = (advWeapon and advWeapon["Y Upper"]) or advBase["Y Upper"]
            result.yLower = (advWeapon and advWeapon["Y Lower"]) or advBase["Y Lower"]
            result.zLeft  = (advWeapon and advWeapon["Z Right"])  or advBase["Z Right"]
            result.zRight = (advWeapon and advWeapon["Z Left"]) or advBase["Z Left"]
        end

        return result
    end

local function ExactPoint(character)
	if not character then return nil end

	local mousePos = UserInputService:GetMouseLocation()
	local camRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local origin = camRay.Origin
	local dir = camRay.Direction
	local dirLen = dir.Magnitude
	if dirLen < 1e-12 then return nil end
	dir = dir / dirLen

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Whitelist
	params.FilterDescendantsInstances = { character }
	params.IgnoreWater = true

	local function isIgnored(inst: Instance): boolean
		return inst.Name == "Handle"
			or inst:FindFirstAncestorOfClass("Accessory") ~= nil
			or inst:FindFirstAncestorOfClass("Tool") ~= nil
	end

	local function validHit(res)
		return res and res.Instance and res.Instance:IsDescendantOf(character) and not isIgnored(res.Instance)
	end

	local direct = workspace:Raycast(origin, dir * 5000, params)
	if validHit(direct) then
		return { Part = direct.Instance, Position = direct.Position }
	end

	local function closestSurfacePointOBBToRay(part: BasePart): (Vector3?, number?)
		local cf = part.CFrame
		local half = part.Size * 0.5
		local hx, hy, hz = half.X, half.Y, half.Z

		local o = cf:PointToObjectSpace(origin)
		local d = cf:VectorToObjectSpace(dir)
		local dLen = d.Magnitude
		if dLen < 1e-12 then return nil end
		d = d / dLen

		local function clampBox(p: Vector3): Vector3
			return Vector3.new(
				math.clamp(p.X, -hx, hx),
				math.clamp(p.Y, -hy, hy),
				math.clamp(p.Z, -hz, hz)
			)
		end

		local function pushToSurfaceIfInside(q: Vector3): Vector3
			local ax, ay, az = math.abs(q.X), math.abs(q.Y), math.abs(q.Z)
			if ax < hx and ay < hy and az < hz then
				local adx, ady, adz = math.abs(d.X), math.abs(d.Y), math.abs(d.Z)
				if adx >= ady and adx >= adz then
					return Vector3.new((d.X >= 0) and -hx or hx, q.Y, q.Z)
				elseif ady >= adz then
					return Vector3.new(q.X, (d.Y >= 0) and -hy or hy, q.Z)
				else
					return Vector3.new(q.X, q.Y, (d.Z >= 0) and -hz or hz)
				end
			end
			return q
		end

		local candidates = { 0, (-o):Dot(d) }

		local function addAxis(oA: number, dA: number, hA: number)
			if math.abs(dA) < 1e-12 then return end
			table.insert(candidates, (-hA - oA) / dA)
			table.insert(candidates, ( hA - oA) / dA)
		end

		addAxis(o.X, d.X, hx)
		addAxis(o.Y, d.Y, hy)
		addAxis(o.Z, d.Z, hz)

		local bestKey = math.huge
		local bestQW = nil

		for _, t in ipairs(candidates) do
			if t >= 0 then
				local p = o + d * t
				local q = pushToSurfaceIfInside(clampBox(p))
				local qW = cf:PointToWorldSpace(q)

				local proj = dir:Dot(qW - origin)
				if proj > 0.01 then
					local lateral = (qW - (origin + dir * proj)).Magnitude
					local key = (lateral / proj)
					if key < bestKey then
						bestKey = key
						bestQW = qW
					end
				end
			end
		end

		return bestQW, bestKey
	end

	local function tryRedirectToPoint(p: Vector3)
		local v = p - origin
		local dist = v.Magnitude
		if dist < 1e-6 then return nil end
		local res = workspace:Raycast(origin, v, params)
		if validHit(res) then
			return { Part = res.Instance, Position = res.Position }
		end
		return nil
	end

	local K = 6
	local candPoints = table.create(K)
	local candKeys = table.create(K)
	local candCount = 0

	local function pushCandidate(p: Vector3, key: number)
		if candCount < K then
			candCount += 1
			candPoints[candCount] = p
			candKeys[candCount] = key
		else
			local worstI = 1
			local worstK = candKeys[1]
			for i = 2, K do
				if candKeys[i] > worstK then
					worstK = candKeys[i]
					worstI = i
				end
			end
			if key < worstK then
				candPoints[worstI] = p
				candKeys[worstI] = key
			end
		end
	end

	for _, inst in ipairs(character:GetDescendants()) do
		if inst:IsA("BasePart") and not isIgnored(inst) then
			local p, key = closestSurfacePointOBBToRay(inst)
			if p and key then
				pushCandidate(p, key)
			end
		end
	end

	for i = 1, candCount - 1 do
		local bestI = i
		local bestK = candKeys[i]
		for j = i + 1, candCount do
			if candKeys[j] < bestK then
				bestK = candKeys[j]
				bestI = j
			end
		end
		if bestI ~= i then
			candKeys[i], candKeys[bestI] = candKeys[bestI], candKeys[i]
			candPoints[i], candPoints[bestI] = candPoints[bestI], candPoints[i]
		end
	end

	for i = 1, candCount do
		local out = tryRedirectToPoint(candPoints[i])
		if out then
			return out
		end
	end

	return nil
end

    local function CenterPoint(character)
        if not character then return nil end

        local mousePos = UserInputService:GetMouseLocation()

        local bestSq, bestPos, bestPart = math.huge, nil, nil

        for _, name in ipairs(r15) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                local halfY = part.Size.Y * 0.5
                local cf = part.CFrame

                for i = 1, 15 do
                    local t = (i - 1) / 14
                    local localY = (t * 2 - 1) * halfY
                    localY = math.clamp(localY, -halfY, halfY)
                    local localPos = Vector3.new(0, localY, 0)
                    local world = cf * localPos

                    local screen = camera:WorldToViewportPoint(world)
                    if screen.Z > 0 then
                        local dx = screen.X - mousePos.X
                        local dy = screen.Y - mousePos.Y
                        local dsq = dx * dx + dy * dy
                        if dsq < bestSq then
                            bestSq = dsq
                            bestPos = world
                            bestPart = part
                        end
                    end
                end
            end
        end

        if bestPos then
            return { Part = bestPart, Position = bestPos }
        end

        return nil
    end

   local function AllPoint(character)
	if not character then return nil end
	
	local mousePos = UserInputService:GetMouseLocation()
	local bestSq = math.huge
	local bestPos = nil
	local bestPart = nil
	local cam = workspace.CurrentCamera
	
	local points = 35
	
	for _, partName in ipairs(r15) do
		local part = character:FindFirstChild(partName)
		if not part or not part:IsA("BasePart") then continue end
		
		local cf = part.CFrame
		local size = part.Size
		
		local stepsX = 4
		local stepsY = 5
		local stepsZ = 1
		
		if stepsX * stepsY * stepsZ > points then
			stepsZ = 1
			stepsY = 5
			stepsX = math.ceil(points / stepsY)
		end
		
		for ix = 0, stepsX - 1 do
			for iy = 0, stepsY - 1 do
				for iz = 0, stepsZ - 1 do
					local tX = stepsX > 1 and (ix / (stepsX - 1)) * 2 - 1 or 0
					local tY = stepsY > 1 and (iy / (stepsY - 1)) * 2 - 1 or 0
					local tZ = stepsZ > 1 and (iz / (stepsZ - 1)) * 2 - 1 or 0
					
					local localPos = Vector3.new(
						tX * size.X * 0.5,
						tY * size.Y * 0.5,
						tZ * size.Z * 0.5
					)
					
					local worldPos = cf * localPos
					
					local screen, onScreen = cam:WorldToViewportPoint(worldPos)
					
					if onScreen and screen.Z > 0 then
						local dx = screen.X - mousePos.X
						local dy = screen.Y - mousePos.Y
						local distSq = dx * dx + dy * dy
						
						if distSq < bestSq then
							bestSq = distSq
							bestPos = worldPos
							bestPart = part
						end
					end
				end
			end
		end
	end
	
	if bestPos then
		return {
			Part = bestPart,
			Position = bestPos
		}
	end
	
	return nil
end

    local function getClosestHitPoint(character, isCamlock, usePredictionForAim)
        local section = isCamlock and shared['x_x']['Camera Aimbot'] or shared['x_x']['Silent Aimbot']
        local HitPoint = section['Hit Point']
        
        if shared['x_x']['Targeting']['Target Mode'] == "Select" and shared['x_x']['Select Only Features']['Force Redirect'] then
            local force = shared['x_x']['Select Only Features']['Force Redirect Part']
            if force == "Head" then
                local head = character:FindFirstChild("Head")
                if head then return {Part = head, Position = head.Position} end
            elseif force == "Body" then
                local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart")
                if upper then return {Part = upper, Position = upper.Position} end
            elseif force == "Random" then
                local parts = {}
                for _, name in {"Head","UpperTorso","LowerTorso","HumanoidRootPart"} do
                    local p = character:FindFirstChild(name)
                    if p then table.insert(parts, p) end
                end
                if #parts > 0 then
                    local p = parts[math.random(#parts)]
                    return {Part = p, Position = p.Position}
                end
            end
        end

        local hit
        
        if HitPoint == "Exact" then
            hit = ExactPoint(character)
        elseif HitPoint == "Center" then
            hit = CenterPoint(character)
        elseif HitPoint == "All" then          
            hit = AllPoint(character)
        else
            local part = character:FindFirstChild(HitPoint)
            hit = part and {Part = part, Position = part.Position}
        end
        
        if not hit then return nil end
        
        local finalPos = hit.Position
        
        return {Part = hit.Part, Position = finalPos}
    end

    local function isMouseInBoxFOV(section)
        if not targetPlayer or not targetPlayer.Character then return false end
        local char = targetPlayer.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return false end

        local boxPos = root.Position

        local fov = getSplitFOV(section)
        local look = root.CFrame.LookVector
        local facing = CFrame.lookAt(Vector3.new(), Vector3.new(look.X, 0, look.Z))

        local size, offset
        if fov.simple then
            size = Vector3.new(fov.x, fov.y, fov.z)
            offset = Vector3.new(0, 0, 0)
        else
            size = Vector3.new(fov.xLeft + fov.xRight, fov.yUpper + fov.yLower, fov.zLeft + fov.zRight)
            offset = Vector3.new((fov.xRight - fov.xLeft) / 2, (fov.yUpper - fov.yLower) / 2, (fov.zRight - fov.zLeft) / 2)
        end

        local worldOffset = facing:VectorToWorldSpace(offset)
        local boxCFrame = CFrame.new(boxPos + worldOffset) * facing

        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local localOrigin = boxCFrame:PointToObjectSpace(ray.Origin)
        local localDir = boxCFrame:VectorToObjectSpace(ray.Direction)
        local halfSize = size * 0.5

        local tMin, tMax = 0, math.huge
        for _, axis in ipairs({"X", "Y", "Z"}) do
            local invDir = 1 / localDir[axis]
            local t0 = (-halfSize[axis] - localOrigin[axis]) * invDir
            local t1 = (halfSize[axis] - localOrigin[axis]) * invDir
            if invDir < 0 then t0, t1 = t1, t0 end
            tMin = math.max(tMin, t0)
            tMax = math.min(tMax, t1)
            if tMax < tMin then return false end
        end
        return tMin >= 0
    end

    local function isMouseInSilentFOV() return isMouseInBoxFOV('Silent Aimbot') end
    local function isMouseInTriggerFOV() return isMouseInBoxFOV('Trigger Bot') end

local function isMouseInHitboxFOV(plr)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        return false 
    end

    local mousePos = UserInputService:GetMouseLocation()
    local camRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { localPlayer.Character or workspace }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local result = workspace:Raycast(camRay.Origin, camRay.Direction * 10000, params)

    if result and result.Instance then
        local hitModel = result.Instance:FindFirstAncestorWhichIsA("Model")
        if hitModel then
            local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
            return hitPlayer == plr
        end
    end

    return false
end


local function updateTargetVisuals()
    if not targetPlayer or not targetPlayer.Character then
        pcall(function()
            if silentBox then silentBox:Destroy() silentBox = nil end
            if triggerBox then triggerBox:Destroy() triggerBox = nil end
        end)
        silentBox = nil
        triggerBox = nil
        return
    end

    local char = targetPlayer.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        pcall(function()
            if silentBox then silentBox:Destroy() silentBox = nil end
            if triggerBox then triggerBox:Destroy() triggerBox = nil end
        end)
        return
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        pcall(function()
            if silentBox then silentBox:Destroy() silentBox = nil end
            if triggerBox then triggerBox:Destroy() triggerBox = nil end
        end)
        return
    end
    
    local look = root.CFrame.LookVector
    local facing = CFrame.lookAt(Vector3.new(), Vector3.new(look.X, 0, look.Z))

    local function drawBox(section, currentBox, activeColor, inactiveColor)
        local fovData = shared['x_x'][section].FOV
        if not fovData or not fovData['Show FOV'] then
            if currentBox then currentBox:Destroy() end
            return nil
        end

        local boxPos = root.Position

        local fov = getSplitFOV(section)
        local size, offset = Vector3.new(), Vector3.new()

        if fov.simple then
            size = Vector3.new(fov.x, fov.y, fov.z)
        else
            size = Vector3.new(fov.xLeft + fov.xRight, fov.yUpper + fov.yLower, fov.zRight + fov.zLeft)
            offset = Vector3.new((fov.xRight - fov.xLeft)/2, (fov.yUpper - fov.yLower)/2, (fov.zRight - fov.zLeft)/2)
        end

        local worldOffset = facing:VectorToWorldSpace(offset)

        if not currentBox then
            currentBox = Instance.new("Part")
            currentBox.Anchored = true
            currentBox.CanCollide = false
            currentBox.CanQuery = false
            currentBox.Transparency = 0.5
            currentBox.Material = Enum.Material.SmoothPlastic
            currentBox.Parent = Workspace
        end

        currentBox.Size = size
        currentBox.CFrame = CFrame.new(boxPos + worldOffset) * facing

        local inFOV = (section == 'Silent Aimbot' and isMouseInSilentFOV()) 
                    or (section == 'Trigger Bot' and isMouseInTriggerFOV())

        currentBox.BrickColor = inFOV and activeColor or inactiveColor

        return currentBox
    end

    silentBox = drawBox('Silent Aimbot', silentBox, BrickColor.new("Lime green"), BrickColor.new("Really red"))
    triggerBox = drawBox('Trigger Bot', triggerBox, BrickColor.new("Lime green"), BrickColor.new("Bright white"))
end



    local function isTargetKnocked(target)
        local bodyEffects = target.Character and target.Character:FindFirstChild("BodyEffects")
        local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
        return ko and ko.Value
    end

    local function isSelfKnocked()
        local bodyEffects = localPlayer.Character and localPlayer.Character:FindFirstChild("BodyEffects")
        local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
        return ko and ko.Value
    end

    local function isTargetGrabbed(player)
        if not shared['x_x']  .Checks['Grabbed Check'] then return false end
        local char = player.Character
        if not char then return false end
        return char:FindFirstChild('GRABBING_CONSTRAINT') ~= nil
    end
    local function isSameCrew(target)
        if not shared['x_x']  .Checks['Crew Check'] then return false end
        local localCrew = localPlayer:GetAttribute("CrewID")
        local targetCrew = target:GetAttribute("CrewID")
        return localCrew and targetCrew and localCrew == targetCrew
    end

    local function isVisible(origin, targetPart, targetCharacter)
        if not shared['x_x']  .Checks['Visible Check'] then return true end
        if not (targetPart and targetPart:IsA("BasePart")) then return false end
        local direction = (targetPart.Position - origin)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = { localPlayer.Character, targetCharacter }
        rayParams.IgnoreWater = true
        local result = Workspace:Raycast(origin, direction, rayParams)
        return not result or result.Instance:IsDescendantOf(targetCharacter)
    end


    local function getBestTarget()
        local closestPlayer, closestDist = nil, math.huge
        local mouseX, mouseY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
        local mousePos = Vector2.new(mouseX, mouseY)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local bodyEffects = player.Character:FindFirstChild("BodyEffects")
                local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
                local ff = player.Character:FindFirstChildOfClass("ForceField")
                
                if rootPart and 
                (not shared['x_x']  .Checks['Knock Check'] or not ko or not ko.Value) and
                (not shared['x_x']  .Checks['Spawn Protection Check'] or not ff) and
                (not shared['x_x']  .Checks['Crew Check'] or not isSameCrew(player)) and
                (not shared['x_x']  .Checks['Grabbed Check'] or not isTargetGrabbed(player)) then
                    
                    local screenPos = camera:WorldToViewportPoint(rootPart.Position)
                    if screenPos.Z > 0 and 
                    (not shared['x_x']  .Checks['Visible Check'] or isVisible(camera.CFrame.Position, rootPart, player.Character)) then
                        
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    local function shouldUnselect()
        local cfg = shared['x_x']  ['Unselect']
        if not cfg then return false end

        if targetPlayer and targetPlayer.Character then
            if cfg['Knocked'] and isTargetKnocked(targetPlayer) then
                return true
            end

            if cfg['Visible'] then
                local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and not isVisible(camera.CFrame.Position, root, targetPlayer.Character) then
                    return true
                end
            end
        end

        if cfg['Self Knocked'] and isSelfKnocked() then
            return true
        end

        return false
    end

    local function clearTarget()
        targetPlayer = nil

        pcall(function()
            if silentBox then silentBox:Destroy() silentBox = nil end
            if triggerBox then triggerBox:Destroy() triggerBox = nil end
        end)

        camLockActive = false
        camLockPart = nil
    end


    local function clearTargetIfInvalid()
        if not targetPlayer or not targetPlayer.Character then
            targetPlayer = nil
            pcall(function()
                if silentBox then silentBox:Destroy() silentBox = nil end
                if triggerBox then triggerBox:Destroy() triggerBox = nil end
            end)
            camLockActive = false
            camLockTarget = nil
            camLockPart = nil
            return true
        end

        if shared['x_x']  .Checks['Self Knock Check'] and isSelfKnocked() then
            targetPlayer = nil
            pcall(function()
                if silentBox then silentBox:Destroy() silentBox = nil end
                if triggerBox then triggerBox:Destroy() triggerBox = nil end
            end)
            camLockActive = false
            camLockTarget = nil
            camLockPart = nil
            return true
        end

        if shared['x_x']  .Checks['Knock Check'] and isTargetKnocked(targetPlayer) then
            targetPlayer = nil
            pcall(function()
                if silentBox then silentBox:Destroy() silentBox = nil end
                if triggerBox then triggerBox:Destroy() triggerBox = nil end
            end)
            camLockActive = false
            camLockTarget = nil
            camLockPart = nil
            return true
        end

        local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local ff = targetPlayer.Character:FindFirstChildOfClass("ForceField")
        
        if not rootPart or
        (shared['x_x']  .Checks['Spawn Protection Check'] and ff) or
        (shared['x_x']  .Checks['Crew Check'] and isSameCrew(targetPlayer)) or
        (shared['x_x']  .Checks['Grabbed Check'] and isTargetGrabbed(targetPlayer)) then
            
            targetPlayer = nil
            pcall(function()
                if silentBox then silentBox:Destroy() silentBox = nil end
                if triggerBox then triggerBox:Destroy() triggerBox = nil end
            end)
            camLockActive = false
            camLockTarget = nil
            camLockPart = nil
            return true
        end

        return false
    end

    task.spawn(LPH_NO_VIRTUALIZE(function()
        while task.wait(0.1) do
            local antiTripEnabled = shared['x_x'] and shared['x_x'].Extras and shared['x_x'].Extras['Anti Trip']
            
            if antiTripEnabled then
                local character = localPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 1 then
                        if humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end
                end
            end
        end
    end))

    UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, gameProcessed)
        if gameProcessed then return end
        local key = input.KeyCode

        if key == Enum.KeyCode.LeftControl then 
            leftCtrlHeld = true 
            return 
        end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            rightClickHeld = true
        end

        local selectBind = shared['x_x']  ["Binds"].Select
        if key == Enum.KeyCode[selectBind] then
            if not selectPressed then
                selectPressed = true
                if shared['x_x']  ["Targeting"]["Target Mode"] == "Select" then
                    if targetPlayer then
                        clearTarget()
                    else
                        targetPlayer = getBestTarget()
                        if targetPlayer and targetPlayer.Character then
                            updateTargetVisuals()
                        end
                    end
                end
            end
        end

        local camBind = shared['x_x']  ["Binds"]["Camera Aimbot"]
        if key == Enum.KeyCode[camBind] then
            if not camPressed then
                camPressed = true
                local mode = shared['x_x']  ["Camera Aimbot"].Mode or "Hold"
                if mode == "Toggle" then
                    camLockActive = not camLockActive
                    if camLockActive then
                        camLockTarget = targetPlayer
                        if camLockTarget and camLockTarget.Character then
                            camLockPart = getClosestHitPoint(camLockTarget.Character, true)
                        end
                    else
                        camLockTarget = nil
                        camLockPart = nil
                    end
                elseif mode == "Hold" then
                    camLockHold = true
                    camLockActive = true
                    camLockTarget = targetPlayer
                    if camLockTarget and camLockTarget.Character then
                        camLockPart = getClosestHitPoint(camLockTarget.Character, true)
                    end
                end
            end
        end

        local triggerBind = shared['x_x']  ["Binds"].Triggerbot
        if key == Enum.KeyCode[triggerBind] then
            if not triggerPressed then
                triggerPressed = true
                local mode = shared['x_x']  ["Trigger Bot"].Settings.Mode or "Hold"
                if mode == "Toggle" then
                    triggerBotActive = not triggerBotActive
                elseif mode == "Hold" then
                    triggerHold = true
                end
            end
        end

    end))

    UserInputService.InputEnded:Connect(LPH_NO_VIRTUALIZE(function(input)
        local key = input.KeyCode

        if key == Enum.KeyCode.LeftControl then
            leftCtrlHeld = false
        end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            rightClickHeld = false
        end

        if key == Enum.KeyCode[shared['x_x']  ["Binds"].Select] then
            selectPressed = false
        end

        if key == Enum.KeyCode[shared['x_x']  ["Binds"]["Camera Aimbot"]] then
            camPressed = false
            local mode = shared['x_x']  ["Camera Aimbot"].Mode or "Hold"
            if mode == "Hold" then
                camLockHold = false
                camLockActive = false
                camLockTarget = nil
                camLockPart = nil
            end
        end

        if key == Enum.KeyCode[shared['x_x']  ["Binds"].Triggerbot] then
            triggerPressed = false
            local mode = shared['x_x']  ["Trigger Bot"].Settings.Mode or "Hold"
            if mode == "Hold" then
                triggerHold = false
            end
        end
    end))

    local function getTriggerbotDelay()
        local cfg = shared['x_x']['Trigger Bot']['Delay Settings']
        if not cfg or not cfg['Delay Toggle'] then return 0 end
        local base = cfg['Delay'] or 0
        if cfg['Randomize Mouse'] and cfg['Randomize Mouse'].Enabled then
            local min = cfg['Randomize Mouse'].Min or 0
            local max = cfg['Randomize Mouse'].Max or 0
            if max > min then
                return min + math.random() * (max - min)
            end
        end
        return base
    end

    local function getShootDelay()
        local cfg = shared['x_x']['Trigger Bot']['Delay Settings']
        if not cfg or not cfg['Shoot Delay Toggle'] then return 0.08 end
        local base = cfg['Shoot Delay'] or 0.08
        if cfg['Randomize Shoot'] and cfg['Randomize Shoot'].Enabled then
            local min = cfg['Randomize Shoot'].Min or 0
            local max = cfg['Randomize Shoot'].Max or 0
            if max > min then
                return min + math.random() * (max - min)
            end
        end
        return base
    end

    rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        clearTargetIfInvalid()
        if shared['x_x']['Targeting']['Target Mode'] == "Select" and targetPlayer then
            if shouldUnselect() then
                clearTarget()
            end
        elseif shared['x_x']['Targeting']['Target Mode'] == "Automatic" then
            targetPlayer = getBestTarget()
        end
        local triggerCfg = shared['x_x']['Trigger Bot']
        if triggerCfg.Enabled and not leftCtrlHeld and targetPlayer and targetPlayer.Character then
            local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local distance = (root.Position - camera.CFrame.Position).Magnitude
                if distance <= triggerCfg['Max Range'] then
                    local settings = triggerCfg.Settings or {}
                    local forceTrigger = shared['x_x']['Targeting']['Target Mode'] == "Select" and shared['x_x']['Select Only Features']['Force Trigger']
                    local shouldActivate = forceTrigger or
                        (settings.Mode == "Always") or
                        (settings.Mode == "Hold" and triggerHold) or
                        (settings.Mode == "Toggle" and triggerBotActive)
                    if shouldActivate then
                        local hit = getClosestHitPoint(targetPlayer.Character, false, false)
                        local part = hit and hit.Part or root
                        local isVisible = not shared['x_x'].Checks["Visible Check"] or isVisible(camera.CFrame.Position, part, targetPlayer.Character)
                        local inFOV = (settings.Type == "FOV" and isMouseInTriggerFOV()) or (settings.Type == "Hitbox" and isMouseInHitboxFOV(targetPlayer))
                        if isVisible and (forceTrigger or inFOV) then
                            local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool and tool.Name ~= "[Knife]" then
                                task.spawn(function()
                                    local mouseDelay = getTriggerbotDelay()
                                    if mouseDelay > 0 then
                                        task.wait(mouseDelay)
                                    end
                                    local shootDelay = getShootDelay()
                                    local now = tick()
                                    if (now - (_G.LastShotTime or 0)) >= shootDelay then
                                        tool:Activate()
                                        _G.LastShotTime = now
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
        updateTargetVisuals()
    end))
rs.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
    local cfg = shared['x_x']['Camera Aimbot']
    if not cfg or not cfg.Enabled then
        if camFOVCircle then camFOVCircle:Remove() camFOVCircle = nil end
        if deadzoneCircle then deadzoneCircle:Remove() deadzoneCircle = nil end
        return
    end

    local shouldBeActive = (cfg.Mode == "Toggle" and camLockActive) or (cfg.Mode == "Hold" and camLockHold)

    if camLockTarget then
        local char = camLockTarget.Character
        if not char or not char.Parent or not camLockTarget.Parent or not char:FindFirstChildWhichIsA("Humanoid") or (char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChildWhichIsA("Humanoid").Health <= 0) then
            camLockTarget = nil
        end
    end

    local target = camLockTarget
    if not target or not target.Character then
        shared.snapFrameCounter = 0
        if camFOVCircle then camFOVCircle:Remove() camFOVCircle = nil end
        if deadzoneCircle then deadzoneCircle:Remove() deadzoneCircle = nil end
        return
    end

    local root = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
    if not root then return end

    local hit = getClosestHitPoint(target.Character, true)
    if not hit or not hit.Position or not hit.Part then return end

    local targetPos = hit.Position
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    local mousePos = UserInputService:GetMouseLocation()
    local mainDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

    local fovTable = cfg.FOV or {}
    local mainRadius = tonumber(fovTable.Radius) or 365
    local deadzoneRadius = tonumber(fovTable['Deadzone FOV']) or 65
    local isVisibleNow = isVisible(camera.CFrame.Position, hit.Part, target.Character)
    local zoom = (camera.CFrame.Position - camera.Focus.Position).Magnitude
    local isFP = zoom < 1
    local cond = cfg['Camera Aimbot Conditions'] or {}
    local allowedPerson = (cond['First Person'] and isFP) or (cond['Third Person'] and not isFP)
    local allowedClick = not cond['Right Click'] or rightClickHeld
    
    local criteriaMet = shouldBeActive and isVisibleNow and allowedPerson and allowedClick and mainDist <= mainRadius

    local isOnPlayer = false
    if criteriaMet and onScreen and hit.Part then
        local part = hit.Part
        local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local relativeCFrame = part.CFrame:PointToObjectSpace(mouseRay.Origin)
        local relativeDirection = part.CFrame:VectorToObjectSpace(mouseRay.Direction)
        local half = part.Size * 0.5
        
        local t = -relativeCFrame.Z / relativeDirection.Z
        local localHit = relativeCFrame + (relativeDirection * t)
        
        if math.abs(localHit.X) <= half.X and math.abs(localHit.Y) <= half.Y then
            isOnPlayer = true
        end
    end

    local snapCfg = cfg['Snap Delay'] or {}
    local maxDelay = shared.currentSnapDelay or 8

    if criteriaMet then
        if isOnPlayer then
            shared.snapFrameCounter = maxDelay 
        else
            shared.snapFrameCounter = (shared.snapFrameCounter or 0) + 1
        end
    else
        shared.snapFrameCounter = 0
        if snapCfg.Randomize and snapCfg.Randomize.Enabled then
            shared.currentSnapDelay = math.random(snapCfg.Randomize.Min, snapCfg.Randomize.Max)
        else
            shared.currentSnapDelay = snapCfg.Delay or 8
        end
    end

    local activated = criteriaMet and (shared.snapFrameCounter >= maxDelay)

    if fovTable['Show FOV'] then
        if not camFOVCircle then
            camFOVCircle = Drawing.new("Circle")
            camFOVCircle.NumSides = 32
            camFOVCircle.Thickness = 2
            camFOVCircle.Transparency = 0.85
            camFOVCircle.Visible = true
        end
        camFOVCircle.Position = mousePos
        camFOVCircle.Radius = mainRadius
        camFOVCircle.Color = activated and Color3.fromRGB(50,205,50) or Color3.fromRGB(255,255,255)
    elseif camFOVCircle then
        camFOVCircle:Remove()
        camFOVCircle = nil
    end

    local inDeadzone = mainDist <= deadzoneRadius
    if fovTable["Show Deadzone FOV"] then
        if not deadzoneCircle then
            deadzoneCircle = Drawing.new("Circle")
            deadzoneCircle.NumSides = 32
            deadzoneCircle.Thickness = 2
            deadzoneCircle.Transparency = 0.85
            deadzoneCircle.Visible = true
        end
        deadzoneCircle.Position = mousePos
        deadzoneCircle.Radius = deadzoneRadius
        deadzoneCircle.Color = (activated and inDeadzone) and Color3.fromRGB(255,165,0) or Color3.fromRGB(255,255,255)
    elseif deadzoneCircle then
        deadzoneCircle:Remove()
        deadzoneCircle = nil
    end

    if not activated then return end

    local smoothX, smoothY = 0.5, 0.5
    local snappiness = cfg['Snappiness']
    if snappiness and snappiness.Enabled then
        if snappiness['Type'] == "Simple" then
            smoothX = snappiness.Simple and snappiness.Simple.X or 0.167
            smoothY = snappiness.Simple and snappiness.Simple.Y or 0.139
        else
            local str = snappiness.Advanced and snappiness.Advanced.Strength or {}
            local sens = snappiness.Advanced and snappiness.Advanced.Sensitivity or 1
            smoothX = (str['X Strength'] or 0.123) * sens
            smoothY = (str['Y Strength'] or 0.123) * sens
        end
    end

    local humanize = cfg['Humanize'] or {}
    if inDeadzone and humanize['Deadzone Snappiness'] and humanize['Deadzone Snappiness'].Enabled then
        local mult = humanize['Deadzone Snappiness']['Deadzone Multiplier'] or {}
        smoothX = smoothX * (mult.X or 1)
        smoothY = smoothY * (mult.Y or 1)
    end

    local rawAlphaX = 1 - math.exp(-smoothX * dt * 60)
    local rawAlphaY = 1 - math.exp(-smoothY * dt * 60)

    local function getEasedAlpha(alpha, style, direction)
        style = style or "Linear"
        direction = direction or "InOut"
        if direction == "In" then
            if style == "Sine" then return 1 - math.cos(alpha * math.pi / 2) end
            if style == "Quad" then return alpha * alpha end
            if style == "Cubic" then return alpha * alpha * alpha end
            if style == "Quart" then return alpha^4 end
            if style == "Quint" then return alpha^5 end
            if style == "Expo" then return alpha == 0 and 0 or 2^(10 * (alpha - 1)) end
            if style == "Circ" then return 1 - math.sqrt(1 - alpha * alpha) end
            if style == "Back" then return alpha * alpha * (3 * alpha - 2) end
            return alpha
        elseif direction == "Out" then
            if style == "Sine" then return math.sin(alpha * math.pi / 2) end
            if style == "Quad" then return 1 - (1 - alpha)^2 end
            if style == "Cubic" then return 1 - (1 - alpha)^3 end
            if style == "Quart" then return 1 - (1 - alpha)^4 end
            if style == "Quint" then return 1 - (1 - alpha)^5 end
            if style == "Expo" then return alpha == 1 and 1 or 1 - 2^(-10 * alpha) end
            if style == "Circ" then return math.sqrt(1 - (alpha - 1)^2) end
            if style == "Back" then local a = 1 - alpha return 1 - a * a * (3 * a - 2) end
            return alpha
        else
            if style == "Sine" then return (1 - math.cos(alpha * math.pi)) / 2 end
            if style == "Quad" then return alpha < 0.5 and 2 * alpha * alpha or 1 - 2 * (1 - alpha)^2 end
            if style == "Cubic" then return alpha < 0.5 and 4 * alpha * alpha * alpha or 1 - 4 * (1 - alpha)^3 end
            if style == "Quart" then return alpha < 0.5 and 8 * alpha * alpha * alpha or 1 - 8 * (1 - alpha)^4 end
            if style == "Quint" then return alpha < 0.5 and 16 * alpha * alpha * alpha or 1 - 16 * (1 - alpha)^5 end
            if style == "Expo" then return alpha == 0 and 0 or (alpha == 1 and 1 or (alpha < 0.5 and 2^(10 * (2 * alpha - 1)) * 0.5 or 1 - 2^(-10 * (2 * alpha - 1)) * 0.5)) end
            if style == "Circ" then return alpha < 0.5 and (1 - math.sqrt(1 - (2 * alpha)^2)) * 0.5 or (math.sqrt(1 - (2 * (alpha - 1))^2) + 1) * 0.5 end
            if style == "Back" then
                local c1, c2 = 1.70158, 1.70158 * 1.525
                if alpha < 0.5 then
                    return (2 * alpha)^2 * ((c2 + 1) * 2 * alpha - c2) * 0.5
                else
                    return ((2 * alpha - 2)^2 * ((c2 + 1) * (2 * alpha - 2) + c2) + 2) * 0.5
                end
            end
            return alpha
        end
    end

    local easingStyle = cfg.Easing and cfg.Easing.Style or "Linear"
    local easingDirection = cfg.Easing and cfg.Easing.Direction or "InOut"
    local alphaX = getEasedAlpha(rawAlphaX, easingStyle, easingDirection)
    local alphaY = getEasedAlpha(rawAlphaY, easingStyle, easingDirection)

    local shakeX, shakeY = 0, 0
    if humanize['Micro Shake'] and humanize['Micro Shake'].Enabled then
        local freq = humanize['Micro Shake'].Frequency or {}
        local inten = humanize['Micro Shake'].Intensity or {}
        shakeX = math.noise(tick() * (freq.X or 12)) * (inten.X or 1.8)
        shakeY = math.noise(tick() * (freq.Y or 14) + 100) * (inten.Y or 1.6)
    end

    local useBezier = humanize['Bezier Curves'] and humanize['Bezier Curves'].Enabled
    local curveType = useBezier and (humanize['Bezier Curves']['Curve Type'] or "Quadratic") or nil
    local method = cfg['Method'] or "Mouse"

    if method == "Mouse" then
        local aimPos
        if useBezier then
            local startPos = camera.CFrame.Position
            local t = math.clamp(1 - math.exp(-3.8 * dt * 60), 0, 1)
            if curveType == "Cubic" then
                local p1, p2 = startPos:Lerp(targetPos, 0.33), startPos:Lerp(targetPos, 0.66)
                aimPos = (1-t)^3 * startPos + 3*(1-t)^2*t * p1 + 3*(1-t)*t^2 * p2 + t^3 * targetPos
            else
                aimPos = startPos:Lerp(targetPos, t)
            end
        else
            aimPos = targetPos
        end

        local targetScreen = camera:WorldToViewportPoint(aimPos)
        local deltaX = (targetScreen.X - mousePos.X + shakeX) * alphaX
        local deltaY = (targetScreen.Y - mousePos.Y + shakeY) * alphaY

        if math.abs(deltaX) > 0.08 or math.abs(deltaY) > 0.08 then
            mousemoverel(deltaX, deltaY)
        end
    else
        local targetCFrame
        if useBezier then
            local startPos = camera.CFrame.Position
            local t = math.clamp(1 - math.exp(-3.8 * dt * 60), 0, 1)
            local bezPos = startPos:Lerp(targetPos, t)
            targetCFrame = CFrame.lookAt(startPos, bezPos)
        else
            targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
        end
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, math.max(alphaX, alphaY))
    end
end))


GunHandler.getAim = function(origin, range)
    local cfg = shared['x_x']["Silent Aimbot"]
    if not cfg or not cfg.Enabled then
        return OriginalGetAim(origin, range)
    end
    if not targetPlayer or not targetPlayer.Character then
        return OriginalGetAim(origin, range)
    end
    local char = targetPlayer.Character
    if clearTargetIfInvalid and clearTargetIfInvalid() then
        return OriginalGetAim(origin, range)
    end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    local distance = root and (root.Position - origin).Magnitude or 9999
    if distance > (cfg["Max Range"] or 250) then
        return OriginalGetAim(origin, range)
    end
    local forceHit = shared['x_x']['Targeting']['Target Mode'] == "Select" and shared['x_x']['Select Only Features']['Force Redirect']
    local inFOV = isMouseInSilentFOV()
    if not (forceHit or inFOV) then
        return OriginalGetAim(origin, range)
    end
    if shared['x_x'].Checks["Visible Check"] then
        if root and not isVisible(origin, root, char) then
            return OriginalGetAim(origin, range)
        end
    end
    if shared['x_x']["Anti Curve"] and shared['x_x']["Anti Curve"].Enabled then
        local ac = shared['x_x']["Anti Curve"]
        local maxX = math.rad(ac["X Angle"] or 0.22)
        local maxY = math.rad(ac["Y Angle"] or 0.35)
        if ac["Weapon Configuration"] and ac["Weapon Configuration"].Enabled then
            local cat = getWeaponCategory()
            local wc = ac["Weapon Configuration"][cat] or ac["Weapon Configuration"].Others or ac
            maxX = math.rad(wc["X Angle"] or 0.22)
            maxY = math.rad(wc["Y Angle"] or 0.35)
        end
        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        if root then
            local toTarget = (root.Position - camPos).Unit
            local horizDot = Vector3.new(camDir.X, 0, camDir.Z).Unit:Dot(Vector3.new(toTarget.X, 0, toTarget.Z).Unit)
            local horizAngle = math.acos(math.clamp(horizDot, -1, 1))
            local vertAngle = math.asin(math.clamp(toTarget.Y, -1, 1))
            if math.abs(horizAngle) > maxX or math.abs(vertAngle) > maxY then
                return OriginalGetAim(origin, range)
            end
        end
    end
    local hitData = getClosestHitPoint(char, false, true)
    if not hitData or not hitData.Position then
        return OriginalGetAim(origin, range)
    end
    local direction = (hitData.Position - origin)
    return direction.Unit, math.min(direction.Magnitude, range or 1000)
end

    if not shared['x_x'] then
        shared['x_x'] = {}
    end

    if not shared['x_x']['skins'] then
        shared['x_x']['skins'] = {}
    end

    local skinchanger = shared['x_x']['Skin Changer']
    if skinchanger and skinchanger.Enabled then
        for weapon, skin in pairs(skinchanger.Weapons) do
            shared['x_x']['skins'][weapon] = skin
        end
    end

    local _char = localPlayer.Character
    if _char then
        for _, v in ipairs(_char:GetChildren()) do
            if v:IsA("Tool") then
                v:SetAttribute("GlorySetup", nil)
            end
        end
    end
    local _backpack = localPlayer:FindFirstChild("Backpack")
    if _backpack then
        for _, tool in ipairs(_backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool:SetAttribute("GlorySetup", nil)
            end
        end
    end

    local function clearMesh(tool, orig)
        for _, child in ipairs(tool:GetChildren()) do
            if child.Name == "CurrentSkin" or (child:IsA("MeshPart") and child ~= orig) then
                child:Destroy()
            end
        end
    end

    local function applyBat(tool, name)
        local mesh = nil
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("MeshPart") and v.Transparency == 0 then
                mesh = v
                break
            end
        end
        if not mesh then return end
        local batskins = ReplicatedStorage:FindFirstChild("SkinModules")
        if not batskins then return end
        batskins = batskins:FindFirstChild("Bats")
        if not batskins then return end
        local skin = batskins:FindFirstChild(name)
        if not skin then return end
        local clone = skin:Clone()
        clone.Parent = tool
        clone.CFrame = mesh.CFrame
        clone.Name = "CurrentSkin"
        local w = Instance.new("Weld")
        w.Part0 = clone
        w.Part1 = mesh
        w.Parent = clone
        mesh.Transparency = 1
    end

    local function applyGun(tool, name)
        local orig = tool:FindFirstChildOfClass("MeshPart")
        if not orig then return end
        local skinmodules = ReplicatedStorage:FindFirstChild("SkinModules")
        if not skinmodules then return end
        local success, skinmodulesreq = pcall(function()
            return require(skinmodules)
        end)
        if not success or not skinmodulesreq then return end
        local info = skinmodulesreq[tool.Name] and skinmodulesreq[tool.Name][name]
        if not info then return end
        clearMesh(tool, orig)
        local skinpart = info.TextureID
        if typeof(skinpart) == "Instance" then
            local clone = skinpart:Clone()
            clone.Parent = tool
            clone.CFrame = orig.CFrame
            clone.Name = "CurrentSkin"
            local w = Instance.new("Weld")
            w.Part0 = clone
            w.Part1 = orig
            w.C0 = info.CFrame:Inverse()
            w.Parent = clone
            orig.Transparency = 1
        else
            orig.TextureID = skinpart
            orig.Transparency = 0
        end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        local shoot = handle:FindFirstChild("ShootSound")
        if shoot then
            local skinassets = ReplicatedStorage:FindFirstChild("SkinAssets")
            if skinassets then
                local gunsounds = skinassets:FindFirstChild("GunShootSounds")
                if gunsounds then
                    local sounds = gunsounds:FindFirstChild(tool.Name)
                    local obj = sounds and sounds:FindFirstChild(name)
                    if obj then
                        shoot.SoundId = obj.Value
                    end
                end
            end
        end
        local skinassets = ReplicatedStorage:FindFirstChild("SkinAssets")
        if skinassets then
            local particlefolder = skinassets:FindFirstChild("GunHandleParticle")
            if particlefolder then
                local particlesource = particlefolder:FindFirstChild(name)
                if particlesource then
                    local pe = particlesource:FindFirstChild("ParticleEmitter")
                    if pe then
                        for _, existing in ipairs(handle:GetChildren()) do
                            if existing:IsA("ParticleEmitter") then
                                existing:Destroy()
                            end
                        end
                        pe:Clone().Parent = handle
                    end
                end
            end
            local beamfolder = skinassets:FindFirstChild("GunHandleBeam")
            if beamfolder then
                local beamsource = beamfolder:FindFirstChild(name)
                if beamsource then
                    for _, existing in ipairs(handle:GetChildren()) do
                        if existing:IsA("Beam") then
                            existing:Destroy()
                        end
                    end
                    beamsource:Clone().Parent = handle
                end
            end
        end
        handle:SetAttribute("SkinName", name)
    end

    local function cleanKnife(tool)
        local data = knifeData[tool]
        if data then
            if data.track then
                data.track:Stop()
                data.track:Destroy()
                data.track = nil
            end
            if data.welds then
                for _, w in ipairs(data.welds) do
                    if w then w:Destroy() end
                end
            end
            if data.sounds then
                for _, s in ipairs(data.sounds) do
                    if s and s.Parent then s:Destroy() end
                end
            end
        end
        local mesh = tool:FindFirstChild("Default")
        if mesh then
            for _, v in ipairs(mesh:GetChildren()) do
                if v.Name == "Handle.R" or v:IsA("Model") or (v:IsA("BasePart") and v.Name ~= "Default") then
                    v:Destroy()
                end
            end
            mesh.Transparency = 0
        end
        knifeData[tool] = nil
    end

    local function applyKnife(char, tool, skin)
        local cfg = knifeSkins[skin]
        if not cfg then return end
        local hum = char:FindFirstChild("Humanoid")
        local rhand = char:FindFirstChild("RightHand")
        if not hum or not rhand then return end
        cleanKnife(tool)
        knifeData[tool] = {track = nil, welds = {}, sounds = {}}
        local data = knifeData[tool]
        local mesh = tool:FindFirstChild("Default")
        if not mesh then return end
        mesh.Transparency = 1
        local skinmodules = ReplicatedStorage:FindFirstChild("SkinModules")
        if not skinmodules then return end
        local knives = skinmodules:FindFirstChild("Knives")
        if not knives then return end
        local skinmodel = knives:FindFirstChild(skin)
        if not skinmodel then return end
        local clone = skinmodel:Clone()
        clone.Name = skin

        local handr = Instance.new("Part")
        handr.Name = "Handle.R"
        handr.Transparency = 1
        handr.CanCollide = false
        handr.Anchored = false
        handr.Size = Vector3.new(0.001, 0.001, 0.001)
        handr.Massless = true
        handr.Parent = mesh

        local m6d = Instance.new("Motor6D")
        m6d.Name = "Handle.R"
        m6d.Part0 = rhand
        m6d.Part1 = handr
        m6d.Parent = handr

        local offset = CFrame.new(cfg.positionoffset) * CFrame.Angles(
            math.rad(cfg.rotationoffset.X),
            math.rad(cfg.rotationoffset.Y),
            math.rad(cfg.rotationoffset.Z)
        )

        if clone:IsA("Model") then
            if not clone.PrimaryPart then
                for _, c in ipairs(clone:GetChildren()) do
                    if c:IsA("BasePart") then
                        clone.PrimaryPart = c
                        break
                    end
                end
            end
            if clone.PrimaryPart then
                for _, p in ipairs(clone:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                        p.Massless = true
                        p.Anchored = false
                        local w = Instance.new("Weld")
                        w.Part0 = handr
                        w.Part1 = p
                        w.C0 = offset
                        w.C1 = p.CFrame:ToObjectSpace(clone.PrimaryPart.CFrame)
                        w.Parent = p
                        table.insert(data.welds, w)
                    end
                end
            end
            clone.Parent = mesh
        elseif clone:IsA("BasePart") then
            clone.CanCollide = false
            clone.Massless = true
            clone.Anchored = false
            if clone:IsA("MeshPart") and cfg.textureid then
                clone.TextureID = cfg.textureid
            end
            if cfg.particle then
                local skinassets = ReplicatedStorage:FindFirstChild("SkinAssets")
                if skinassets then
                    local particlefolder = skinassets:FindFirstChild("GunHandleParticle")
                    if particlefolder then
                        local particlesource = particlefolder:FindFirstChild(skin)
                        if particlesource then
                            local pe = particlesource:FindFirstChild("ParticleEmitter")
                            if pe then
                                pe:Clone().Parent = clone
                            end
                        end
                    end
                end
            end
            clone.Parent = mesh
            local w = Instance.new("Weld")
            w.Part0 = handr
            w.Part1 = clone
            w.C0 = offset
            w.Parent = clone
            table.insert(data.welds, w)
        end

        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end
        if cfg.animationid and cfg.animationid ~= "" then
            local anim = Instance.new("Animation")
            anim.AnimationId = cfg.animationid
            local track = animator:LoadAnimation(anim)
            track.Looped = false
            track:Play()
            data.track = track
            anim:Destroy()
            track.Ended:Once(function()
                if data.track == track then
                    data.track = nil
                end
                track:Destroy()
            end)
        end
        if cfg.soundid and cfg.soundid ~= "" then
            local snd = Instance.new("Sound")
            snd.SoundId = cfg.soundid
            snd.Parent = Workspace
            snd:Play()
            table.insert(data.sounds, snd)
            snd.Ended:Connect(function()
                snd:Destroy()
            end)
        end
        tool:SetAttribute("CurrentKnifeSkin", skin)
    end

    local function applyCurrentSkin(tool)
        if not tool or not tool.Parent then return end
        local char = localPlayer.Character
        if tool.Parent ~= char then return end
        if not shared['x_x'] then return end
        if not shared['x_x']['skins'] then return end
        local skin = shared['x_x']['skins'][tool.Name]
        if not skin or skin == "" then return end
        local handle = tool:FindFirstChild("Handle")
        if handle and handle:GetAttribute("SkinName") == skin then return end
        if tool.Name == "[Knife]" then
            applyKnife(char, tool, skin)
        elseif tool.Name == "[Bat]" then
            applyBat(tool, skin)
        else
            applyGun(tool, skin)
        end
    end

    local function setupTool(tool)
        if not tool:IsA("Tool") then return end
        if tool:GetAttribute("GlorySetup") then return end
        tool:SetAttribute("GlorySetup", true)

        tool.Equipped:Connect(function()
            local char = tool.Parent
            if char ~= localPlayer.Character then return end
            applyCurrentSkin(tool)
        end)

        tool.Unequipped:Connect(function()
            if tool.Name == "[Knife]" then
                local data = knifeData[tool]
                if not data then return end
                if data.welds then
                    for _, w in ipairs(data.welds) do
                        if w then w:Destroy() end
                    end
                    data.welds = {}
                end
                if data.sounds then
                    for _, s in ipairs(data.sounds) do
                        if s and s.Parent then s:Destroy() end
                    end
                    data.sounds = {}
                end
                local mesh = tool:FindFirstChild("Default")
                if mesh then
                    for _, v in ipairs(mesh:GetChildren()) do
                        if v.Name == "Handle.R" or v:IsA("Model") or (v:IsA("MeshPart") and v.Name ~= "Default") then
                            v:Destroy()
                        end
                    end
                    mesh.Transparency = 0
                end
            end
        end)

        if tool.Parent == localPlayer.Character then
            applyCurrentSkin(tool)
        end
    end

    local function watchCharacter(char)
        if not char then return end
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then
                setupTool(v)
            end
        end
        char.ChildAdded:Connect(function(v)
            if v:IsA("Tool") then
                setupTool(v)
            end
        end)
    end

    watchCharacter(localPlayer.Character)
    localPlayer.CharacterAdded:Connect(watchCharacter)

    local backpack = localPlayer:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            setupTool(tool)
        end
    end
    backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupTool(child)
        end
    end)

    if localPlayer.Character then
        for _, v in ipairs(localPlayer.Character:GetChildren()) do
            if v:IsA("Tool") then
                applyCurrentSkin(v)
            end
        end
    end
