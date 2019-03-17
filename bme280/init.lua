alt=320 -- altitude of the measurement place

sda, scl = 3, 4
i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
bme280.setup()
tmr.alarm(3,10000,tmr.ALARM_AUTO,function()
	T, P, H, QNH = bme280.read(alt)
	if P ~= nil   then
		print(string.format("Actual pressure =%d.%03d", P/1000, P%1000))
	end
	if QNH ~= nil then 
		print(string.format("Relative pressure =%d.%03d", QNH/1000, QNH%1000))
	end
	if H~=nil    then
		print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
	end
end)