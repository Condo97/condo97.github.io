-- AnimalConfig.luau
-- Configuration for animal species and tags

local AnimalConfig = {}

-- Bunny species tags
AnimalConfig.BunnySpecies = {
    BROWN_BUNNY = "animalBrownBunny",
    TAN_BUNNY = "animalTanBunny", 
    WHITE_BUNNY = "animalWhiteBunny",
    WHITE_BLACK_BUNNY = "animalWhiteAndBlackBunny",
    EVIL_BUNNY = "animalEvilBunny"
}

-- Other animal species tags  
AnimalConfig.OtherSpecies = {
    DOG = "animalDog", 
    CAT = "animalCat"
}

-- Status tags
AnimalConfig.StatusTags = {
    INFECTED = "animalInfected"
}

-- Get all bunny species tags as an array
AnimalConfig.AllBunnies = {
    AnimalConfig.BunnySpecies.BROWN_BUNNY,
    AnimalConfig.BunnySpecies.TAN_BUNNY,
    AnimalConfig.BunnySpecies.WHITE_BUNNY,
    AnimalConfig.BunnySpecies.WHITE_BLACK_BUNNY,
    AnimalConfig.BunnySpecies.EVIL_BUNNY
}

-- Get all other animal species tags as an array
AnimalConfig.AllOtherAnimals = {
    AnimalConfig.OtherSpecies.DOG,
    AnimalConfig.OtherSpecies.CAT
}

-- Get all species tags combined
AnimalConfig.AllSpecies = {}
for _, bunny in pairs(AnimalConfig.AllBunnies) do
    table.insert(AnimalConfig.AllSpecies, bunny)
end
for _, animal in pairs(AnimalConfig.AllOtherAnimals) do
    table.insert(AnimalConfig.AllSpecies, animal)
end

-- Counter key generators
AnimalConfig.CounterKeys = {
    Total = function(species)
        return species .. "_Total"
    end,
    Infected = function(species)
        return species .. "_Infected" 
    end,
    Cured = function(species)
        return species .. "_Cured"
    end
}

-- Helper function to check if a tag is a bunny species
function AnimalConfig.isBunnySpecies(tag)
    for _, bunnyTag in pairs(AnimalConfig.AllBunnies) do
        if bunnyTag == tag then
            return true
        end
    end
    return false
end

-- Helper function to get species display name
AnimalConfig.DisplayNames = {
    ["animalBrownBunny"] = "Brown Bunny",
    ["animalTanBunny"] = "Tan Bunny",
    ["animalWhiteBunny"] = "White Bunny", 
    ["animalWhiteAndBlackBunny"] = "White & Black Bunny",
    ["animalEvilBunny"] = "Evil Bunny",
    ["animalDog"] = "Dog",
    ["animalCat"] = "Cat"
}

return AnimalConfig
