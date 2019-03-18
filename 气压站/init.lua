
--wifi连接配置信息
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="智能路由"		--wifi名称
station_cfg.pwd=""	--密码
wifi.sta.config(station_cfg)
wifi.sta.connect()
wifi.sta.autoconnect(1)
date="data:2019.01.01"
time="time:01-01-01"
Actual="Actual=1013.341"
pressure1_1="1013.341"
Relative="Relative=1052.683"
pressure1_2="1052.683"
--阿里云信息配置
--aliyun.DeviceNameFnc,aliyun.ProductKey,aliyun.DeviceSecretFnc = "869300031657095","a1vYCEPm6L6","XAplqKacU6SAKAbG8VQxvpoJ27BSIHpa"
--订阅
subscribe1="/sys/a137oBqUiTV/jmiNPT1yRCaa41rdGa2o/thing/service/property/set"
--发布
publish1="/sys/a137oBqUiTV/jmiNPT1yRCaa41rdGa2o/thing/event/property/post"

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
function ntp()
--print("ntp start")
--tmr.stop(0)
tmr.alarm(2, 10000, 1,function() 
  sntp.sync({"time1.aliyun.com",
			"tw.pool.ntp.org",
			"0.cn.pool.ntp.org",
			"0.tw.pool.ntp.org",
			"1.cn.pool.ntp.org",
			"1.tw.pool.ntp.org",
			"3.cn.pool.ntp.org",
			"3.tw.pool.ntp.org",
			},
    function(sec, usec, server, info) -- success callback
      --print("SNTP server " .. server)
	   --print('sync', sec, usec, info)
	   local tm = rtctime.epoch2cal(sec)
      date = string.format("data:%04d.%02d.%02d", tm["year"], tm["mon"], tm["day"])
      time = string.format("time:%02d-%02d-%02d", tm["hour"]+8, tm["min"], tm["sec"])
	  print(date..time)
	  sendPublish(pressure1_1,pressure1_2)
    end,
    function(errno, errstr) -- error callback
      print("SNTP failure")
    end)
end)
end
--连接mqtt服务器

function mqtt_do()
	m:connect("a137oBqUiTV.iot-as-mqtt.cn-shanghai.aliyuncs.com", 1883, 0,0, 
				function(client) 
					print("----Aliyun MQTT Server Connected") 
					tmr.stop(0)
					m:subscribe(subscribe1,0, function(conn) print("subscribe success") end)
					m:on("message", function(client, topic, data) 
					--print(data) 
					uart.write(0,data)
					end)
				end, 
				function(client, reason) 
				print("Failed reason: "..reason) 
				end)
end
function sendPublish(pub_data1,pub_data2)
	pressure1_1=pub_data1
	pressure1_2=pub_data2
	base={}
	base.method = "thing.event.property.post"
	base.id = "52490979"
	base.params={}
	base.params.pressure1=tonumber(pressure1_1)
	base.params.pressure2=tonumber(pressure1_2)
	json_data=sjson.encode(base)
	print(json_data)
	m:publish(publish1,json_data,1,0,function(client)
	print("sent "..json_data.." to "..publish1)
end)
end
--uart.on("data","\r",function(data) sendPublish(data) end, 0)
function init()
	local post=0
	tmr.alarm(0,2000,tmr.ALARM_AUTO,function()
	if wifi.sta.getip() == nil then
		print("on wifi")
		connect()	
	elseif ready=="wifiok" then
		print("start mqtt")
		ntp()
		m = mqtt.Client("jmiNPT1yRCaa41rdGa2o|securemode=3,signmethod=hmacsha1|",70,"jmiNPT1yRCaa41rdGa2o&a137oBqUiTV","28BF18C52671FDD489004DB74D989A2B48ED88F5",1)		
		m:on("connect", function(client) 
			print ("----Aliyun MQTT Server Connected1") 
		end)
		m:on("offline", function(client) 
				print ("----Aliyun MQTT Server Offline") 
				collectgarbage("collect")
				mqtt_do()
		end)
		mqtt_do()
	
	end
	end)
end
init()
-- setup SPI and connect display
function init_spi_display()
    -- Hardware SPI CLK  = GPIO14
    -- Hardware SPI MOSI = GPIO13
    -- Hardware SPI MISO = GPIO12 (not used)
    -- Hardware SPI /CS  = GPIO15 (not used)
    -- CS, D/C, and RES can be assigned freely to available GPIOs
    local cs  = 8 -- GPIO15, pull-down 10k to GND
    local dc  = 2 -- GPIO2
    local res = 0 -- GPIO16

    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
    -- we won't be using the HSPI /CS line, so disable it again
    gpio.mode(8, gpio.INPUT, gpio.PULLUP)

    disp = u8g2.ssd1306_128x64_noname(1, cs, dc, res)
end

function u8g2_prepare()
  disp:setFont(u8g2.font_6x10_tf)
  disp:setFontRefHeightExtendedText()
  disp:setDrawColor(1)
  disp:setFontPosTop()
  disp:setFontDirection(0)
end
function u8g2_ascii_1()
  disp:drawStr( 0, 0, date)
  disp:drawStr( 0, 10, time)
  disp:drawStr( 0, 20, Actual)
  disp:drawStr( 0, 30, Relative)
  
 end

function draw()
  u8g2_prepare()

  local d3 = bit.rshift(draw_state, 3)
  local d7 = bit.band(draw_state, 7)
  u8g2_ascii_1()



end

function loop()
  -- picture loop  
  disp:clearBuffer()
  draw()
  disp:sendBuffer()
  
  -- increase the state
  draw_state = draw_state + 1
  if draw_state >= 12*8 then
    draw_state = 0
  end

  -- delay between each frame
  loop_tmr:start()
end


draw_state = 0
loop_tmr = tmr.create()
loop_tmr:register(100, tmr.ALARM_SEMI, loop)

--init_i2c_display()
init_spi_display()

print("--- Starting Graphics Test ---")
loop_tmr:start()
alt=320 -- altitude of the measurement place

sda, scl = 3, 4
i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
bme280.setup()
tmr.alarm(3,10000,tmr.ALARM_AUTO,function()
	T, P, H, QNH = bme280.read(alt)
	if P ~= nil   then
		print(string.format("Actual=%d.%03d", P/1000, P%1000))
		Actual=string.format("Actual=%d.%03d", P/1000, P%1000)
		pressure1_1=string.format("%d.%03d", P/1000, P%1000)
	end
	if QNH ~= nil then 
		print(string.format("Relative=%d.%03d", QNH/1000, QNH%1000))
		Relative=string.format("Relative=%d.%03d", QNH/1000, QNH%1000)
		pressure1_2=string.format("%d.%03d", QNH/1000, QNH%1000)
	end
	if H~=nil    then
		print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
	end
end)