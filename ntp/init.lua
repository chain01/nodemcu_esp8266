--wifi连接配置信息
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = "智能路由" --wifi名称
station_cfg.pwd = "" --密码
wifi.sta.config(station_cfg)
wifi.sta.connect()
wifi.sta.autoconnect(1)

--连接wifi
function connect()
	cnt = 0
	tmr.alarm(
		1,
		1000,
		tmr.ALARM_AUTO,
		function()
			if (wifi.sta.getip() == nil) and (cnt < 20) then
				print("--ip unavable,wating.......")
				cnt = cnt + 1
			else
				tmr.stop(1)
				if (cnt < 20) then
					print("ip:" .. wifi.sta.getip())
					print("mac:" .. wifi.sta.getmac())
					ready = "wifiok"
				else
					print("--no wifi")
				end
			end
		end
	)
end
function ntp()
	print("ntp start")
	tmr.stop(0)
	tmr.alarm(
		2,
		10000,
		1,
		function()
			sntp.sync(
				{
					"time1.aliyun.com",
					"tw.pool.ntp.org",
					"0.cn.pool.ntp.org",
					"0.tw.pool.ntp.org",
					"1.cn.pool.ntp.org",
					"1.tw.pool.ntp.org",
					"3.cn.pool.ntp.org",
					"3.tw.pool.ntp.org"
				},
				function(sec, usec, server, info) -- success callback
					--print("SNTP server " .. server)
					--print('sync', sec, usec, info)
					local tm = rtctime.epoch2cal(sec)
					local date = string.format("data:%04d.%02d.%02d", tm["year"], tm["mon"], tm["day"])
					local time = string.format("time:%02d-%02d-%02d", tm["hour"] + 8, tm["min"], tm["sec"])
					print(date .. time)
				end,
				function(errno, errstr) -- error callback
					print("SNTP failure")
				end
			)
		end
	)
end
function init()
	tmr.alarm(
		0,
		2000,
		tmr.ALARM_AUTO,
		function()
			if wifi.sta.getip() == nil then
				print("on wifi")
				connect()
			elseif ready == "wifiok" then
				print("on ntp")
				ntp()
			end
		end
	)
end
init()
