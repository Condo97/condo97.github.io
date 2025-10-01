local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local LOCAL_PLAYER = Players.LocalPlayer

-- Track swimming state
local isSwimming = false
local currentWaterPart: BasePart? = nil
local swimConnection: RBXScriptConnection? = nil
local originalWalkSpeed: number? = nil
local bodyVelocity: BodyVelocity? = nil

-- Configuration
local SWIM_SPEED = 24 -- Increased from 16 for faster swimming
local SURFACE_FORCE = 20 -- Upward force when near surface
local UNDERWATER_DAMPING = 0.7

local function getWaterParts(): {BasePart}
	local tagged = CollectionService:GetTagged("Water")
	if #tagged > 0 then
		return tagged
	end
	-- Fallback: any part named "Water"
	local results = {}
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "Water" then
			table.insert(results, descendant)
		end
	end
	return results
end

local function isPointInWater(position: Vector3): BasePart?
	for _, waterPart in ipairs(getWaterParts()) do
		if waterPart.Parent then
			local localPoint = waterPart.CFrame:PointToObjectSpace(position)
			local halfSize = waterPart.Size * 0.5
			if math.abs(localPoint.X) <= halfSize.X 
				and math.abs(localPoint.Y) <= halfSize.Y 
				and math.abs(localPoint.Z) <= halfSize.Z then
				return waterPart
			end
		end
	end
	return nil
end

local function startSwimming(humanoid: Humanoid, rootPart: BasePart, waterPart: BasePart)
	if isSwimming then return end

	isSwimming = true
	currentWaterPart = waterPart

	-- Store original walk speed
	if not originalWalkSpeed then
		originalWalkSpeed = humanoid.WalkSpeed
	end

	-- Set up swimming physics like default Roblox water
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	-- Create BodyVelocity for controlled swimming (like default water)
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = rootPart

	-- Apply immediate upward force to prevent initial sinking
	local currentVelocity = rootPart.AssemblyLinearVelocity
	if currentVelocity.Y < 0 then -- If falling when entering water
		-- Apply strong upward force to counteract downward momentum
		bodyVelocity.Velocity = Vector3.new(currentVelocity.X * 0.5, math.max(currentVelocity.Y * -0.2, 8), currentVelocity.Z * 0.5)
	else
		-- Gentle upward force for neutral entry
		bodyVelocity.Velocity = Vector3.new(currentVelocity.X * 0.7, math.max(currentVelocity.Y, 3), currentVelocity.Z * 0.7)
	end

	-- Start swimming update loop (defined below)
	local function updateSwimming()
		if not bodyVelocity then return end

		local camera = workspace.CurrentCamera
		local moveVector = humanoid.MoveDirection
		local velocity = rootPart.AssemblyLinearVelocity

		-- Calculate target velocity based on movement input
		local targetVelocity = Vector3.zero

		-- Horizontal movement (WASD)
		if moveVector.Magnitude > 0 then
			-- Use camera direction for movement like default water
			local cameraCFrame = camera.CFrame
			local lookDirection = cameraCFrame.LookVector
			local rightDirection = cameraCFrame.RightVector

			-- Project movement onto camera directions
			local forwardMovement = moveVector.Z * -lookDirection -- Z is inverted in MoveDirection
			local rightMovement = moveVector.X * rightDirection

			targetVelocity = (forwardMovement + rightMovement) * SWIM_SPEED
		end

		-- Vertical movement (Space/Ctrl)
		local verticalVelocity = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			verticalVelocity = SWIM_SPEED * 0.7 -- Ascend
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			verticalVelocity = -SWIM_SPEED * 0.7 -- Descend
		else
			-- Natural buoyancy - float toward surface like default water
			local waterTop = waterPart.Position.Y + (waterPart.Size.Y * 0.5)
			local playerY = rootPart.Position.Y
			local distanceFromSurface = waterTop - playerY

			if distanceFromSurface > 0 and distanceFromSurface < 8 then
				-- Near surface - apply upward force
				verticalVelocity = SURFACE_FORCE * (distanceFromSurface / 8)
			else
				-- Underwater - stronger buoyancy to prevent excessive sinking
				verticalVelocity = 4 -- Increased from 2 to 4 for better buoyancy
			end
		end

		targetVelocity = targetVelocity + Vector3.new(0, verticalVelocity, 0)

		-- Handle movement responsiveness vs momentum
		local finalVelocity

		if moveVector.Magnitude > 0 then
			-- Moving - more responsive to input, less drift
			local dampedVelocity = velocity * (UNDERWATER_DAMPING * 0.5) -- Reduce momentum when changing direction
			finalVelocity = targetVelocity * 0.7 + dampedVelocity * 0.3
		else
			-- Not moving - stop horizontal drift but preserve vertical movement
			local currentVertical = Vector3.new(0, velocity.Y, 0)
			local horizontalDamping = Vector3.new(velocity.X, 0, velocity.Z) * 0.2 -- Strong horizontal damping
			finalVelocity = targetVelocity + currentVertical * UNDERWATER_DAMPING + horizontalDamping
		end

		bodyVelocity.Velocity = finalVelocity
	end

	swimConnection = RunService.Heartbeat:Connect(updateSwimming)

	print("Started swimming")
end

local function stopSwimming(humanoid: Humanoid)
	if not isSwimming then return end

	isSwimming = false
	currentWaterPart = nil

	-- Restore humanoid states
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)

	-- Restore walk speed
	if originalWalkSpeed then
		humanoid.WalkSpeed = originalWalkSpeed
		originalWalkSpeed = nil
	end

	-- Clean up swimming physics
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if swimConnection then
		swimConnection:Disconnect()
		swimConnection = nil
	end

	print("Stopped swimming")
end



-- Main loop to check for water entry/exit
task.spawn(function()
	while true do
		local character = LOCAL_PLAYER.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid and rootPart then
				local waterPart = isPointInWater(rootPart.Position)

				if waterPart and not isSwimming then
					-- Enter water
					startSwimming(humanoid, rootPart, waterPart)
				elseif not waterPart and isSwimming then
					-- Exit water
					stopSwimming(humanoid)
				end
			end
		end

		task.wait(0.1) -- Check less frequently for better performance
	end
end)

-- Handle character respawning
LOCAL_PLAYER.CharacterAdded:Connect(function()
	-- Reset swimming state when character respawns
	isSwimming = false
	currentWaterPart = nil
	originalWalkSpeed = nil

	if swimConnection then
		swimConnection:Disconnect()
		swimConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
end)