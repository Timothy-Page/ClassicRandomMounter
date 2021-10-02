local addonName, ClassicRandomMounter = ...

SLASH_CRM1 = "/CRM"
local inDebugMode = false

local mounted = IsMounted()
local inCombat = InCombatLockdown()

local myMounts = {
  ["myGroundMounts"] = {},
  ["mySwiftGroundMounts"] = {},
  ["myFlyingMounts"] = {},
  ["mySwiftFlyingMounts"] = {},
  ["mySuperSwiftFlyingMounts"] = {}
}

local myMountsCount = 0
local myMountsPreviousCount = 0

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--Create delay function
local waitTable = {}
local waitFrame = nil

local function crm_wait(delay, func, ...)
    if(type(delay) ~= "number" or type(func) ~= "function") then
      return false
    end
    if not waitFrame then
      waitFrame = CreateFrame("Frame", nil, UIParent)
      waitFrame:SetScript("OnUpdate", function (self, elapse)
        for i = 1, #waitTable do
          local waitRecord = tremove(waitTable, i)
          local d = tremove(waitRecord, 1)
          local f = tremove(waitRecord, 1)
          local p = tremove(waitRecord, 1)
          if d > elapse then
            tinsert(waitTable, i, {d - elapse, f, p})
            i = i + 1
          else
            i = i - 1
            f(unpack(p))
          end
        end
      end)
    end
    tinsert(waitTable, {delay, func, {...}})
    return true
end

local function PrintMounts()
  for mountType in pairs (myMounts) do
    local mountString = nil
    for mount in pairs(myMounts[mountType]) do
      if mountString == nil then
        mountString = myMounts[mountType][mount][1]
      else
        mountString = mountString .. ", " .. myMounts[mountType][mount][1]
      end
    end
    print(mountType .. ": " .. tostring(mountString))
  end
end

local function GetRandomMount(mountType)
  local numberOfMounts = tablelength(myMounts[mountType])

  local mount

  if numberOfMounts > 0 then
    local mountID = math.random(numberOfMounts)

    mount = myMounts[mountType][mountID][1]
  end

  return mount
end

local function GetRandomMounts()
  local groundMount = GetRandomMount("myGroundMounts")
  local swiftGroundMount = GetRandomMount("mySwiftGroundMounts")
  local flyingMount = GetRandomMount("myFlyingMounts")
  local swiftFlyingMount = GetRandomMount("mySwiftFlyingMounts")
  local superSwiftFlyingMount = GetRandomMount("mySuperSwiftFlyingMounts")
  
  if superSwiftFlyingMount ~= nil then
    swiftFlyingMount = superSwiftFlyingMount
  end
  if swiftFlyingMount ~= nil then
    flyingMount = swiftFlyingMount
  end
  if swiftGroundMount ~= nil then
    groundMount = swiftGroundMount
  end

  return groundMount, flyingMount
end

local function UpdateMacro(groundMount, flyingMount)

    local groundMountMacro = ""
    local groundMountMacro2 = ""
    local flyingMountMacro = ""
    local tooltip = ""

    if groundMount ~= nil then
      groundMountMacro = "\n/cast [nomounted,mod:alt] " .. tostring(groundMount)
      groundMountMacro2 = "\n/cast [nomounted] " .. tostring(groundMount)
      tooltip = tostring(groundMount)
    end
    if flyingMount ~= nil then
      flyingMountMacro = "\n/cast [nomounted,flyable] " .. tostring(flyingMount)
      if 	IsFlyableArea() then
        tooltip = tostring(flyingMount)
      end
    end

    local body = "#showtooltip " .. tooltip .. "\n/stopcasting" .. groundMountMacro .. flyingMountMacro .. groundMountMacro2 .. "\n/CRM" .. "\n/dismount"
    EditMacro("Mount", "Mount", nil, body, 1, 1)
end

local function CheckIfItemInBags(item)
  local foundItem = false
  local _, itemLink = GetItemInfo(item)

  if itemLink ~= nil then
    for bagID = 0, NUM_BAG_SLOTS do
      for slotInBag = 1, GetContainerNumSlots(bagID) do
        if(GetContainerItemLink(bagID, slotInBag) == itemLink) then
          if inDebugMode then
            print("CRM Found: " .. GetContainerItemLink(bagID, slotInBag))
          end
          foundItem = true
        end
      end
    end
  end

  return foundItem
end

