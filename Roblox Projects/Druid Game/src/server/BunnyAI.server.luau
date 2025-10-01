-- BunnyAI.server.luau - Optimized bunny movement and animation script
-- This script gets cloned and added to each spawned bunny

-- Safety check: only run if parented to a model with Humanoid
if not script.Parent:IsA("Model") or not script.Parent:FindFirstChildOfClass("Humanoid") then
    return -- Don't run if not properly parented to a bunny
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local model = script.Parent
local humanoid = model:WaitForChild("Humanoid", 5)
local animator = humanoid and humanoid:WaitForChild("Animator", 5)
local rootPart = model:WaitForChild("HumanoidRootPart", 5)

-- Exit if essential components aren't found
if not humanoid or not animator or not rootPart then
    warn("BunnyAI: Missing essential components, exiting")
    return
end

-- Get bunny configuration
local BunnyAIConfig = require(ReplicatedStorage.Shared.BunnyAIConfig)
local bunnyTypeValue = model:WaitForChild("BunnyType", 5) -- Wait up to 5 seconds
local bunnyType = bunnyTypeValue and bunnyTypeValue.Value or "BrownBunny" -- Default fallback

local config = BunnyAIConfig.getConfig(bunnyType)

-- Apply rotation from config
rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(config.ROTATION_OFFSET), 0)

-- === Dynamic Configuration ===
local HOP_ANIM_ID = config.HOP_ANIM_ID
local MOVE_INTERVAL = config.MOVE_INTERVAL
local MIN_DISTANCE = config.MIN_DISTANCE
local MAX_DISTANCE = config.MAX_DISTANCE
local PAUSE_CHANCE = config.PAUSE_CHANCE

humanoid.WalkSpeed = config.WALK_SPEED

-- Create and load animation
local hopAnim = Instance.new("Animation")
hopAnim.AnimationId = "rbxassetid://" .. HOP_ANIM_ID

local hopTrack = animator:LoadAnimation(hopAnim)
hopTrack.Priority = Enum.AnimationPriority.Movement
hopTrack.Looped = true

local function startAnimation()
	if not hopTrack.IsPlaying then
		hopTrack:Play(0.15)
	end
end

local function stopAnimation()
	if hopTrack.IsPlaying then
		hopTrack:Stop(0.2)
	end
end

-- === EFFICIENT MOVEMENT LOGIC ===
local function getRandomPosition()
	local currentPos = rootPart.Position
	local randomAngle = math.random() * math.pi * 2
	local distance = math.random(MIN_DISTANCE, MAX_DISTANCE)

	return Vector3.new(
		currentPos.X + math.cos(randomAngle) * distance,
		currentPos.Y,
		currentPos.Z + math.sin(randomAngle) * distance
	)
end

local function moveBunny()
	if math.random() < PAUSE_CHANCE then
		task.wait(MOVE_INTERVAL)
		return
	end

	local targetPos = getRandomPosition()

	-- Start animation when movement begins
	startAnimation()

	-- Move and wait for completion (event-driven, no polling!)
	humanoid:MoveTo(targetPos)
	humanoid.MoveToFinished:Wait() -- Much more efficient than while loop!

	-- Stop animation when movement ends
	stopAnimation()

	task.wait(MOVE_INTERVAL)
end

-- === SIMPLE MOVEMENT LOOP ===
local function movementLoop()
	while model.Parent and humanoid and humanoid.Health > 0 do
		local success, err = pcall(moveBunny)
		if not success then
			warn("Bunny movement error:", err)
			task.wait(1) -- Brief pause on error
		end
	end
end

-- Start the movement loop
task.spawn(movementLoop)

-- Handle cleanup
humanoid.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Seated or 
		newState == Enum.HumanoidStateType.Dead then
		stopAnimation()
	end
end)

print("🐰 Bunny AI initialized for:", bunnyType, "- Speed:", config.WALK_SPEED, "Pause chance:", config.PAUSE_CHANCE)
