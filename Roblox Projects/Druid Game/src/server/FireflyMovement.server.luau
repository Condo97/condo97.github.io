local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

--[[
	FireflyController - Movement Behavior Module
	
	This script handles the movement AI for firefly models.
	Fireflies will move naturally within defined boundaries using smooth
	waypoint-based movement with occasional pauses.
	
	Boundaries start at the firefly's spawn position (floor level) and 
	extend upward and outward, perfect for fireflies placed on the ground.
	
	Fireflies orient with their positive X axis as the front, so they
	fly front-first toward their destinations.
	
	Usage: Tag any Model with "Firefly" to start the movement AI
--]]

-- ========================================================================================
-- CONFIGURATION
-- ========================================================================================

local MOVEMENT_CONFIG = {
	-- Boundary settings
	BOUNDARY_SIZE = 20,              -- How far from spawn point fireflies can roam horizontally (studs)
	BOUNDARY_HEIGHT = 15,            -- How high above spawn point fireflies can fly (studs)
	
	-- Movement behavior
	MOVE_SPEED_MIN = 2,              -- Minimum movement speed (studs/second)
	MOVE_SPEED_MAX = 8,              -- Maximum movement speed (studs/second)
	WAYPOINT_DISTANCE_MIN = 3,       -- Minimum distance to next waypoint
	WAYPOINT_DISTANCE_MAX = 12,      -- Maximum distance to next waypoint
	
	-- Pause behavior
	PAUSE_CHANCE = 0.3,              -- Chance to pause at each waypoint (0-1)
	PAUSE_MIN = 0.5,                 -- Minimum pause duration (seconds)
	PAUSE_MAX = 3.0,                 -- Maximum pause duration (seconds)
	
	-- Movement style
	EASING_STYLE = Enum.EasingStyle.Sine,
	EASING_DIRECTION = Enum.EasingDirection.InOut,
	
	-- Rotation settings
	FACE_MOVEMENT = true,            -- Should fireflies face their movement direction (positive X axis = front)
	
	-- Debug visualization
	SHOW_BOUNDARY_BOX = false,        -- Show bounding box visualization at 0.2 transparency
}

-- ========================================================================================
-- STATE MANAGEMENT
-- ========================================================================================

local activeFireflies = {}         -- Track active firefly models and their data
local movementCoroutines = {}      -- Track running movement coroutines
local boundaryBoxes = {}           -- Track boundary box visualizations

-- ========================================================================================
-- UTILITY FUNCTIONS
-- ========================================================================================

-- Get the primary part of a firefly model (or first BasePart found)
local function getFireflyPrimaryPart(fireflyModel)
	-- Try PrimaryPart first
	if fireflyModel.PrimaryPart then
		return fireflyModel.PrimaryPart
	end
	
	-- Find first BasePart that's NOT named "Light" (avoid moving just light parts)
	for _, child in pairs(fireflyModel:GetChildren()) do
		if child:IsA("BasePart") and child.Name ~= "Light" then
			return child
		end
	end
	
	-- If no non-Light parts found, use any BasePart
	for _, child in pairs(fireflyModel:GetChildren()) do
		if child:IsA("BasePart") then
			return child
		end
	end
	
	return nil
end

-- Calculate a random waypoint within boundaries (boundary starts at floor and goes up)
local function generateWaypoint(centerPosition, currentPosition)
	local angle = math.random() * math.pi * 2
	local distance = math.random() * (MOVEMENT_CONFIG.WAYPOINT_DISTANCE_MAX - MOVEMENT_CONFIG.WAYPOINT_DISTANCE_MIN) + MOVEMENT_CONFIG.WAYPOINT_DISTANCE_MIN
	
	-- Use current position as base for more natural movement (bias toward nearby areas)
	local basePosition = currentPosition + (centerPosition - currentPosition) * 0.3 -- Slight bias toward center
	
	-- Calculate base position (X and Z)
	local newX = basePosition.X + math.cos(angle) * distance
	local newZ = basePosition.Z + math.sin(angle) * distance
	
	-- Add vertical variation - from floor level (centerPosition.Y) up to BOUNDARY_HEIGHT
	local heightFromFloor = math.random() * MOVEMENT_CONFIG.BOUNDARY_HEIGHT
	local newY = centerPosition.Y + heightFromFloor
	
	local newPosition = Vector3.new(newX, newY, newZ)
	
	-- Ensure waypoint is within horizontal boundaries
	local horizontalDistance = math.sqrt((newPosition.X - centerPosition.X)^2 + (newPosition.Z - centerPosition.Z)^2)
	if horizontalDistance > MOVEMENT_CONFIG.BOUNDARY_SIZE then
		-- Pull back to boundary edge (only X and Z, keep Y)
		local direction = Vector3.new(newPosition.X - centerPosition.X, 0, newPosition.Z - centerPosition.Z).Unit
		local correctedPosition = centerPosition + direction * MOVEMENT_CONFIG.BOUNDARY_SIZE * 0.9
		newPosition = Vector3.new(correctedPosition.X, newY, correctedPosition.Z)
	end
	
	-- Ensure Y stays within bounds (floor to ceiling)
	newPosition = Vector3.new(newPosition.X, math.max(centerPosition.Y, math.min(newPosition.Y, centerPosition.Y + MOVEMENT_CONFIG.BOUNDARY_HEIGHT)), newPosition.Z)
	
	return newPosition
