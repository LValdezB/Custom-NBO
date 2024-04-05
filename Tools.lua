-- tools tab
setDefaultTab("Tools")
UI.Separator()
UI.Label("Facility")
UI.Separator()
UI.Button("Stop Cave/Target Bot", function()
  if CaveBot.isOn() or TargetBot.isOn() then
      CaveBot.setOff()
      TargetBot.setOff()
  elseif CaveBot.isOff() or TargetBot.isOff() then
      CaveBot.setOn()
      TargetBot.setOn()
   end
  end)
UI.Separator()
macro(500, "power down", function()
  say('power down')
  end)
---bUG MAP WASD
UI.Separator()
BugMap = {};

local availableKeys = {
  ['W'] = { 0, -5 },
  ['S'] = { 0, 5 },
  ['A'] = { -5, 0 },
  ['D'] = { 5, 0 },
};

BugMap.macro = macro(1, "Bug Map WASD", function() 
  BugMap.logic();
end)

function BugMap.logic()
  local playerPos = pos();
  local tile;
  for key, value in pairs(availableKeys) do
    if (modules.corelib.g_keyboard.isKeyPressed(key)) then
      playerPos.x = playerPos.x + value[1];
      playerPos.y = playerPos.y + value[2];
      tile = g_map.getTile(playerPos);
      break;
    end
  end
  if (not tile) then return end;
  g_game.use(tile:getTopUseThing());
end
--bUG MAP seta---
local function checkPos(x, y)
  xyz = g_game.getLocalPlayer():getPosition()
  xyz.x = xyz.x + x
  xyz.y = xyz.y + y
  tile = g_map.getTile(xyz)
  if tile then
   return g_game.use(tile:getTopUseThing())  
  else
   return false
  end
 end
 
 
 bugMap = macro(1, "Bug Map Seta", function() 
  if modules.corelib.g_keyboard.isKeyPressed('Up') then
   checkPos(0, -5)
  elseif modules.corelib.g_keyboard.isKeyPressed('Right') then
   checkPos(5, 0)
  elseif modules.corelib.g_keyboard.isKeyPressed('Down') then
   checkPos(0, 5)
  elseif modules.corelib.g_keyboard.isKeyPressed('Left') then
   checkPos(-5, 0)
  end
 end)
---Bless------
local windowUI = setupUI([[
MainWindow
  id: main
  !text: tr('Bless')
  size: 230 310
  scrollable: true
    
  ScrollablePanel
    id: TpList
    anchors.top: parent.top
    anchors.left: parent.left
    size: 190 225
    vertical-scrollbar: mainScroll

    Button
      !text: tr('first bless')
      anchors.top: parent.top
      anchors.left: parent.left
      width: 165

    Button
      !text: tr('second bless')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('third bless')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('fourth bless')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('fifth bless')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

  VerticalScrollBar  
    id: mainScroll
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    step: 48
    pixels-scroll: true
    
  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
    margin-right: 15

]], g_ui.getRootWidget());
windowUI:hide();

Bless = {};
Bless.macro = macro(100, "Bless", function() end);
local TpList = windowUI.TpList;

Bless.close = function()
  windowUI:hide()
  NPC.say('bye');
end

Bless.show = function()
    print("Ta aqui?")
    windowUI:show();
    windowUI:raise();
    windowUI:focus();
end

windowUI.closeButton.onClick = function()
    Bless.close();
end

Bless.ToBless = function(Bless)
        NPC.say(Bless);
        schedule(100, function()
          NPC.say('yes');
        end);
      end


for i, child in pairs(TpList:getChildren()) do
    child.onClick = function()
        Bless.ToBless(child:getText())
    end
end

onTalk(function(name, level, mode, text, channelId, pos)
  if (Bless.macro.isOff()) then return; end
  if (name ~= 'benefactor') then return; end              
  if (mode ~= 51) then return; end
  if (text:find('I can grant you blessings to suffer less in this dangerous ninja world! I offer progressive blesses')) then
      Bless.show();
  else
      Bless.close();
  end
end);

