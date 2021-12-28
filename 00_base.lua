--print("Loading event.")
local event=require("Event")
print("Welcome to ReceatOS.")
print("System info:")
print("  Kernel version: ".._KERNELVERSION)
print("  Boot drive space usage: "..fs.spaceUsed().."/"..fs.spaceTotal().." bytes available")
print("  Memory: "..computer.freeMemory().."/"..computer.totalMemory().." bytes available")

function add_component(_,componentAddress,componentName)
	component[componentName]=component.proxy(componentAddress)
	--print("新增了一个设备:"..componentName)
end

function remove_component(_,componentAddress,componentName)
	component[componentName]=nil
    components=component.list(componentName)()
    if components then
        component[component]=component.proxy(components)
    end
	--print("减少了一个设备:"..componentName)
end

for a,b in component.list() do
	add_component(nil,a,b)
end

event.listen("component_added",add_component)
event.listen("component_removed",remove_component)

local TODO=[[local function ababab()
  while 1
  events={event.pull()}
  for i=1,#eventlist do
    if string.match(events[1],eventlist[i][2])~=nil then
      eventlist[i][1](table.unpack(events))
    end
  end
end
end]]


--coroutine.resume(coroutine.create(ababab))
--print("Loading keyboard.")
local keyboard = require("keyboard")

local function onKeyChange(ev, _, char, code)
  -- nil might be slightly more mem friendly during runtime
  -- and `or nil` appears to only cost 30 bytes
  keyboard.pressedChars[char] = ev == "key_down" or nil
  keyboard.pressedCodes[code] = ev == "key_down" or nil
end

event.listen("key_down", onKeyChange)
event.listen("key_up", onKeyChange)


ababab=nil

if component.keyboard==nil then
  print("No keyboard Detected.")
  print("Press any key to continue.")
  while 1 do
    events={event.pull()}
    if events[1]=="key_down" then
      break
    end
  end
end

if component.screen==nil then
  print("No screen Detected.")
  print("Touch screen to continue.")
  while true do 
    events={event.pull()}
    if events[1]=="touch" or events[1]=="drag" or events[1]=="drop" then 
      break
    end
  end
end