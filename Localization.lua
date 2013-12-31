local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
if not L then return end

L["%s resisted!"] = true
L["Pulling %s"] = true
L["%s casted on %s"] = true
L["%s started on %s"] = true
L["%s ended on %s"] = true
L["%s faded from %s"] = true
L["%s removed from %s"] = true
L["Failed to dispell %s from %s"] = true
L["%s failed on %s (%s)!"] = true

