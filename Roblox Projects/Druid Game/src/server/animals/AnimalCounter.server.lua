
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import animal configuration
local AnimalConfig = require(ReplicatedStorage.Shared.AnimalConfig)

local COUNTER_FOLDER_NAME = "AnimalCounters"

local counts = {}
local tracked = setmetatable({}, {__mode="k"})

-- Put counters folder into Replicated Storage
local countersFolder = ReplicatedStorage:FindFirstChild(COUNTER_FOLDER_NAME)
if not countersFolder then
    countersFolder = Instance.new("Folder")
    countersFolder.Name = COUNTER_FOLDER_NAME
    countersFolder.Parent = ReplicatedStorage
end

local function publish(key)
    countersFolder:SetAttribute(key, counts[key] or 0)
end

local function bump(key, delta)
    delta = delta or 1
    counts[key] = (counts[key] or 0) + delta
    publish(key)
end

-- Get the species tag from an instance (returns nil if no species tag found)
local function getSpeciesTag(instance)
    for _, species in pairs(AnimalConfig.AllSpecies) do
        if CollectionService:HasTag(instance, species) then
            return species
        end
    end
    return nil
end

-- Check if an animal is infected
local function isInfected(instance)
    return CollectionService:HasTag(instance, AnimalConfig.StatusTags.INFECTED)
end

-- Update counts for an animal instance
local function updateAnimalCounts(instance, delta)
    local species = getSpeciesTag(instance)
    if not species then return end -- Not an animal
    
    delta = delta or 1
    local infected = isInfected(instance)
    
    -- Update total count
    bump(AnimalConfig.CounterKeys.Total(species), delta)
    
    -- Update status count
    if infected then
        bump(AnimalConfig.CounterKeys.Infected(species), delta)
    else
        bump(AnimalConfig.CounterKeys.Cured(species), delta)
    end
end

-- Handle when an animal is added or removed
local function onAnimalAdded(instance)
    if tracked[instance] then return end -- Already tracking
    tracked[instance] = true
    updateAnimalCounts(instance, 1)
end

local function onAnimalRemoved(instance)
    if not tracked[instance] then return end -- Not tracking
    tracked[instance] = nil
    updateAnimalCounts(instance, -1)
end

-- Handle infection status changes
local function onInfectionAdded(instance)
    local species = getSpeciesTag(instance)
    if not species or not tracked[instance] then return end
    
    -- Move from cured to infected
    bump(AnimalConfig.CounterKeys.Cured(species), -1)
    bump(AnimalConfig.CounterKeys.Infected(species), 1)
end

local function onInfectionRemoved(instance)
    local species = getSpeciesTag(instance)
    if not species or not tracked[instance] then return end
    
    -- Move from infected to cured
    bump(AnimalConfig.CounterKeys.Infected(species), -1)
    bump(AnimalConfig.CounterKeys.Cured(species), 1)
end

-- Initialize counts to 0
for _, species in pairs(AnimalConfig.AllSpecies) do
    bump(AnimalConfig.CounterKeys.Total(species), 0)
    bump(AnimalConfig.CounterKeys.Infected(species), 0)
    bump(AnimalConfig.CounterKeys.Cured(species), 0)
end

-- Set up CollectionService connections for each animal species
for _, species in pairs(AnimalConfig.AllSpecies) do
    -- Connect to species tag events
    CollectionService:GetInstanceAddedSignal(species):Connect(onAnimalAdded)
    CollectionService:GetInstanceRemovedSignal(species):Connect(onAnimalRemoved)
    
    -- Count existing animals with this species tag
    for _, existingAnimal in pairs(CollectionService:GetTagged(species)) do
        onAnimalAdded(existingAnimal)
    end
end

-- Set up CollectionService connections for infection status
CollectionService:GetInstanceAddedSignal(AnimalConfig.StatusTags.INFECTED):Connect(onInfectionAdded)
CollectionService:GetInstanceRemovedSignal(AnimalConfig.StatusTags.INFECTED):Connect(onInfectionRemoved)

print("AnimalCounter initialized with species:", table.concat(AnimalConfig.AllSpecies, ", "))