onKeyDown(function(keys)
    if (keys == 'Escape' and windowUI:isVisible())  then
        Bless.close();
    end
end);
---------
local showhp = macro(20000, "All Creature HP %", function() end)
onCreatureHealthPercentChange(function(creature, healthPercent)
    if showhp:isOff() then  return end
    if creature:isMonster() or creature:isPlayer() and creature:getPosition() and pos() then
        if getDistanceBetween(pos(), creature:getPosition()) <= 5 then
            creature:setText(healthPercent .. "%")
        else
            creature:clearText()
        end
    end
end)
UI.Separator()
UI.Label("Utility")
UI.Separator()
---auto haste--
macro(500, "Auto Haste", nil, function()
  if not hasHaste() and storage.autoHasteText:len() > 0 then
    if saySpell(storage.autoHasteText) then
      delay(5000)
    end
  end
end)
addTextEdit("autoHasteText", storage.autoHasteText or "chakra feet", function(widget, text) 
  storage.autoHasteText = text
end)
---Buff--
macro(5000, "Auto Buff", function()
  if not hasPartyBuff() and storage.autoBuffText:len() > 0 then
    if saySpell(storage.autoBuffText) then
      delay(1000)
    end
  end
end)

addTextEdit("autoBuffText", storage.autoBuffText or "Buff", function(widget, text)
  storage.autoBuffText = text
end)
---jump
local panelName = "Jumpadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titlejump
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Jump')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]], parent)
  ui:setId(panelName)
local JumpListWindow = setupUI([[
MainWindow
  !text: tr('Jump Options')
  size: 150 230
  @onEscape: self:hide()

  Label
    id: Fistkey
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: North

  BotTextEdit
    id: Jumpkey
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Fistkey.bottom
    margin-top: 3

  Label
    id: Secondkey
    anchors.top: Jumpkey.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: South

  BotTextEdit
    id: Jumpkeys
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Secondkey.bottom
    margin-top: 3

  Label
    id: Tirdkey
    anchors.top: Jumpkeys.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: West

  BotTextEdit
    id: Jumpkeyone
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Tirdkey.bottom
    margin-top: 3

  Label
    id: Fourthkey
    anchors.top: Jumpkeyone.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: East

  BotTextEdit
    id: Jumpkeytwo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Fourthkey.bottom
    margin-top: 3

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
    Jumpkey= 'Up',
    Jumpkeys= 'Down',
    Jumpkeyone='Left',
    Jumpkeytwo='Right',
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
JumpListWindow:hide()

ui.titlejump:setOn(storage.titlejumpEnabled);
ui.titlejump.onClick = function(widget)
    storage.titlejumpEnabled = not storage.titlejumpEnabled;
    widget:setOn(storage.titlejumpEnabled);
end

ui.editList.onClick = function(widget)
  JumpListWindow:show()
  JumpListWindow:raise()
  JumpListWindow:focus()
end
JumpListWindow.closeButton.onClick = function(widget)
  JumpListWindow:hide()
end
JumpListWindow.Jumpkey.onTextChange = function(widget, text)
  storage[panelName].Jumpkey = text
end
JumpListWindow.Jumpkeys.onTextChange = function(widget, text)
  storage[panelName].Jumpkeys = text
end
JumpListWindow.Jumpkeyone.onTextChange = function(widget, text)
  storage[panelName].Jumpkeyone = text
end
JumpListWindow.Jumpkeytwo.onTextChange = function(widget, text)
  storage[panelName].Jumpkeytwo = text
end
JumpListWindow.Jumpkey:setText(config.Jumpkey) 
JumpListWindow.Jumpkeys:setText(config.Jumpkeys)
JumpListWindow.Jumpkeyone:setText(config.Jumpkeyone)
JumpListWindow.Jumpkeytwo:setText(config.Jumpkeytwo)
end
macro(100, function() 
if (not storage.titlejumpEnabled) then
  return
end
if modules.corelib.g_keyboard.areKeysPressed(config.Jumpkey) then
  g_game.turn(0) -- norte
  say('jump "up"')
  say('jump "down"')
elseif modules.corelib.g_keyboard.areKeysPressed(config.Jumpkeys) then
  g_game.turn(2) -- oeste
  say('jump "up"')
  say('jump "down"')
elseif modules.corelib.g_keyboard.areKeysPressed(config.Jumpkeyone) then
  g_game.turn(3) -- sul
  say('jump "up"')
  say('jump "down"')
elseif modules.corelib.g_keyboard.areKeysPressed(config.Jumpkeytwo) then
  g_game.turn(1) -- leste
  say('jump "up"')
  say('jump "down"')
end
end)


---river
local panelName = "riveradv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titleriver
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('River')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]], parent)
  ui:setId(panelName)
