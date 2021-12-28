local args={...}

if not args[1] then
	args[1]=path
end

local list1=fs.list(args[1])
local str1=''
for i=1,#list1 do
	if cursorPos.x+#str1+#list1[i]+4*i>resX then
		print(str1)
		str1=list1[i]
	else
		str1=str1.."    "..list1[i]
	end
end
print(str1)