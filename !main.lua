setDefaultTab ("Main");
UI.Label("NBO Brasil")
UI.Button("Official Discord", function() g_platform.openUrl("https://discord.gg/C3U7CD58vk") end)

UI.Button("Official Site", function() g_platform.openUrl("https://www.nbosimulator.com") end)
UI.Separator()
local panelName = "playerList"
  local ui = setupUI([[
Panel
  height: 18

  Button
    id: editList
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    background: #292A2A
    height: 18
    text: Player Lists
  ]], parent)
  ui:setId(panelName)
ui:setId(panelName)
local playerListWindow = setupUI([[
PlayerName < Label
  background-color: alpha
  text-offset: 2 0
  focusable: true
  height: 16

  $focus:
    background-color: #00000055

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15

MainWindow
  !text: tr('Player Lists')
  size: 580 350
  @onEscape: self:hide()

  Label
    anchors.left: FriendList.left
    anchors.top: parent.top
    anchors.right: FriendList.right
    text-align: center
    text: Friends List
    margin-right: 3 

  TextList
    id: FriendList
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 15
    margin-bottom: 5
    margin-right: 3
    padding: 1
    width: 180
    height: 160
    vertical-scrollbar: FriendListScrollBar

  VerticalScrollBar
    id: FriendListScrollBar
    anchors.top: FriendList.top
    anchors.bottom: FriendList.bottom
    anchors.right: FriendList.right
    step: 14
    pixels-scroll: true

  TextEdit
    id: FriendName
    anchors.right: FriendList.right
    anchors.left: FriendList.left
    anchors.top: FriendList.bottom
    margin-right: 3    
    margin-top: 5

  Button
    id: AddFriend
    !text: tr('Add Friend')
    anchors.right: FriendList.right
    anchors.left: FriendList.left
    anchors.top: prev.bottom
    margin-right: 3    
    margin-top: 3

  Label
    anchors.right: EnemyList.right
    anchors.top: parent.top
    anchors.left: EnemyList.left
    text-align: center
    text: Enemy List
    margin-left: 3     

  TextList
    id: EnemyList
    anchors.top: parent.top
    anchors.left: FriendList.right
    margin-top: 15
    margin-bottom: 5
    margin-left: 3
    padding: 1
    width: 180
    height: 160
    vertical-scrollbar: EnemyListScrollBar

  VerticalScrollBar
    id: EnemyListScrollBar
    anchors.top: EnemyList.top
    anchors.bottom: EnemyList.bottom
    anchors.right: EnemyList.right
    step: 14
    pixels-scroll: true

  TextEdit
    id: EnemyName
    anchors.left: EnemyList.left
    anchors.right: EnemyList.right
    anchors.top: EnemyList.bottom
    margin-left: 3    
    margin-top: 5

  Button
    id: AddEnemy
    !text: tr('Add Enemy')
    anchors.left: EnemyList.left
    anchors.right: EnemyList.right
    anchors.top: prev.bottom
    margin-left: 3    
    margin-top: 3

  Label
    anchors.right: BlackList.right
    anchors.top: parent.top
    anchors.left: BlackList.left
    text-align: center
    text: Anty RS List
    margin-left: 3   

  TextList
    id: BlackList
    anchors.top: parent.top
    anchors.left: EnemyList.right
    margin-top: 15
    margin-bottom: 5
    margin-left: 3
    padding: 1
    width: 180
    height: 160
    vertical-scrollbar: BlackListScrollBar

  VerticalScrollBar
    id: BlackListScrollBar
    anchors.top: BlackList.top
    anchors.bottom: BlackList.bottom
    anchors.right: BlackList.right
    step: 14
    pixels-scroll: true

  TextEdit
    id: BlackName
    anchors.left: BlackList.left
    anchors.right: BlackList.right
    anchors.top: BlackList.bottom
    margin-left: 3    
    margin-top: 5

  Button
    id: AddBlack
    !text: tr('Add Anty-RS')
    anchors.left: BlackList.left
    anchors.right: BlackList.right
    anchors.top: prev.bottom
    margin-left: 3    
    margin-top: 3

  BotSwitch
    id: Members
    anchors.left: parent.left
    anchors.top: AddEnemy.bottom
    margin-top: 15
    width: 135
    text-align: center
    text: Group Members  

  BotSwitch
    id: Outfit
    anchors.bottom: prev.bottom
    anchors.left: prev.right
    margin-left: 3
    width: 135
    text-align: center
    text: Color Outfits

  BotSwitch
    id: Marks
    anchors.bottom: prev.bottom
    anchors.left: prev.right
    width: 135
    margin-left: 3
    text-align: center
    text: Not Ally = Enemy    

  BotSwitch
    id: Highlight    
    anchors.bottom: prev.bottom
    anchors.left: prev.right
    width: 135
    margin-left: 3
    text-align: center
    text: Highlight     

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
    enemyList = {},
    friendList = {},
    blackList = {},
    groupMembers = true,
    outfits = false,
    marks = false,
    highlight = false
  }
end

local config = storage[panelName]
-- for backward compability
if not config.blackList then
  config.blackList = {}
end


-- functions
local function clearCachedPlayers()
  CachedFriends = {}
  CachedEnemies = {}
end

local refreshStatus = function()
  for _, spec in ipairs(getSpectators()) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if config.outfits then
        local specOutfit = spec:getOutfit()
        if isFriend(spec:getName()) then
          if config.highlight then
            spec:setMarked('#0000FF')
          end
          specOutfit.head = 88
          specOutfit.body = 88
          specOutfit.legs = 88
          specOutfit.feet = 88
          if storage.BOTserver.outfit then
            local voc = vBot.BotServerMembers[spec:getName()]
            specOutfit.addons = 3 
            if voc == 1 then
              specOutfit.type = 131
            elseif voc == 2 then
              specOutfit.type = 129
            elseif voc == 3 then
              specOutfit.type = 130
            elseif voc == 4 then
              specOutfit.type = 144
            end
          end
          spec:setOutfit(specOutfit)
        elseif isEnemy(spec:getName()) then
          if config.highlight then
            spec:setMarked('#FF0000')
          end
          specOutfit.head = 94
          specOutfit.body = 94
          specOutfit.legs = 94
          specOutfit.feet = 94
          spec:setOutfit(specOutfit)
        end
      end
    end
  end
end
refreshStatus()

local checkStatus = function(creature)
  if not creature:isPlayer() or creature:isLocalPlayer() then return end

  local specName = creature:getName()
  local specOutfit = creature:getOutfit()

  if isFriend(specName) then
    if config.highlight then
      creature:setMarked('#0000FF')
    end
    if config.outfits then
      specOutfit.head = 88
      specOutfit.body = 88
      specOutfit.legs = 88
      specOutfit.feet = 88
      if storage.BOTserver.outfit then
        local voc = vBot.BotServerMembers[creature:getName()]
        specOutfit.addons = 3 
        if voc == 1 then
          specOutfit.type = 131
        elseif voc == 2 then
          specOutfit.type = 129
        elseif voc == 3 then
          specOutfit.type = 130
        elseif voc == 4 then
          specOutfit.type = 144
        end
      end
      creature:setOutfit(specOutfit)
    end
  elseif isEnemy(specName) then
    if config.highlight then
      creature:setMarked('#FF0000')
    end
    if config.outfits then
      specOutfit.head = 94
      specOutfit.body = 94
      specOutfit.legs = 94
      specOutfit.feet = 94
      creature:setOutfit(specOutfit)
    end
  end
end

-- eof

-- UI
rootWidget = g_ui.getRootWidget()
playerListWindow:hide()

playerListWindow.Members:setOn(config.groupMembers)
playerListWindow.Members.onClick = function(widget)
  config.groupMembers = not config.groupMembers
  if not config then
    clearCachedPlayers()
  end
  refreshStatus()
  widget:setOn(config.groupMembers)
end
playerListWindow.Outfit:setOn(config.outfits)
playerListWindow.Outfit.onClick = function(widget)
  config.outfits = not config.outfits
  widget:setOn(config.outfits)
end
playerListWindow.Marks:setOn(config.marks)
playerListWindow.Marks.onClick = function(widget)
  config.marks = not config.marks
  widget:setOn(config.marks)
end
playerListWindow.Highlight:setOn(config.highlight)
playerListWindow.Highlight.onClick = function(widget)
  config.highlight = not config.highlight
  widget:setOn(config.highlight)
end

if config.enemyList and #config.enemyList > 0 then
  for _, name in ipairs(config.enemyList) do
    local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
    label.remove.onClick = function(widget)
      table.removevalue(config.enemyList, label:getText())
      label:destroy()
    end
    label:setText(name)
  end
end

if config.blackList and #config.blackList > 0 then
  for _, name in ipairs(config.blackList) do
    local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
    label.remove.onClick = function(widget)
      table.removevalue(config.blackList, label:getText())
      label:destroy()
    end
    label:setText(name)
  end
end

if config.friendList and #config.friendList > 0 then
  for _, name in ipairs(config.friendList) do
    local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
    label.remove.onClick = function(widget)
      table.removevalue(config.friendList, label:getText())
      label:destroy()
    end
    label:setText(name)
  end
end

playerListWindow.AddFriend.onClick = function(widget)
  local friendName = playerListWindow.FriendName:getText()
  if friendName:len() > 0 and not table.contains(config.friendList, friendName, true) then
    table.insert(config.friendList, friendName)
    local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
    label.remove.onClick = function(widget)
      table.removevalue(config.friendList, label:getText())
      label:destroy()
    end
    label:setText(friendName)
    playerListWindow.FriendName:setText('')
    clearCachedPlayers()
    refreshStatus()
  end
end

playerListWindow.AddEnemy.onClick = function(widget)
  local enemyName = playerListWindow.EnemyName:getText()
  if enemyName:len() > 0 and not table.contains(config.enemyList, enemyName, true) then
    table.insert(config.enemyList, enemyName)
    local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
    label.remove.onClick = function(widget)
      table.removevalue(config.enemyList, label:getText())
      label:destroy()
    end
    label:setText(enemyName)
    playerListWindow.EnemyName:setText('')
    clearCachedPlayers()
    refreshStatus()
  end
end 

playerListWindow.AddBlack.onClick = function(widget)
  local blackName = playerListWindow.BlackName:getText()
  if blackName:len() > 0 and not table.contains(config.blackList, blackName, true) then
    table.insert(config.blackList, blackName)
    local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
    label.remove.onClick = function(widget)
      table.removevalue(config.blackList, label:getText())
      label:destroy()
    end
    label:setText(blackName)
    playerListWindow.BlackName:setText('')
    clearCachedPlayers()
    refreshStatus()
  end
end 

ui.editList.onClick = function(widget)
  playerListWindow:show()
  playerListWindow:raise()
  playerListWindow:focus()
end
playerListWindow.closeButton.onClick = function(widget)
  playerListWindow:hide()
end


-- execution

onCreatureAppear(function(creature)
checkStatus(creature)
end)

onPlayerPositionChange(function(x,y)
if x.z ~= y.z then
  schedule(20, function()
    refreshStatus()
  end)
end
end)
UI.Separator()
local panelName = "alarms"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Alarms')

  Button
    id: alerts
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit

]])
ui:setId(panelName)
local AlarmsWindow = setupUI([[
AlarmCheckBox < Panel
  height: 20
  margin-top: 2

  CheckBox
    id: tick
    anchors.fill: parent
    margin-top: 4
    font: verdana-11px-rounded
    text: Player Attack
    text-offset: 17 -3

AlarmCheckBoxAndSpinBox < Panel
  height: 20
  margin-top: 2

  CheckBox
    id: tick
    anchors.fill: parent
    anchors.right: next.left
    margin-top: 4
    font: verdana-11px-rounded
    text: Player Attack
    text-offset: 17 -3

  SpinBox
    id: value
    anchors.top: parent.top
    margin-top: 1
    margin-bottom: 1
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 40
    minimum: 0
    maximum: 100
    step: 1
    editable: true
    focusable: true

AlarmCheckBoxAndTextEdit < Panel
  height: 20
  margin-top: 2

  CheckBox
    id: tick
    anchors.fill: parent
    anchors.right: next.left
    margin-top: 4
    font: verdana-11px-rounded
    text: Creature Name
    text-offset: 17 -3

  BotTextEdit
    id: text
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: 150
    font: terminus-10px
    margin-top: 1
    margin-bottom: 1

MainWindow
  !text: tr('Alarms')
  size: 330 400
  padding: 15
  @onEscape: self:hide()

  FlatPanel
    id: list
    anchors.fill: parent
    anchors.bottom: settingsList.top
    margin-bottom: 20
    margin-top: 10
    layout: verticalBox
    padding: 10
    padding-top: 5

  FlatPanel
    id: settingsList
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin-bottom: 5
    margin-top: 10
    padding: 5
    padding-left: 10
    layout: 
      type: verticalBox
      fit-children: true

  Label
    anchors.verticalCenter: settingsList.top
    anchors.left: settingsList.left
    margin-left: 5
    width: 200
    text: Alarms Settings
    font: verdana-11px-rounded
    color: #9f5031

  Label
    anchors.verticalCenter: list.top
    anchors.left: list.left
    margin-left: 5
    width: 200
    text: Active Alarms
    font: verdana-11px-rounded
    color: #9f5031

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  ResizeBorder
    id: bottomResizeBorder
    anchors.fill: separator
    height: 3
    minimum: 260
    maximum: 600
    margin-left: 3
    margin-right: 3
    background: #ffffff88  

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5
    @onClick: self:getParent():hide() 
]], g_ui.getRootWidget())