end

-- Calculate movement speed based on distance
local function calculateMovementSpeed(distance)
	-- Shorter distances = slower movement for more natural feel
	local speedFactor = math.min(distance / MOVEMENT_CONFIG.WAYPOINT_DISTANCE_MAX, 1)
	return MOVEMENT_CONFIG.MOVE_SPEED_MIN + (MOVEMENT_CONFIG.MOVE_SPEED_MAX - MOVEMENT_CONFIG.MOVE_SPEED_MIN) * speedFactor
end

-- Create a bounding box visualization for debugging (starts at floor, goes up)
local function createBoundaryBox(fireflyModel, floorPosition)
	if not MOVEMENT_CONFIG.SHOW_BOUNDARY_BOX then
		return nil
	end
	
	-- Create a transparent part to visualize the boundary
	local boundaryPart = Instance.new("Part")
	boundaryPart.Name = "FireflyBoundaryBox_" .. fireflyModel.Name
	boundaryPart.Shape = Enum.PartType.Block
	boundaryPart.Material = Enum.Material.ForceField
	boundaryPart.BrickColor = BrickColor.new("Bright green")
	boundaryPart.Transparency = 0.2
	boundaryPart.CanCollide = false
	boundaryPart.Anchored = true
	
	-- Size the box to show the movement boundary (starts at floor, goes up)
	local boxSize = Vector3.new(
		MOVEMENT_CONFIG.BOUNDARY_SIZE * 2,
		MOVEMENT_CONFIG.BOUNDARY_HEIGHT,
		MOVEMENT_CONFIG.BOUNDARY_SIZE * 2
	)
	boundaryPart.Size = boxSize
	
	-- Position the box so its bottom edge is at the floor position, extending upward
	local boxPosition = Vector3.new(
		floorPosition.X,
		floorPosition.Y + MOVEMENT_CONFIG.BOUNDARY_HEIGHT / 2,  -- Center the box vertically above the floor
		floorPosition.Z
	)
	boundaryPart.CFrame = CFrame.new(boxPosition)
	
	-- Parent to workspace
	boundaryPart.Parent = workspace
	
	-- Add a text label to identify the firefly (position above the boundary box)
	local gui = Instance.new("BillboardGui")
	gui.Name = "BoundaryLabel"
	gui.Size = UDim2.fromOffset(200, 50)
	gui.StudsOffset = Vector3.new(0, MOVEMENT_CONFIG.BOUNDARY_HEIGHT/2 + 2, 0)  -- Above the box
	gui.Parent = boundaryPart
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = fireflyModel.Name .. " Territory"
	label.TextColor3 = Color3.new(0, 1, 0)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = gui
	
	return boundaryPart
end

-- Remove boundary box visualization
local function removeBoundaryBox(fireflyModel)
	if boundaryBoxes[fireflyModel] then
		if boundaryBoxes[fireflyModel].Parent then
			boundaryBoxes[fireflyModel]:Destroy()
		end
		boundaryBoxes[fireflyModel] = nil
	end
end

-- Move the entire model to a target position using SetPrimaryPartCFrame
local function moveModelToPosition(fireflyModel, primaryPart, targetPosition, duration)
	local currentCFrame = primaryPart.CFrame
	local currentPosition = currentCFrame.Position
	
	-- Calculate target CFrame (position + rotation if facing movement)
	local targetCFrame
	if MOVEMENT_CONFIG.FACE_MOVEMENT then
		local direction = (targetPosition - currentPosition).Unit
		
		-- Create a CFrame where positive X axis points toward the movement direction
		-- First, create a standard lookAt CFrame (where -Z points toward target)
		local standardLookAt = CFrame.lookAt(targetPosition, targetPosition + direction)
		
		-- Then rotate -90 degrees around Y axis so that +X points toward target instead of -Z
		-- This rotates the firefly so its positive X axis becomes the front
		targetCFrame = standardLookAt * CFrame.Angles(0, math.rad(-90), 0)
	else
		-- Just move position, keep same rotation
		targetCFrame = currentCFrame + (targetPosition - currentPosition)
	end
	
	-- Create a custom tween that moves the entire model
	local startTime = tick()
	local connection
	
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local progress = math.min(elapsed / duration, 1)
		
		-- Apply easing
		local easedProgress = progress
		if MOVEMENT_CONFIG.EASING_STYLE == Enum.EasingStyle.Sine then
			if MOVEMENT_CONFIG.EASING_DIRECTION == Enum.EasingDirection.InOut then
				easedProgress = (1 - math.cos(progress * math.pi)) / 2
			end
		end
		
		-- Interpolate between start and target CFrame
		local interpolatedCFrame = currentCFrame:Lerp(targetCFrame, easedProgress)
		
		-- Move the entire model using SetPrimaryPartCFrame
		if fireflyModel.Parent and fireflyModel.PrimaryPart then
			fireflyModel:SetPrimaryPartCFrame(interpolatedCFrame)
		end
		
		-- Check if tween is complete
		if progress >= 1 then
			connection:Disconnect()
		end
	end)
	
	-- Return a promise-like object
	local completed = {}
	completed.Completed = {
		Wait = function()
			while tick() - startTime < duration do
				RunService.Heartbeat:Wait()
			end
		end
	}
	
	return completed
