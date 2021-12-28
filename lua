local io=require("io")
print("Use os.exit() to exit")
print("MicroLua")
while true do
  luacmd=io.read("lua> ")
  if luacmd=="os.exit()" then
    return
  end
  function error(reason) print(reason) end
  code=load("return "..luacmd,"=stdin")
  if not code then
    code,reason=load(luacmd,"=stdin")
  end
  if code then
    local result = table.pack(xpcall(code, debug.traceback))
    if not result[1] then
      print(result[3])
    end
    local ok, why = pcall(function()
      for i = 2, result.n do
        print(require("serialization").serialize(result[i], true) .. "  ")
      end
    end)
    if not ok then
      print(why)
    end
  else
    print(reason)
  end
end