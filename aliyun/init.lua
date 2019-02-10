require"aliyun"
--wifi连接配置信息
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="qwer"		--wifi名称
station_cfg.pwd="1234567890"	--密码
wifi.sta.config(station_cfg)
wifi.sta.connect()
wifi.sta.autoconnect(1)
--连接wifi
function connect()
	cnt=0
	tmr.alarm(1,1000,tmr.ALARM_AUTO,function()
		if (wifi.sta.getip()==nil) and (cnt<20) then
			print("--ip unavable,wating.......")
			cnt=cnt+1
		else
			tmr.stop(1)
			if (cnt<20) then 
				print("ip:"..wifi.sta.getip())
				print("mac:"..wifi.sta.getmac())
				ready="wifiok"

			else
				print("--no wifi")
			end
		end
	end)
	
end
--连接mqtt服务器

function mqtt_do()
	m:connect("a1vYCEPm6L6.iot-as-mqtt.cn-shanghai.aliyuncs.com", 1883, 0,0, 
				function(client) 
					print("----DiFi MQTT Server Connected") 
					tmr.stop(0)
					m:subscribe("/sys/a1vYCEPm6L6/869300031657095/thing/service/property/set",0, function(conn) print("subscribe success") end)
					m:on("message", function(client, topic, data) print(data) end)
				end, 
				function(client, reason) 
				print("Failed reason: "..reason) 
				end)
end
post=0
function init()
	tmr.alarm(0,2000,tmr.ALARM_AUTO,function()
	if wifi.sta.getip() == nil then
		print("on wifi")
		connect()
	elseif ready=="wifiok" then 
		body = aliyun.httppost()
		if body == nil then
			post=post+1
			print("-------------"..post)
		else
			print(body)
			jsondata = sjson.decode(body)
			testcode=jsondata["code"]
			if testcode == 200 then
				user = jsondata["data"]["iotId"]
				password = jsondata["data"]["iotToken"]
				print("user:"..user.."password"..password)
				ready="userok"
			end
		end
	elseif ready=="userok" then
		print("start mqtt")
		m = mqtt.Client(34,90,user,password,1)		
		m:on("connect", function(client) 
			print ("----Aliyun MQTT Server Connected1") 
		end)
		m:on("offline", function(client) 
				print ("----Aliyun MQTT Server Offline") 
				collectgarbage("collect")
				mqttdo()
		end)
		mqtt_do()
	
	end
	end)
end
init()