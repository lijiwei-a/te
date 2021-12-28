_G._KERNELNAME="ReceatOS"
_G._KERNELVER="0.0.4-Alpha"
_G._KERNELVERSION=_KERNELNAME.."_".._KERNELVER
gpu=component.proxy(component.list("gpu")())
fs=component.proxy(computer.getBootAddress())
resX,resY=gpu.maxResolution()
gpu.setResolution(resX,resY)
gpu.fill(1,1,resX,resY," ")
cursorPos = {
  x = 1,
  y = 1
}
local loadedLibraries={}
gpu.fill(1,1,resX,resY," ")
kernel={}
os={}
kernel.bootFS=computer.getBootAddress()
function string.split(str, seperators)
  local t = {}
  for subst in string.gmatch(str, "[^"..seperators.."]+") do
    table.insert(t, subst)
  end
  if #t==0 then return {str} end
  return t
end
function fs.readfile(file)
  handle=fs.open(file)
  chunks=""
  repeat
    filec=fs.read(handle,math.huge)
    if filec then chunks=chunks..filec end
    computer.pullSignal(0)
  until not filec
  --print(debug.traceback())
  fs.close(handle)
  return chunks
end
function require(lib)
  if loadedLibraries[lib]==nil then
    --print(lib.."没有加载！")
    loadedLibraries[lib]=load(fs.readfile("/Libraries/"..lib..".lua"),'='.."/Libraries/"..lib..".lua")()
  else
    --print(lib.."已经加载！")
  end
  return loadedLibraries[lib]
end
function os.sleep(timeout)
  checkArg(1, timeout, "number", "nil")
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end
function prints(str)
  strs=""
  for i=1,#str do
    strs=strs..str[i].."    "
  end
  gpu.set(cursorPos.x,cursorPos.y,strs)
  if cursorPos.y>=resY then
      gpu.copy(1,2,resX,resY-1,0,-1)
      gpu.fill(1,resY,resX,resY," ")
  else
    cursorPos.y = cursorPos.y + 1    
  end
  cursorPos.x = 1
end
function print(str)
  local split=string.split(str,"\n")
  for i=1,#split do
    split1=string.split(split[i],"\t")
    for j=1,#split1 do
      if j~=1 then
        cursorPos.x=cursorPos.x+4
      end
      gpu.set(cursorPos.x,cursorPos.y,split1[j])
      if cursorPos.y>=resY then
        gpu.copy(1,2,resX,resY-1,0,-1)
        gpu.fill(1,resY,resX,resY," ")
      else
        cursorPos.y = cursorPos.y + 1    
      end
      cursorPos.x = 1
    end
  end
end
function kernel.panic(reason,traceback,hr)
  if not reason then
    reason="Not specified"
  end
  if not traceback then
    traceback="None"
  end
  if not hr then 
    hr="Panic"
  end
  print("Kernel Panic!!!")
  print("  Reason: "..reason)
  print("  Traceback: "..traceback)
  print("  Kernel version: ".._KERNELVERSION)
  print("  System uptime: "..computer.uptime())
  print("System halted: "..hr)
  while true do
    --print("\tKernel Panic!!!"..tostring(math.random(1,100)))
    computer.pullSignal()
  end
end
function kernel.execInit(init)
  if fs.exists(init) then
    initc=fs.readfile(init)
    v, err = xpcall(load(initc,"="..init),function(reason) gpu.setBackground(0x000000) gpu.setForeground(0xFF0000) traceback=debug.traceback() print("a error created during open "..init..": "..reason) print(traceback) gpu.setForeground(0xFFFFFF) end)
    v=1
    if not v then
      kernel.panic("Cannot load file \""..init.."\"",err)
    end
  else
    kernel.panic("Cannot found file \""..init.."\"","File not found")
  end
end
function list(dir,filename,run)
  if not filename then
    listmode=true
  end
  list=fs.list(dir)
  table.sort(list)
  for i=1,#list do
    if listmode then
      return list
    end
    if list[i]==list[i]:match("%d%d_.[^\\.]+.lua") then
      --print("第"..tostring(i).."个"..list[i])
      run(dir..list[i])
    end
  end
end
function dofile(file)
  xpcall(function() return load(fs.readfile(file),'='..file)() end,function(reason) gpu.setForeground(0xFF0000) traceback=debug.traceback() print("a error created during open "..file..": "..reason) print(traceback) gpu.setForeground(0xFFFFFF) end)
end
function removeAllComponents()
  for a,b in component.list() do
    computer.pushSignal("component_removed",a,b)
    component[b]=nil
  end
end
function kernel.fakehalt(err)
  if not err then
    print("System halted.")
  else
    print("System halted: "..err)
  end
  while 1 do os.sleep(math.huge) end
end
if fs.exists("/Kernel/Startup/") then
  v,err=xpcall(function() list("/Kernel/Startup/",".lua",kernel.execInit) end,function() print(debug.traceback()) end)
  if not v then
    kernel.panic("ERROR",err)
  end
  dofile("/Binaries/shell.lua")
  kernel.fakehalt()
else
  kernel.panic("Cannot found dir \"/Kernel/Startup/\"","Dir not found")
end