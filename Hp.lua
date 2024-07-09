setDefaultTab ("HP");
UI.Separator()
UI.Button("Add HP Macro", function(newText)
    UI.MultilineEditorWindow(storage.ingame_Macro or "", {title="Macro HP editor", description="You can add your custom scrupts here"}, function(text)
      storage.ingame_Macro = text
      reload()
    end)
  end)
  UI.Separator()
  UI.Label('Added Macro')
  for _, scripts in pairs({storage.ingame_Macro}) do
    if type(scripts) == "string" and scripts:len() > 3 then
      local status, result = pcall(function()
        assert(load(scripts, "ingame_editor"))()
      end)
      if not status then 
        error("Ingame edior error:\n" .. result)
      end
    end
  end
  UI.Separator()
UI.Label("Healing Spells")

if type(storage.healing1) ~= "table" then
  storage.healing1 = {on=false, title="HP%", min=51, max=90}
end
if type(storage.healing2) ~= "table" then
  storage.healing2 = {on=false, title="HP%", min=0, max=50}
end

for _, healingInfo in ipairs({storage.healing1, storage.healing2}) do
  local healingmacro = macro(20, function()
    local hp = player:getHealthPercent()
    if healingInfo.max >= hp and hp >= healingInfo.min then
      if TargetBot then 
        TargetBot.saySpell(healingInfo.text)
      else
        say(healingInfo.text)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on)

  UI.DualScrollPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on)
  end)
end
UI.Separator()
local panelName = "Traineradv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titletrainer
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Trainer Spell')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]])
  ui:setId(panelName)
local TrainerWindow = setupUI([[

MainWindow
  !text: tr('Trainer Options')
  size: 200 180
  @onEscape: self:hide()

  Label
    id: SpellName
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Spell Name
    margin-bottom: 3

  BotTextEdit
    id: trainerSpell
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SpellName.bottom
    text-align: center
    margin-bottom: 5

  Label
    id: Percent
    anchors.top: trainerSpell.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    margin-top: 5

  HorizontalScrollBar
    id: maxmanaPercent
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Percent.bottom
    margin-top: 5
    minimum: 1
    maximum: 100
    step: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8    

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
    margin-right: 5   
]], g_ui.getRootWidget())

if not storage[panelName] then
  storage[panelName] = {
    maxmanaPercent = 50,
  }
  end
local config = storage[panelName]
  rootWidget = g_ui.getRootWidget()
  if rootWidget then
  TrainerWindow:hide()

  ui.titletrainer:setOn(storage.titletrainerEnabled);
  ui.titletrainer.onClick = function(widget)
      storage.titletrainerEnabled = not storage.titletrainerEnabled;
      widget:setOn(storage.titletrainerEnabled);
  end
  ui.editList.onClick = function(widget)
    TrainerWindow:show()
    TrainerWindow:raise()
    TrainerWindow:focus()
  end
  TrainerWindow.closeButton.onClick = function(widget)
    TrainerWindow:hide()
  end
  local updatePercentText = function()
    TrainerWindow.Percent:setText("Activates Above " .. config.maxmanaPercent .. "% Mana")  
  end
  TrainerWindow.maxmanaPercent:setValue(config.maxmanaPercent)
  TrainerWindow.maxmanaPercent.onValueChange = function(scroll, value)
    config.maxmanaPercent = value
    updatePercentText()
  end
  updatePercentText()

  TrainerWindow.trainerSpell.onTextChange = function(widget, text)
    storage[panelName].trainerSpell = text
  end
  TrainerWindow.trainerSpell:setText(config.trainerSpell) 
end
macro(100, function()
  if (not storage.titletrainerEnabled) then
    elseif (manapercent() >= config.maxmanaPercent) then
      say(config.trainerSpell)
    end
end)
UI.Separator()
UI.Label("Potions")

if type(storage.hpitem1) ~= "table" then
  storage.hpitem1 = {on=false, title="HP%", item=236, min=51, max=90}
end
if type(storage.hpitem2) ~= "table" then
  storage.hpitem2 = {on=false, title="HP%", item=10578, min=0, max=50}
end
if type(storage.manaitem1) ~= "table" then
  storage.manaitem1 = {on=false, title="MP%", item=11289, min=51, max=90}
end
if type(storage.manaitem2) ~= "table" then
  storage.manaitem2 = {on=false, title="MP%", item=237, min=0, max=50}
end

for i, healingInfo in ipairs({storage.hpitem1, storage.hpitem2, storage.manaitem1, storage.manaitem2}) do
  local healingmacro = macro(20, function()
    local hp = i <= 2 and player:getHealthPercent() or math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
    if healingInfo.max >= hp and hp >= healingInfo.min then
      if TargetBot then 
        TargetBot.useItem(healingInfo.item, healingInfo.subType, player) -- sync spell with targetbot if available
      else
        local thing = g_things.getThingType(healingInfo.item)
        local subType = g_game.getClientVersion() >= 860 and 0 or 1
        if thing and thing:isFluidContainer() then
          subType = healingInfo.subType
        end
        g_game.useInventoryItemWith(healingInfo.item, player, subType)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on)

  UI.DualScrollItemPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on and healingInfo.item > 100)
  end)
end
UI.Separator();
UI.Label("Defensive Spells")
UI.Separator()
---kawarimi--
local panelName = "Kawaadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titlekawa
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Evasive Spell')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]])
  ui:setId(panelName)
