if true then
	print("set wifi") --控制台打印
	wifi.setmode(wifi.STATION) --设置工作模式为STA
	station_cfg = {} --创建一个表用于STA模式参数配置
	station_cfg.ssid = "204" --ssid名
	station_cfg.pwd = "1234567890" --密码
	wifi.sta.config(station_cfg) --配置STA
	wifi.sta.connect() --连接到AP
	wifi.sta.autoconnect(1) --自动连接
	local cnt = 0 --局部变量用于储存尝试连接AP的次数
	tmr.alarm(
		1,
		1000,
		tmr.ALARM_AUTO,
		function()
			--开启定时器每秒执行一次
			if (wifi.sta.getip() == nil) and (cnt < 20) then --根据是否获取到IP判断是否连接上AP，可以控制尝试次数
				print("--ip unavable,wating.......") --控制台打印
				cnt = cnt + 1 --每尝试一次计数加一
			else --获取到IP或者尝试次数达到指定值
				tmr.stop(1) --停止定时器任务
				if (cnt < 20) then --如果次数小于20证明成功连接AP
					--if (wifi.sta.getip()~=nil) --或者通过是否获取到IP确定连接
					print("ip:" .. wifi.sta.getip()) --打印获取的IP
					print("mac:" .. wifi.sta.getmac()) --打印mac
				else --如果上面不成立证明在指定次数内连接失败
					print("--no wifi") --控制台打印打印
				end
			end
		end
	)
else --增加健壮性这句不会被执行
	print("error")
end
wifi.eventmon.register(
	wifi.eventmon.STA_CONNECTED,
	function(T)
		print("\n\tSTA - CONNECTED" .. "\n\tSSID: " .. T.SSID .. "\n\tBSSID: " .. T.BSSID .. "\n\tChannel: " .. T.channel)
	end
)

wifi.eventmon.register(
	wifi.eventmon.STA_DISCONNECTED,
	function(T)
		print("\n\tSTA - DISCONNECTED" .. "\n\tSSID: " .. T.SSID .. "\n\tBSSID: " .. T.BSSID .. "\n\treason: " .. T.reason)
	end
)

wifi.eventmon.register(
	wifi.eventmon.STA_AUTHMODE_CHANGE,
	function(T)
		print(
			"\n\tSTA - AUTHMODE CHANGE" .. "\n\told_auth_mode: " .. T.old_auth_mode .. "\n\tnew_auth_mode: " .. T.new_auth_mode
		)
	end
)

wifi.eventmon.register(
	wifi.eventmon.STA_GOT_IP,
	function(T)
		print(
			"\n\tSTA - GOT IP" ..
				"\n\tStation IP: " .. T.IP .. "\n\tSubnet mask: " .. T.netmask .. "\n\tGateway IP: " .. T.gateway
		)
	end
)

wifi.eventmon.register(
	wifi.eventmon.STA_DHCP_TIMEOUT,
	function()
		print("\n\tSTA - DHCP TIMEOUT")
	end
)
wifi.eventmon.register(
	wifi.eventmon.WIFI_MODE_CHANGED,
	function(T)
		print("\n\tSTA - WIFI MODE CHANGED" .. "\n\told_mode: " .. T.old_mode .. "\n\tnew_mode: " .. T.new_mode)
	end
)
