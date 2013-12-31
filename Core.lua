local _, class = UnitClass("player")
local player = UnitName("player")
if class ~= "HUNTER" then
	--return
end

local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local defaults =
{
  profile =
  {
	enabled = 
	{
		feigndeath = true,
		dispel = true,
		taunt = true,
		misdirection = true,
		misdirection_detailed = true,
		masterscall = true,
		roarofsacrifice = true,
	}
  }
}

local on_off = { [true] = "|cff00ff00enabled|r", [false] = "|cffff0000disabled|r"}
local function printf(s, ...)
	print("|cffabd473HunterAnnouncer|r|cff666666:|r " .. s:format(...))
end


local SPELL = {
	DISTRACTING_SHOT    = 20736,
	MISDIRECTION        = 34477,
	MISDIRECTION_EFFECT = 35079,
	TRANQUILIZING_SHOT  = 19801,
	FEIGN_DEATH         = 5384,
	MASTERS_CALL        = 53271,
	ROAR_OF_SACRIFICE   = 53480,
}

addon.options = {
	name = addonName,
	handler = addon,
	type = "group",
	args = {
		version =
		{
			--name = filled in during OnEnable
			type = 'description',
			fontSize = 'medium',
			cmdHidden = true,
			order = 1,
		},
		feigndeath = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.FEIGN_DEATH),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.feigndeath = val
				printf('%s: %s', GetSpellLink(SPELL.FEIGN_DEATH), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.feigndeath end,
			order = 10,
			width = 'full',
		},
		dispel = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.TRANQUILIZING_SHOT),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.dispel = val
				printf('%s: %s', GetSpellLink(SPELL.TRANQUILIZING_SHOT), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.dispel end,
			order = 20,
			width = 'full',
		},
		taunt = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.DISTRACTING_SHOT),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.taunt = val
				printf('%s: %s', GetSpellLink(SPELL.DISTRACTING_SHOT), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.taunt end,
			order = 30,
			width = 'full',
		},
		misdirection = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.MISDIRECTION),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.misdirection = val
				printf('%s: %s', GetSpellLink(SPELL.MISDIRECTION), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.misdirection end,
			order = 40,
			width = 'full',
		},
		misdirection_detailed = 
		{
			name = "Enable detailed info of "..GetSpellInfo(SPELL.MISDIRECTION)..' to yourself',
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.misdirection_detailed = val
				printf('%s (detail): %s', GetSpellLink(SPELL.MISDIRECTION), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.misdirection_detailed end,
			order = 50,
			width = 'full',
		},
		masterscall = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.MASTERS_CALL),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.masterscall = val
				printf('%s: %s', GetSpellLink(SPELL.MASTERS_CALL), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.masterscall end,
			order = 60,
			width = 'full',
		},
		roarofsacrifice = 
		{
			name = "Enable announce of "..GetSpellInfo(SPELL.ROAR_OF_SACRIFICE),
			type = "toggle",
			set = function(info,val)
				addon.db.profile.enabled.roarofsacrifice = val
				printf('%s: %s', GetSpellLink(SPELL.ROAR_OF_SACRIFICE), on_off[val])
			end,
			get = function(info) return addon.db.profile.enabled.roarofsacrifice end,
			order = 70,
			width = 'full',
		}
	}
}


addon = LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceConsole-3.0', 'AceEvent-3.0')

function addon:OnInitialize()
	self.options.args.version.name = "|cff30adffVersion " ..(GetAddOnMetadata(addonName, "Version") or "?").. "|r"

	self.db = LibStub("AceDB-3.0"):New("HunterAnnouncerDB", defaults)

	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
	self:RegisterChatCommand("hunterannouncer", "OnChatCommand")
	self:RegisterChatCommand("ha", "OnChatCommand")
	
	self.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName.." Profiles", self.profileOptions)
	self.profilesFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName.." Profiles", "Profiles", addonName)
	
	self:RegisterEvent("UI_ERROR_MESSAGE")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function addon:RefreshConfig()
  -- would do some stuff here
end

function addon:UI_ERROR_MESSAGE(e, arg1)
	if self.db.profile.enabled.feigndeath == false then return end
    if arg1 == ERR_FEIGN_DEATH_RESISTED then
		self:doAccounce(L['%s resisted!'], GetSpellLink(SPELL.FEIGN_DEATH))
		PlaySoundFile('Sound/Doodad/BellTollHorde.wav')
    end
end

local band = bit.band
local mine = bit.bor(
	0x00000001, -- COMBATLOG_OBJECT_AFFILIATION_MINE
	0x00000010, -- COMBATLOG_OBJECT_REACTION_FRIENDLY
	0x00000100, -- COMBATLOG_OBJECT_CONTROL_PLAYER
	0x00000400, -- COMBATLOG_OBJECT_TYPE_PLAYER
	0x00004000) -- COMBATLOG_OBJECT_TYPE_OBJECT