local RiverListWindow = setupUI([[
MainWindow
  !text: tr('River Options')
  size: 150 230
  @onEscape: self:hide()

  Label
    id: Fistkey
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: North

  BotTextEdit
    id: Riverkey
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Fistkey.bottom
    margin-top: 3

  Label
    id: Secondkey
    anchors.top: Riverkey.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: South

  BotTextEdit
    id: Riverkeys
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Secondkey.bottom
    margin-top: 3

  Label
    id: Tirdkey
    anchors.top: Riverkeys.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: West

  BotTextEdit
    id: Riverkeyone
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Tirdkey.bottom
    margin-top: 3

  Label
    id: Fourthkey
    anchors.top: Riverkeyone.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: East

  BotTextEdit
    id: Riverkeytwo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: Fourthkey.bottom
    margin-top: 3

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
    Riverkey= 'Up',
    Riverkeys= 'Down',
    Riverkeyone='Left',
    Riverkeytwo='Right',
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
RiverListWindow:hide()

ui.titleriver:setOn(storage.titleriverEnabled);
ui.titleriver.onClick = function(widget)
    storage.titleriverEnabled = not storage.titleriverEnabled;
    widget:setOn(storage.titleriverEnabled);
end

ui.editList.onClick = function(widget)
  RiverListWindow:show()
  RiverListWindow:raise()
  RiverListWindow:focus()
end
RiverListWindow.closeButton.onClick = function(widget)
  RiverListWindow:hide()
end
RiverListWindow.Riverkey.onTextChange = function(widget, text)
  storage[panelName].Riverkey = text
end
RiverListWindow.Riverkeys.onTextChange = function(widget, text)
  storage[panelName].Riverkeys = text
end
RiverListWindow.Riverkeyone.onTextChange = function(widget, text)
  storage[panelName].Riverkeyone = text
end
RiverListWindow.Riverkeytwo.onTextChange = function(widget, text)
  storage[panelName].Riverkeytwo = text
end
RiverListWindow.Riverkey:setText(config.Riverkey) 
RiverListWindow.Riverkeys:setText(config.Riverkeys)
RiverListWindow.Riverkeyone:setText(config.Riverkeyone)
RiverListWindow.Riverkeytwo:setText(config.Riverkeytwo)
end
local keyriver = modules.corelib.g_keyboard;
macro(100, function() 
  if (not storage.titleriverEnabled) then
    return
end
if keyriver.areKeysPressed(config.Riverkey) then
  g_game.turn(0) -- norte
  say('suimen hoko no gyo')
elseif keyriver.areKeysPressed(config.Riverkeys) then
  g_game.turn(2) -- oeste
  say('suimen hoko no gyo')
elseif keyriver.areKeysPressed(config.Riverkeyone) then
  g_game.turn(3) -- sul
  say('suimen hoko no gyo')
elseif keyriver.areKeysPressed(config.Riverkeytwo) then
  g_game.turn(1) -- leste
  say('suimen hoko no gyo')
end
end)

UI.Separator()
UI.Label("Offensive")
UI.Separator()
--------combo
local panelName = "Comboadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titlecomboI
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Combo I')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]], parent)
  ui:setId(panelName)
local ComboListWindow = setupUI([[
MainWindow
  !text: tr('Combo I Options')
  size: 200 230
  @onEscape: self:hide()

  Label
    id: FistSpell
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Fist Spell

  BotTextEdit
    id: Combokeyone
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: FistSpell.bottom
    margin-bot: 5

  Label
    id: SecondSpell
    anchors.top: Combokeyone.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Second Spell

  BotTextEdit
    id: Combokeytwo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SecondSpell.bottom

  Label
    id: TirdSpell
    anchors.top: Combokeytwo.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Tird Spell

  BotTextEdit
    id: Combokeythree
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: TirdSpell.bottom
    margin-top: 5

  Label
    id: FourthSpell
    anchors.top: Combokeythree.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Fourth Spell

  BotTextEdit
    id: Combokeyfour
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: FourthSpell.bottom
    margin-top: 3

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
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
ComboListWindow:hide()

ui.titlecomboI:setOn(storage.titlecomboIEnabled);
ui.titlecomboI.onClick = function(widget)
    storage.titlecomboIEnabled = not storage.titlecomboIEnabled;
    widget:setOn(storage.titlecomboIEnabled);
end

ui.editList.onClick = function(widget)
  ComboListWindow:show()
  ComboListWindow:raise()
  ComboListWindow:focus()
end
ComboListWindow.closeButton.onClick = function(widget)
  ComboListWindow:hide()
end
ComboListWindow.Combokeyone.onTextChange = function(widget, text)
  storage[panelName].Combokeyone = text
end
ComboListWindow.Combokeytwo.onTextChange = function(widget, text)
  storage[panelName].Combokeytwo = text
end
ComboListWindow.Combokeythree.onTextChange = function(widget, text)
  storage[panelName].Combokeythree = text
end
ComboListWindow.Combokeyfour.onTextChange = function(widget, text)
  storage[panelName].Combokeyfour = text
end
ComboListWindow.Combokeyone:setText(config.Combokeyone) 
ComboListWindow.Combokeytwo:setText(config.Combokeytwo)
ComboListWindow.Combokeythree:setText(config.Combokeythree)
ComboListWindow.Combokeyfour:setText(config.Combokeyfour)
end

local keyboard = modules.corelib.g_keyboard;
macro(200, function()
if (not storage.titlecomboIEnabled) then
  return
end
if (
  g_game.isAttacking() and
  not keyboard.isKeyPressed('F1') and
  not keyboard.isKeyPressed('F2') and
  not keyboard.isKeyPressed('F3') and
  not keyboard.isKeyPressed('F4') and 
  not keyboard.isKeyPressed('F5') and
  not keyboard.isKeyPressed('F6') and
  not keyboard.isKeyPressed('F7') and
  not keyboard.isKeyPressed('F8')
) then
say(storage[panelName].Combokeyone)
say(storage[panelName].Combokeytwo)
say(storage[panelName].Combokeythree)
say(storage[panelName].Combokeyfour)
end
end)

-------combo 2
local panelName = "Ctwotwoadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titletwo
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Combo II')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]], parent)
  ui:setId(panelName)
local CtwotwoListWindow = setupUI([[
MainWindow
  !text: tr('Combo II Options')
  size: 200 230
  @onEscape: self:hide()

  Label
    id: FistSpell
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Fist Spell

  BotTextEdit
    id: Ctwotwokeyone
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: FistSpell.bottom
    margin-bot: 5

  Label
    id: SecondSpell
    anchors.top: Ctwotwokeyone.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Second Spell

  BotTextEdit
    id: Ctwotwokeytwo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: SecondSpell.bottom

  Label
    id: TirdSpell
    anchors.top: Ctwotwokeytwo.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Tird Spell

  BotTextEdit
    id: Ctwotwokeythree
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: TirdSpell.bottom
    margin-top: 5

  Label
    id: FourthSpell
    anchors.top: Ctwotwokeythree.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Fourth Spell

  BotTextEdit
    id: Ctwotwokeyfour
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: FourthSpell.bottom
    margin-top: 3

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
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
CtwotwoListWindow:hide()

ui.titletwo:setOn(storage.titletwoEnabled);
ui.titletwo.onClick = function(widget)
    storage.titletwoEnabled = not storage.titletwoEnabled;
    widget:setOn(storage.titletwoEnabled);
end

ui.editList.onClick = function(widget)
  CtwotwoListWindow:show()
  CtwotwoListWindow:raise()
  CtwotwoListWindow:focus()
end
CtwotwoListWindow.closeButton.onClick = function(widget)
  CtwotwoListWindow:hide()
end
CtwotwoListWindow.Ctwotwokeyone.onTextChange = function(widget, text)
  storage[panelName].Ctwotwokeyone = text
end
CtwotwoListWindow.Ctwotwokeytwo.onTextChange = function(widget, text)
  storage[panelName].Ctwotwokeytwo = text
end
CtwotwoListWindow.Ctwotwokeythree.onTextChange = function(widget, text)
  storage[panelName].Ctwotwokeythree = text
end
CtwotwoListWindow.Ctwotwokeyfour.onTextChange = function(widget, text)
  storage[panelName].Ctwotwokeyfour = text
end
CtwotwoListWindow.Ctwotwokeyone:setText(config.Ctwotwokeyone) 
CtwotwoListWindow.Ctwotwokeytwo:setText(config.Ctwotwokeytwo)
CtwotwoListWindow.Ctwotwokeythree:setText(config.Ctwotwokeythree)
CtwotwoListWindow.Ctwotwokeyfour:setText(config.Ctwotwokeyfour)
end

macro(200, function()
if (not storage.titletwoEnabled) then
  return
end
if (g_game.isAttacking()) then
say(storage[panelName].Ctwotwokeyone)
say(storage[panelName].Ctwotwokeytwo)
say(storage[panelName].Ctwotwokeythree)
say(storage[panelName].Ctwotwokeyfour)
end
end)

-----Attack Target----------
macro(100, "Attack Target", nil, function()
  if g_game.isAttacking() 
then
 oldTarget = g_game.getAttackingCreature()
  end
  if (oldTarget and oldTarget:getPosition()) 
then
 if (not g_game.isAttacking() and getDistanceBetween(pos(), oldTarget:getPosition()) <= 8) then
    
if (oldTarget:getPosition().z == posz()) then
        g_game.attack(oldTarget)
      end
    end
  end
end)

onKeyDown(function(keys)
 
if keys == "Escape" then
    oldTarget = nil
g_game.cancelAttack()
  end
end)
----------
local panelName = "Senseadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titlesense
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Sense')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
      
  ]], parent)
  ui:setId(panelName)
local SenseListWindow = setupUI([[
MainWindow
  !text: tr('Sense  Options')
  size: 150 150
  @onEscape: self:hide()

  Label
    id: KeySense
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Key Sense

  BotTextEdit
    id: Sensekey
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: KeySense.bottom
    margin-bot: 5

  Label
    id: TextSense
    anchors.top: Sensekey.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Sense Spell

  BotTextEdit
    id: SenseText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: TextSense.bottom

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
    SenseText= 'sense',
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
SenseListWindow:hide()

ui.titlesense:setOn(storage.titlesenseEnabled);
ui.titlesense.onClick = function(widget)
    storage.titlesenseEnabled = not storage.titlesenseEnabled;
    widget:setOn(storage.titlesenseEnabled);
end

ui.editList.onClick = function(widget)
  SenseListWindow:show()
  SenseListWindow:raise()
  SenseListWindow:focus()
end
SenseListWindow.closeButton.onClick = function(widget)
  SenseListWindow:hide()
end
SenseListWindow.SenseText.onTextChange = function(widget, text)
  storage[panelName].SenseText = text
end
SenseListWindow.Sensekey.onTextChange = function(widget, text)
  storage[panelName].Sensekey = text
end

SenseListWindow.Sensekey:setText(config.Sensekey) 
SenseListWindow.SenseText:setText(config.SenseText) 
end

macro(100, function()
if (not storage.titlesenseEnabled) then
  return
end
if g_game.isAttacking() and g_game.getAttackingCreature():isPlayer() then 
sense = g_game.getAttackingCreature():getName() end end) 
onKeyPress(function(keys) 
if keys == config.Sensekey then 
  if sense then say(config.SenseText ..' "'.. sense) 
  end 
end 
end)


UI.Separator()
UI.Label("Hunt")
UI.Separator()

local panelName = "AntiRedadv"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: titleAntiRed
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Anti-Red')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit
  ]], parent)
  ui:setId(panelName)
local AntiListWindow = setupUI([[
MainWindow
  !text: tr('Anti-Red Options')
  color: #03C04A
  size: 350 200

  @onEscape: self:hide()

  Label
    id: ComboSpell
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Combo

  BotTextEdit
    id: AntiComboText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: ComboSpell.bottom
    margin-bot: 5

  Label
    id: AreaSpell
    anchors.top: AntiComboText.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    text: Area

  BotTextEdit
    id: AntiAreaText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: AreaSpell.bottom
    margin-bot: 5

  Label
    id:textoinfo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: AntiAreaText.bottom
    margin-top: 10
    text-align: center
    color: #aeaeae
    text: Info

  Label
    id:texto
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: textoinfo.bottom
    margin-top: 10
    color: #aeaeae
    text: Combo must be in sequence and separated by " , "


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
  }
end

local config = storage[panelName]
rootWidget = g_ui.getRootWidget()
if rootWidget then
AntiListWindow:hide()

ui.titleAntiRed:setOn(storage.titleAntiRedEnabled);
ui.titleAntiRed.onClick = function(widget)
    storage.titleAntiRedEnabled = not storage.titleAntiRedEnabled;
    widget:setOn(storage.titleAntiRedEnabled);
end

ui.editList.onClick = function(widget)
  AntiListWindow:show()
  AntiListWindow:raise()
  AntiListWindow:focus()
end
AntiListWindow.closeButton.onClick = function(widget)
  AntiListWindow:hide()
end
AntiListWindow.AntiComboText.onTextChange = function(widget, text)
  storage[panelName].AntiComboText = text
end
AntiListWindow.AntiAreaText.onTextChange = function(widget, text)
  storage[panelName].AntiAreaText = text
end

AntiListWindow.AntiComboText:setText(config.AntiComboText) 
AntiListWindow.AntiAreaText:setText(config.AntiAreaText)
end
AntiRed = {
areaSpell = config.AntiAreaText,
comboSpells = config.AntiComboText, -- Combo separado por VIRGULA
delayTime = 60 * 1000,
time = 0,
};

AntiRed.macro = macro(100, function()
if (not storage.titleAntiRedEnabled) then
  return
end
local spectators = getSpectators(true);
local monstersNextTo = getMonstersInRange(pos(), 2);
for _, creature in pairs(spectators) do
    if (creature:getName() ~= player:getName() and creature:isPlayer() and creature:getEmblem() ~= 1) then
        AntiRed.time = now + AntiRed.delayTime;
        break;
    end
end
if (monstersNextTo > 0 and AntiRed.time < now and player:getSkull() < 3) then
    say(AntiRed.areaSpell);
elseif (g_game.isAttacking() and (AntiRed.time >= now or player:getSkull() >= 3)) then
    local arraySpells = AntiRed.comboSpells:explode(",");
    for _, spell in ipairs(arraySpells) do
      say(spell);
    end
end
end);

---Lure---

local MIN_RANGE = 12;
macro(100, 'Lure', function()
    if (CaveBot.isOff()) then return; end
    local creaturesAround = getMonstersInRange(pos(), MIN_RANGE);
    if (TargetBot.isOff() and creaturesAround >= storage.LureMin) then
        TargetBot.setOn();
    elseif (TargetBot.isOn() and creaturesAround <= storage.LureOff) then
        TargetBot.setOff();
    end
end);

addTextEdit("LureMinText", storage.LureMin or "Min To Stop", function(widget, text)
    storage.LureMin = tonumber(text)
end)
addTextEdit("LureOffText", storage.LureOff or "Run Again", function(widget, text)
    storage.LureOff = tonumber(text)
end)
