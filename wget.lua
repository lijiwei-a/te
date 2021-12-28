local internet=require("component").internet
local fs=require("Filesystem")
local args={...}

local handle=internet.request(args[1])
if not handle then
    error("invaild URL.")
end
handle.finishConnect()
local code,text,header=handle.response()
print("code: "..tostring(code).." "..text)
if code~=200 then
    error("server return "..tostring(code).." "..text)
end
print("Length: "..header["Content-Length"][1])
print("Server: "..header["Server"][1])
filename=string.split(args[1],"/")
filename=filename[#filename]
if path=="/" then
    filename="/"..filename
else
    filename=path.."/"..filename
end
file=fs.open(filename,"w")
repeat
	data=handle.read(math.huge)
	computer.pullSignal(0)
	if data then
		fs.write(file,data)
	end
until not data
handle.close()
fs.close(file)
print("Done.")