end

-- ========================================================================================
-- MOVEMENT BEHAVIOR FUNCTIONS
-- ========================================================================================

-- Main movement loop for a single firefly
local function startMovementLoop(fireflyModel, primaryPart, floorPosition)
	local movementCoroutine = coroutine.create(function()
		local currentPosition = primaryPart.CFrame.Position
		
		while primaryPart.Parent and activeFireflies[fireflyModel] do
			-- Generate next waypoint
			local targetPosition = generateWaypoint(floorPosition, currentPosition)
			local distance = (targetPosition - currentPosition).Magnitude
			local speed = calculateMovementSpeed(distance)
			local duration = distance / speed
			
			-- Move the entire model using SetPrimaryPartCFrame
			local movementPromise = moveModelToPosition(fireflyModel, primaryPart, targetPosition, duration)
			
			-- Wait for movement to complete
			movementPromise.Completed:Wait()
			
			-- Update current position
			currentPosition = primaryPart.CFrame.Position
			
			-- Check if still valid
			if not primaryPart.Parent or not activeFireflies[fireflyModel] then break end
			
			-- Random pause chance
			if math.random() < MOVEMENT_CONFIG.PAUSE_CHANCE then
				local pauseDuration = math.random() * (MOVEMENT_CONFIG.PAUSE_MAX - MOVEMENT_CONFIG.PAUSE_MIN) + MOVEMENT_CONFIG.PAUSE_MIN
				wait(pauseDuration)
			end
		end
	end)
	
	-- Store the coroutine for cleanup
	if not movementCoroutines[fireflyModel] then
		movementCoroutines[fireflyModel] = {}
	end
	table.insert(movementCoroutines[fireflyModel], movementCoroutine)
	
	-- Start the coroutine
	coroutine.resume(movementCoroutine)
end

-- ========================================================================================
-- MAIN FIREFLY CONTROL FUNCTIONS
-- ========================================================================================

-- Start movement behavior for a firefly model
local function startFireflyMovement(fireflyModel)
	-- Find the primary part to move
	local primaryPart = getFireflyPrimaryPart(fireflyModel)
	if not primaryPart then
		return
	end
	
	-- Ensure the model's PrimaryPart is set (required for moving entire model)
	if not fireflyModel.PrimaryPart then
		fireflyModel.PrimaryPart = primaryPart
	end
	
	-- Set floor position (where the firefly starts - this becomes the floor of the boundary)
	local floorPosition = primaryPart.CFrame.Position
	
	-- Store firefly data
	activeFireflies[fireflyModel] = {
		primaryPart = primaryPart,
		centerPosition = floorPosition,  -- This is now the floor level, not center
		startTime = tick()
	}
	
	-- Create boundary box visualization if enabled
	local boundaryBox = createBoundaryBox(fireflyModel, floorPosition)
	if boundaryBox then
		boundaryBoxes[fireflyModel] = boundaryBox
	end
	
	-- Start the movement loop
	startMovementLoop(fireflyModel, primaryPart, floorPosition)
end

-- Stop movement behavior for a firefly model
local function stopFireflyMovement(fireflyModel)
	-- Mark firefly as inactive (this will stop the coroutines)
	if activeFireflies[fireflyModel] then
		activeFireflies[fireflyModel] = nil
	end
	
	-- Clean up movement coroutines
	if movementCoroutines[fireflyModel] then
		movementCoroutines[fireflyModel] = nil
	end
	
	-- Clean up boundary box visualization
	removeBoundaryBox(fireflyModel)
end

-- ========================================================================================
-- INITIALIZATION
-- ========================================================================================

-- Handle existing Firefly-tagged models
local existingFireflies = CollectionService:GetTagged("Firefly")

for _, object in pairs(existingFireflies) do
	if object:IsA("Model") then
		startFireflyMovement(object)
	end
end

-- ========================================================================================
-- EVENT HANDLERS
-- ========================================================================================

-- Handle new Firefly-tagged models
CollectionService:GetInstanceAddedSignal("Firefly"):Connect(function(object)
	if object:IsA("Model") then
		startFireflyMovement(object)
	end
end)

-- Handle removed Firefly-tagged models
CollectionService:GetInstanceRemovedSignal("Firefly"):Connect(function(object)
	if object:IsA("Model") then
		stopFireflyMovement(object)
	end
end)

-- Clean up when models are destroyed
workspace.DescendantRemoving:Connect(function(descendant)
	if activeFireflies[descendant] then
		stopFireflyMovement(descendant)
	end
	
	-- Also clean up any orphaned boundary boxes
	if boundaryBoxes[descendant] then
		removeBoundaryBox(descendant)
	end
end)
