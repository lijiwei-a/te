passwd = require("Passwd")
io = require("io")
ipwd=io.read("Require password: ")
wrongcount=0
while true do
    if ipwd==passwd.getpwd() then
        break
    elseif wrongcount==3 then
        kernel.fakehalt("Wrong password")
    else 
        ipwd=io.read("Wrong password try again: ")
        wrongcount=wrongcount+1
    end
end