local KawaListWindow = setupUI([[

MainWindow
  !text: tr('Evasive  Options')
  size: 200 180
  @onEscape: self:hide()

  Label
    id: SpellName
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Spell Name
    margin-bottom: 3

  BotTextEdit
    id: kawaSpell
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SpellName.bottom
    text-align: center
    margin-bottom: 5

  Label
    id: Percent
    anchors.top: kawaSpell.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    margin-top: 5

  HorizontalScrollBar
    id: minActivePercent
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Percent.bottom
    margin-top: 5
    minimum: 1
    maximum: 100
    step: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8    

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
    margin-right: 5   
]], g_ui.getRootWidget())

if not storage[panelName] then
  storage[panelName] = {
    minActivePercent = 80,
  }
end
local config = storage[panelName]
  rootWidget = g_ui.getRootWidget()
  if rootWidget then
  KawaListWindow:hide()

  ui.titlekawa:setOn(storage.titlekawaEnabled);
  ui.titlekawa.onClick = function(widget)
      storage.titlekawaEnabled = not storage.titlekawaEnabled;
      widget:setOn(storage.titlekawaEnabled);
  end
  ui.editList.onClick = function(widget)
    KawaListWindow:show()
    KawaListWindow:raise()
    KawaListWindow:focus()
  end
  KawaListWindow.closeButton.onClick = function(widget)
    KawaListWindow:hide()
  end
  local updatePercentText = function()
    KawaListWindow.Percent:setText("Activates Below " .. config.minActivePercent .. "% hp")  
  end
  KawaListWindow.minActivePercent:setValue(config.minActivePercent)
  KawaListWindow.minActivePercent.onValueChange = function(scroll, value)
    config.minActivePercent = value
    updatePercentText()
  end
  updatePercentText()

  KawaListWindow.kawaSpell.onTextChange = function(widget, text)
    storage[panelName].kawaSpell = text
  end
  KawaListWindow.kawaSpell:setText(config.kawaSpell) 
end
macro(100, function() 
  if (not storage.titlekawaEnabled) then
  elseif (hppercent() <= config.minActivePercent) then
    say(config.kawaSpell) 
  end
end)
------
UI.Separator()
local panelName = "defenseadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titleDefense
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Defensive Spell')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]])
  ui:setId(panelName)

local DefenseListWindow = setupUI([[

MainWindow
  !text: tr('Defensive  Options')
  size: 200 250
  @onEscape: self:hide()

  Label
    id: SpellNameActive
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Spell Name Active
    margin-bottom: 3

  BotTextEdit
    id: ActiveSpell
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SpellNameActive.bottom
    text-align: center
    margin-bot: 5

  Label
    id: Percent
    anchors.top: ActiveSpell.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    margin-top: 5

  HorizontalScrollBar
    id: minActivePercent
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Percent.bottom
    margin-top: 5
    minimum: 1
    maximum: 100
    step: 1
  
  Label
    id: SpellNameDisable
    anchors.top: minActivePercent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Spell Name Disable
    margin-bottom: 3
    margin-top: 10

  BotTextEdit
    id: DisableSpell
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SpellNameDisable.bottom
    text-align: center
    margin-bot: 5

  Label
    id: PercentDisable
    anchors.top: DisableSpell.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    margin-top: 5

  HorizontalScrollBar
    id: minDisablePercent
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: PercentDisable.bottom
    margin-top: 5
    minimum: 1
    maximum: 100
    step: 1

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8 

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
    margin-right: 1  
]], g_ui.getRootWidget())

if not storage[panelName] then
  storage[panelName] = {
    minActivePercent= 60,
    minDisablePercent= 90,
  }
end

local config = storage[panelName]
  rootWidget = g_ui.getRootWidget()
  if rootWidget then
  DefenseListWindow:hide()

  ui.titleDefense:setOn(storage.titleDefenseEnabled);
  ui.titleDefense.onClick = function(widget)
      storage.titleDefenseEnabled = not storage.titleDefenseEnabled;
      widget:setOn(storage.titleDefenseEnabled);
  end

  DefenseListWindow.closeButton.onClick = function(widget)
    DefenseListWindow:hide()
    end

    ui.editList .onClick = function(widget)
      DefenseListWindow:show()
      DefenseListWindow:raise()
      DefenseListWindow:focus()
    end

    local updatePercentText = function()
      DefenseListWindow.Percent:setText("Activates Below " .. config.minActivePercent .. "% hp")  
    end
    DefenseListWindow.minActivePercent:setValue(config.minActivePercent)
    DefenseListWindow.minActivePercent.onValueChange = function(scroll, value)
      config.minActivePercent = value
      updatePercentText()
    end
    updatePercentText()

    local updatePercentDisableText = function()
      DefenseListWindow.PercentDisable:setText("Disables Above " .. config.minDisablePercent .. "% hp")  
    end
    DefenseListWindow.minDisablePercent:setValue(config.minDisablePercent)
    DefenseListWindow.minDisablePercent.onValueChange = function(scroll, value)
      config.minDisablePercent = value
      updatePercentDisableText()
    end
    updatePercentDisableText()

    DefenseListWindow.ActiveSpell.onTextChange = function(widget, text)
      storage[panelName].ActiveSpell = text
    end
    DefenseListWindow.DisableSpell.onTextChange = function(widget, text)
      storage[panelName].DisableSpell = text
    end
    DefenseListWindow.ActiveSpell:setText(config.ActiveSpell) 
    DefenseListWindow.DisableSpell:setText(config.DisableSpell) 

    macro(98,  function()
      if (not storage.titleDefenseEnabled) then
      elseif (hppercent() <= config.minActivePercent and not hasManaShield()) then
        say(config.ActiveSpell)
      end
      if (not storage.titleDefenseEnabled) then
      elseif (hppercent() >= config.minDisablePercent and hasManaShield()) then
          say(config.DisableSpell)
    end
    end)
  end