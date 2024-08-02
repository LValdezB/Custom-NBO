-- tools tab
setDefaultTab("Tools")
UI.Separator()
UI.Button("Add Script", function(newText)
    UI.MultilineEditorWindow(storage.ingame_hotkeys or "", {title="Hotkeys editor", description="You can add your custom scrupts here"}, function(text)
      storage.ingame_hotkeys = text
      reload()
    end)
  end)
UI.Separator()
UI.Label('Added Script')
  for _, scripts in pairs({storage.ingame_hotkeys}) do
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
local bugMap = {};

bugMap.checkBox = setupUI([[
CheckBox
  id: checkBox
  font: cipsoftFont
  text: Use Diagonal
]]);

bugMap.checkBox.onCheckChange = function(widget, checked)
    storage.bugMapCheck = checked;
end

if storage.bugMapCheck == nil then
    storage.bugMapCheck = true;
end

bugMap.checkBox:setChecked(storage.bugMapCheck);

bugMap.isKeyPressed = modules.corelib.g_keyboard.isKeyPressed;

bugMap.directions = {
    ["W"] = {x = 0, y = -5, direction = 0},
    ["E"] = {x = 3, y = -3},
    ["D"] = {x = 5, y = 0, direction = 1},
    ["C"] = {x = 3, y = 3},
    ["S"] = {x = 0, y = 5, direction = 2},
    ["Z"] = {x = -3, y = 3},
    ["A"] = {x = -5, y = 0, direction = 3},
    ["Q"] = {x = -3, y = -3}
};

bugMap.macro = macro(1, "Bug Map", function()
    if not bugMap.directions then
        print("[BUG MAP] Error: Directions table is nil.")
        return
    end

    if (modules.game_console:isChatEnabled() or modules.corelib.g_keyboard.isCtrlPressed()) then
        return
    end

    local pos = pos()

    for key, config in pairs(bugMap.directions) do
        if (bugMap.isKeyPressed(key)) then
            if (storage.bugMapCheck or config.direction) then
                if (config.direction) then
                    turn(config.direction)
                end
                local tile = g_map.getTile({x = pos.x + config.x, y = pos.y + config.y, z = pos.z})
                if (tile) then
                    return g_game.use(tile:getTopUseThing())
                end
            end
        end
    end
end)

addIcon("Bug Map", { item = 10666, text = "Bug Map" }, bugMap.macro)

------
local windowUI = setupUI([[
Panel
  id: mainWindow
  anchors.top: prev.bottom
  anchors.horizontalCenter: parent.horizontalCenter
  height: 50
  margin-top: 200
  width: 200
  phantom: true

  Label
    id: creatureName
    text: Name: Beez
    color: white
    margin-left: 22
    anchors.left: creature.left
    width: 100
    font: verdana-11px-rounded
    text-horizontal-auto-resize: true
  UICreature
    id: creature
    size: 27 27

  MiniWindowContents
    size: 200 200
    margin: 15 22
    id: secondaryWindow
    HealthBar
      id: healthBar
      background-color: green
      height: 12
      anchors.left: parent.left
      text: 100/100
      text-offset: 0 1
      text-align: center
      font: verdana-11px-rounded
      width: 160
      margin-right: 5

]], modules.game_interface.gameMapPanel);

windowUI:hide();

macro(100, function()
    local target = g_game.getAttackingCreature();

    if target and not target:isNpc() then
        local hp = target:getHealthPercent();
        if(hp >= 76) then
            windowUI.secondaryWindow.healthBar:setBackgroundColor("#14fe17")
        elseif (hp > 50) then
            windowUI.secondaryWindow.healthBar:setBackgroundColor("#ffff29")
        elseif (hp > 25) then
            windowUI.secondaryWindow.healthBar:setBackgroundColor("#ff9b29")
        elseif (hp > 1) then
            windowUI.secondaryWindow.healthBar:setBackgroundColor("#ff2929")
        end
        windowUI.creature:setOutfit(target:getOutfit());
        windowUI.creatureName:setText(target:getName());

        if (windowUI:isHidden()) then
            windowUI:show();
        end
        windowUI.secondaryWindow.healthBar:setValue(hp, 0, 100);
        windowUI.secondaryWindow.healthBar:setText(hp .. "/100");
    elseif (not target and not windowUI:isHidden()) then
        windowUI:hide();
    end
end);
------

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
--------
local windowUI = setupUI([[
MainWindow
  id: main
  !text: tr('Teleport')
  size: 230 310
  scrollable: true
    
  ScrollablePanel
    id: TpList
    anchors.top: parent.top
    anchors.left: parent.left
    size: 190 225
    vertical-scrollbar: mainScroll

    Button
      !text: tr('Konoha')
      anchors.top: parent.top
      anchors.left: parent.left
      width: 165

    Button
      !text: tr('Suna')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('Yu no Kuni')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('An no kuni')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('Yuki no Kuni')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('Kushiro Island')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('Kumogakure')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: tr('Jinchuurikis Island')
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

TpMinoru = {};
TpMinoru.macro = macro(100, "Teleport", function() end);
local MainPanel = windowUI.main;
local TpList = windowUI.TpList;

TpMinoru.close = function()
  windowUI:hide()
  NPC.say('bye');
end

TpMinoru.show = function()
    windowUI:show();
    windowUI:raise();
    windowUI:focus();
end

windowUI.closeButton.onClick = function()
    TpMinoru.close();
end

TpMinoru.tpToCity = function(city)
    NPC.say(city);
    schedule(500, function()
        NPC.say('yes');
    end);
end


for i, child in pairs(TpList:getChildren()) do
    child.onClick = function()
        TpMinoru.tpToCity(child:getText())
    end
end

onTalk(function(name, level, mode, text, channelId, pos)
  if (TpMinoru.macro.isOff()) then return; end
  if (name ~= 'Minoru') then return; end              
  if (mode ~= 51) then return; end
  if (text:find('Welcome on board, Sir ' .. player:getName() .. '. Do you want to {travel}')) then 
      TpMinoru.show();
  else
      TpMinoru.close();
  end
end);

onKeyDown(function(keys)
    if (keys == 'Escape' and windowUI:isVisible())  then
        TpMinoru.close();
    end
end);

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
comboSpells = config.AntiComboText,
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

local MIN_RANGE = 7;
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