local function UpdateMyMounts()
  myMounts = {
    ["myGroundMounts"] = {},
    ["mySwiftGroundMounts"] = {},
    ["myFlyingMounts"] = {},
    ["mySwiftFlyingMounts"] = {},
    ["mySuperSwiftFlyingMounts"] = {}
  }

  for mount in pairs(ClassicRandomMounter.itemMounts) do
    if CheckIfItemInBags(ClassicRandomMounter.itemMounts[mount][2]) then
      if ClassicRandomMounter.itemMounts[mount][3] == 1 then
        table.insert(myMounts["myGroundMounts"], ClassicRandomMounter.itemMounts[mount])
      end
      if ClassicRandomMounter.itemMounts[mount][4] == 1 then
        table.insert(myMounts["mySwiftGroundMounts"], ClassicRandomMounter.itemMounts[mount])
      end
      if ClassicRandomMounter.itemMounts[mount][5] == 1 then
        table.insert(myMounts["myFlyingMounts"], ClassicRandomMounter.itemMounts[mount])
      end
      if ClassicRandomMounter.itemMounts[mount][6] == 1 then
        table.insert(myMounts["mySwiftFlyingMounts"], ClassicRandomMounter.itemMounts[mount])
      end
      if ClassicRandomMounter.itemMounts[mount][7] == 1 then
        table.insert(myMounts["mySuperSwiftFlyingMounts"], ClassicRandomMounter.itemMounts[mount])
      end
    end
  end
  
  for mount in pairs(ClassicRandomMounter.spellMounts) do
    if IsSpellKnown(ClassicRandomMounter.spellMounts[mount][2]) then

      if ClassicRandomMounter.spellMounts[mount][3] == 1 then
        table.insert(myMounts["myGroundMounts"], ClassicRandomMounter.spellMounts[mount])
      end
      if ClassicRandomMounter.spellMounts[mount][4] == 1 then
        table.insert(myMounts["mySwiftGroundMounts"], ClassicRandomMounter.spellMounts[mount])
      end
      if ClassicRandomMounter.spellMounts[mount][5] == 1 then
        table.insert(myMounts["myFlyingMounts"], ClassicRandomMounter.spellMounts[mount])
      end
      if ClassicRandomMounter.spellMounts[mount][6] == 1 then
        table.insert(myMounts["mySwiftFlyingMounts"], ClassicRandomMounter.spellMounts[mount])
      end
      if ClassicRandomMounter.spellMounts[mount][7] == 1 then
        table.insert(myMounts["mySuperSwiftFlyingMounts"], ClassicRandomMounter.spellMounts[mount])
      end
    end
  end
  
  local numberOfMounts = tablelength(myMounts["myGroundMounts"])
  numberOfMounts = numberOfMounts + tablelength(myMounts["mySwiftGroundMounts"])
  numberOfMounts = numberOfMounts + tablelength(myMounts["myFlyingMounts"])
  numberOfMounts = numberOfMounts + tablelength(myMounts["mySwiftFlyingMounts"])
  numberOfMounts = numberOfMounts + tablelength(myMounts["mySuperSwiftFlyingMounts"])

  myMountsPreviousCount = myMountsCount
  myMountsCount = numberOfMounts

  if inDebugMode then
    print("Total Mounts Found: " .. tostring(numberOfMounts))
    PrintMounts()
  end
end

local function InitialStartup(forceRunHandler, debugString)
  UpdateMyMounts()

  local groundMount, flyingMount = GetRandomMounts()

  UpdateMacro(groundMount, flyingMount)
end

local function CRMHandler(parameter)
    
  if(string.len(parameter) > 0) then
    if parameter == "list" then
      PrintMounts()
    elseif parameter == "update" then
      InitialStartup()
    elseif parameter == "debug" then
      inDebugMode = true
    else
      print(parameter)
    end
  else
    if myMountsCount ~= myMountsPreviousCount then --used to ensure that all mounts are found
      InitialStartup()
    end
    local groundMount, flyingMount = GetRandomMounts()
    if IsMounted() == false then
      crm_wait(0.1, UpdateMacro, groundMount, flyingMount)
    end
  end

  if inDebugMode then
      print("CRM was called with parameter: " .. parameter)
  end
end

-- Initilize addon when entering world
local EnterWorldFrame = CreateFrame("Frame")
EnterWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EnterWorldFrame:SetScript("OnEvent", InitialStartup)

-- Register slash commands
SlashCmdList["CRM"] = CRMHandler;