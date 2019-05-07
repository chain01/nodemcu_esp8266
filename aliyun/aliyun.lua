module(..., package.seeall)
DeviceNameFnc, ProductKey, DeviceSecretFnc = "", "", ""
function getBody()
	data = "clientId" .. DeviceNameFnc .. "deviceName" .. DeviceNameFnc .. "productKey" .. ProductKey
	signKey = DeviceSecretFnc
	sign = crypto.toHex(crypto.hmac("md5", data, signKey))
	return "productKey=" ..
		ProductKey .. "&sign=" .. sign .. "&clientId=" .. DeviceNameFnc .. "&deviceName=" .. DeviceNameFnc
end
sucecc = 0
function httppost()
	if sucecc == 0 then
		if DeviceNameFnc ~= "" and ProductKey ~= "" and DeviceSecretFnc ~= "" then
			bodydata = getBody()
			print("-----------------" .. bodydata)
			http.post(
				"https://iot-auth.cn-shanghai.aliyuncs.com/auth/devicename",
				"Content-Type:application/x-www-form-urlencoded\r\n",
				bodydata,
				function(code, data)
					if (code < 0) then
						print("HTTP request failed")
					else
						--print(code, data)
						datatest = data
						print("ok")
						sucecc = 1
					end
				end
			)
			return datatest
		else
			print("aliyun auth error")
		end
	else
		return datatest
	end
end