local function UnitIsA(unitFlags, flagType)
	if (band(band(unitFlags, flagType), 0x0000000F) > 0 and	-- COMBATLOG_OBJECT_AFFILIATION_MASK
		band(band(unitFlags, flagType), 0x000000F0) > 0 and	-- COMBATLOG_OBJECT_REACTION_MASK
		band(band(unitFlags, flagType), 0x00000300) > 0 and	-- COMBATLOG_OBJECT_CONTROL_MASK
		band(band(unitFlags, flagType), 0x0000FC00) > 0)	-- COMBATLOG_OBJECT_TYPE_MASK
	or  band(band(unitFlags, flagType), 0xFFFF0000) > 0 then	-- COMBATLOG_OBJECT_SPECIAL_MASK
		return true
	end
	return false
end

local lastMdTarget = ''

function addon:COMBAT_LOG_EVENT_UNFILTERED(e, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if destName then destName = strsplit('-', destName) end -- remove realm name
	
	if sourceName == player then
	
		if event == 'SPELL_CAST_SUCCESS' then
			local spellId = select(1, ...)		
		
			-- misdirection
			if self.db.profile.enabled.misdirection and spellId == SPELL.MISDIRECTION then
				self:doAccounce(L['%s casted on %s'], GetSpellLink(SPELL.MISDIRECTION), destName)
				lastMdTarget = destName
			end
			
			-- distract
			if self.db.profile.enabled.taunt and spellId == SPELL.DISTRACTING_SHOT then
				self:doAccounce(L['Pulling %s'], destName)
			end
			
			-- master's call
			if self.db.profile.enabled.masterscall and spellId == SPELL.MASTERS_CALL then
				self:doAccounce(L['%s casted on %s'], GetSpellLink(SPELL.MASTERS_CALL), destName)
			end
			
			-- roar of sacrifice
			if self.db.profile.enabled.roarofsacrifice and spellId == SPELL.ROAR_OF_SCRIFICE then
				self:doAccounce(L['%s casted on %s'], GetSpellLink(SPELL.ROAR_OF_SCRIFICE), destName)
			end
			
		elseif event == 'SPELL_AURA_APPLIED' then
			local spellId = select(1, ...)	
			
			-- misdirection
			if self.db.profile.enabled.misdirection_detailed and spellId == SPELL.MISDIRECTION_EFFECT then
				printf(L['%s started on %s'], GetSpellLink(SPELL.MISDIRECTION_EFFECT), lastMdTarget)
			end
		
		elseif event == 'SPELL_AURA_REMOVED' then
			local spellId = select(1, ...)	
			
			-- misdirection
			if self.db.profile.enabled.misdirection_detailed and spellId == SPELL.MISDIRECTION_EFFECT then
				printf(L['%s ended on %s'], GetSpellLink(SPELL.MISDIRECTION_EFFECT), lastMdTarget)
				lastMdTarget = ''
			end
			if self.db.profile.enabled.misdirection_detailed and spellId == SPELL.MISDIRECTION and not (lastMdTarget == '') then
				printf(L["%s faded from %s"], GetSpellLink(SPELL.MISDIRECTION), lastMdTarget)
				lastMdTarget = ''
			end
		
		elseif event == 'SPELL_DISPEL' then
			local spellId, spellName, spellSchool, extraSpellId, extraSpellName, _, auraType = select(1, ...)
			
			-- dispel
			if self.db.profile.enabled.dispel and spellId == SPELL.TRANQUILIZING_SHOT and auraType == "BUFF" then
				self:doAccounce(L['%s removed from %s'], GetSpellLink(extraSpellId), destName)
			end
			
		elseif event == 'SPELL_DISPEL_FAILED' then
			local spellId, spellName, spellSchool, extraSpellId, extraSpellName, _, auraType = select(1, ...)
			
			-- dispel
			if self.db.profile.enabled.dispel and spellId == SPELL.TRANQUILIZING_SHOT and auraType == "BUFF" then
				self:doAccounce(L['Failed to dispell %s from %s'], GetSpellLink(extraSpellId), destName)
			end
			
		end
	
	end
end

function addon:OnChatCommand (input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(self, "hunterannouncer", addonName, input)
	end
end

function addon:doAccounce(s, ...)
	text = s:format(...)
	
	if GetNumPartyMembers() > 0 and GetNumRaidMembers() == 0 then
		SendChatMessage(text, "PARTY")
		return
	end

	if GetNumRaidMembers() > 0  then
		SendChatMessage(text, "RAID")
		return
	end
	
	printf(s, ...)
end