if not storage[panelName] then
    storage[panelName] = {}
  end
  
  local config = storage[panelName]
  
  ui.title:setOn(config.enabled)
  ui.title.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setOn(config.enabled)
  end
  AlarmsWindow:hide()
  
  ui.alerts.onClick = function()
    AlarmsWindow:show()
    AlarmsWindow:raise()
    AlarmsWindow:focus()
  end
  
  local widgets = 
  {
    "AlarmCheckBox", 
    "AlarmCheckBoxAndSpinBox", 
    "AlarmCheckBoxAndTextEdit"
  }
  
  local parents = 
  {
    AlarmsWindow.list, 
    AlarmsWindow.settingsList
  }
  
  
  -- type
  addAlarm = function(id, title, defaultValue, alarmType, parent, tooltip)
    local widget = UI.createWidget(widgets[alarmType], parents[parent])
    widget:setId(id)
  
    if type(config[id]) ~= 'table' then
      config[id] = {}
    end
  
    widget.tick:setText(title)
    widget.tick:setChecked(config[id].enabled)
    widget.tick:setTooltip(tooltip)
    widget.tick.onClick = function()
      config[id].enabled = not config[id].enabled
      widget.tick:setChecked(config[id].enabled)
    end
  
    if alarmType > 1 and type(config[id].value) == 'nil' then
      config[id].value = defaultValue
    end
  
    if alarmType == 2 then
      widget.value:setValue(config[id].value)
      widget.value.onValueChange = function(widget, value)
        config[id].value = value
      end
    elseif alarmType == 3 then
      widget.text:setText(config[id].value)
      widget.text.onTextChange = function(widget, newText)
        config[id].value = newText
      end
    end
  
  end
  
  -- settings
  addAlarm("ignoreFriends", "Ignore Friends", true, 1, 2)
  addAlarm("flashClient", "Flash Client", true, 1, 2)
  
  -- alarm list
  addAlarm("damageTaken", "Damage Taken", false, 1, 1)
  addAlarm("lowHealth", "Low Health", 20, 2, 1)
  addAlarm("lowMana", "Low Mana", 20, 2, 1)
  addAlarm("playerAttack", "Player Attack", false, 1, 1)
  
  UI.Separator(AlarmsWindow.list)
  
  addAlarm("privateMsg", "Private Message", false, 1, 1)
  addAlarm("defaultMsg", "Default Message", false, 1, 1)
  addAlarm("customMessage", "Custom Message:", "", 3, 1, "You can add text, that if found in any incoming message will trigger alert.\n You can add many, just separate them by comma.")
  
  UI.Separator(AlarmsWindow.list)
  
  addAlarm("creatureDetected", "Creature Detected", false, 1, 1)
  addAlarm("playerDetected", "Player Detected", false, 1, 1)
  addAlarm("creatureName", "Creature Name:", "", 3, 1, "You can add a name or part of it, that if found in any visible creature name will trigger alert.\nYou can add many, just separate them by comma.")
  
  
  local lastCall = now
  local function alarm(file, windowText)
    if now - lastCall < 2000 then return end -- 2s delay
    lastCall = now
  
    if not g_resources.fileExists(file) then
      file = "/sounds/alarm.ogg"
      lastCall = now + 4000 -- alarm.ogg length is 6s
    end
  
    
    if modules.game_bot.g_app.getOs() == "windows" and config.flashClient.enabled then
      g_window.flash()
    end
    g_window.setTitle(player:getName() .. " - " .. windowText)
    playSound(file)
  end
  
  -- damage taken & custom message
  onTextMessage(function(mode, text)
    if not config.enabled then return end
    if mode == 22 and config.damageTaken.enabled then
      return alarm('/sounds/magnum.ogg', "Damage Received!")
    end
  
    if config.customMessage.enabled then
      local alertText = config.customMessage.value
      if alertText:len() > 0 then
        text = text:lower()
        local parts = string.split(alertText, ",")
  
        for i=1,#parts do
          local part = parts[i]
          part = part:trim()
          part = part:lower()
  
          if text:find(part) then
            return alarm('/sounds/magnum.ogg', "Special Message!")
          end
        end
      end
    end
  end)
  
  -- default & private message
  onTalk(function(name, level, mode, text, channelId, pos)
    if not config.enabled then return end
    if name == player:getName() then return end -- ignore self messages
    if config.ignoreFriends.enabled and isFriend(name) then return end -- ignore friends if enabled
  
    if mode == 1 and config.defaultMsg.enabled then
      return alarm("/sounds/magnum.ogg", "Default Message!")
    end
  
    if mode == 4 and config.privateMsg.enabled then
      return alarm("/sounds/Private_Message.ogg", "Private Message!")
    end
  end)
  
  -- health & mana
  macro(100, function() 
    if not config.enabled then return end
    if config.lowHealth.enabled then
      if hppercent() < config.lowHealth.value then
        return alarm("/sounds/Low_Health.ogg", "Low Health!")
      end
    end
  
    if config.lowMana.enabled then
      if hppercent() < config.lowMana.value then
        return alarm("/sounds/Low_Mana.ogg", "Low Mana!")
      end
    end
  
    for i, spec in ipairs(getSpectators()) do
      if not spec:isLocalPlayer() and not (config.ignoreFriends.enabled and isFriend(spec)) then
  
        if config.creatureDetected.enabled then
          return alarm("/sounds/magnum.ogg", "Creature Detected!")
        end
  
        if spec:isPlayer() then 
          if config.playerAttack.enabled then
            return alarm("/sounds/Player_Attack.ogg", "Player Attack!")
          end
          if config.playerDetected.enabled then
            return alarm("/sounds/Player_Detected.ogg", "Player Detected!")
          end
        end
  
        if config.creatureName.enabled then
          local name = spec:getName():lower()
          local fragments = string.split(config.creatureName.value, ",")
          
          for i=1,#fragments do
            local frag = fragments[i]:trim():lower()
  
            if name:lower():find(frag) then
              return alarm("/sounds/alarm.ogg", "Special Creature Detected!")
            end
          end
        end
      end
    end
  end)

UI.Separator()
UI.Button("Add Macro", function(newText)
    UI.MultilineEditorWindow(storage.ingame_MainMacro or "", {title="Macro Main editor", description="You can add your custom scrupts here"}, function(text)
      storage.ingame_MainMacro = text
      reload()
    end)
  end)
  UI.Separator()
  UI.Label('Add Macro')
  for _, scripts in pairs({storage.ingame_MainMacro}) do
    if type(scripts) == "string" and scripts:len() > 3 then
      local status, result = pcall(function()
        assert(load(scripts, "ingame_maineditor"))()
      end)
      if not status then 
        error("Ingame edior error:\n" .. result)
      end
    end
  end
  UI.Separator()

UI.Separator()
UI.Label("Custom by: Valdez")
UI.Separator()
