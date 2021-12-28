local io=require("io")
PATH="/Binaries;.;/home;"
path='/'

function error(str)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFF0000)
  print(str)
  gpu.setForeground(0xFFFFFF)
end

while true do
while true do
  local cmd=io.read(path.." # ")
  if cmd=="shutdown" then
    computer.shutdown()
  elseif cmd=="reboot" then
    computer.shutdown(true)
  elseif cmd=='pwd' then
    print(path)
  elseif cmd=='' then
    break
  else
    local found=false
    local PATHList=string.split(PATH,";")
    local args={}
    local arg=string.split(cmd," ")
    for i=2,#arg do
      table.insert(args,arg[i])
    end
    cmd=arg[1]
    for i=1,#PATHList do
      cmd=PATHList[i].."/"..cmd
      if fs.exists(cmd) then
        found=true
        xpcall(function() load(fs.readfile(cmd),"="..cmd)(table.unpack(args)) end,function(reason) 
                                                 gpu.setBackground(0x000000)
                                                 gpu.setForeground(0xFF0000)
                                                 traceback=debug.traceback()
                                                 print("a error created during open "..cmd..": "..reason)
                                                 print(traceback)
                                                 gpu.setForeground(0xFFFFFF) 
                                              end)
        break
      end
    end
    if not found then
      gpu.setBackground(0x000000) 
      gpu.setForeground(0xFF0000)
      print(arg[1]..":file not found")
      gpu.setForeground(0xFFFFFF)
    end
  end
  break
end
end