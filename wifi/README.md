用到的api
## wifi.setmode（）
配置要使用的WiFi模式。可选的模式有4种。
* STA模式，终端模式，可以加入现有的无线网络
* AP模式，接入点模式，相当于路由器，创建局域网络并允许终端接入该网络
* STA+AP模式，同时工作在两种模式下（当使用STA+AP模式时，两个模式将使用相同的信道，因为模块只能监听一个信道）
* OFF模式，不使用wifi

** 即使设备已关闭，WiFi配置也将保留，直至更改为止。 **

使用方法
`wifi.setmode(mode[, save])`
mode 可选的参数：
*  wifi.STATION  对应STA模式
* `wifi.SOFTAP` 对应AP模式默认设备本地IP地址192.168.4.1，并为终端分配下一个可用的IP地址，例如192.168.4.2。
	* `wifi.STATIONAP` 对应STA+AP模式
	* `wifi.NULLMODE` 将WiFi模式更改为NULL_MODE会使wifi进入类似于MODEM_SLEEP的低功耗状态，前提wifi.nullmodesleep(false)是尚未调用。
save 选择是否将wifi模式保存进flash
	* `true` 断电保留WiFi模式配置。（默认）
	* `false` 断电不保留WiFi模式配置。
	
## wifi.sta.config（）
STA模式参数设置

使用方法
`wifi.sta.config(station_config)`
参数
+ `station_config` 类型table，包含配置信息
	+ `ssid` 类型string，接入点名称小于32个字符
	+ `pwd` 类型string，接入点密码小于64字符，连接没有密码的开放网络这个参数设置为空即可，注意：WPA至少需要8个字符，但ESP8266也可以连接到WEP接入点（可以提供40位WEP密钥作为其对应的5个字符的ASCII字符串）。
	+ `auto`默认为ture
		+ `true`启用自动连接并连接到接入点，当auto=true不需要调用wifi.sta.connect()
		+ `false` 禁用自动连接并保持与接入点的连接
	+ `bssid`包含接入点MAC地址的字符串（可选）
	如果您有多个具有相同SSID的接入点，则可以设置BSSID。
如果为特定SSID设置BSSID并且想要将站配置为仅在没有BSSID要求的情况下连接到相同的SSID，则必须首先配置为首先驻留到不同的SSID，然后连接到所需的SSID
以下格式有效：
“DE：C1：A5：51：F1：ED”
“AC-1D-1C-B1-0B-22”
“DE AD BE EF 7A C0”
	+ `save`将STA配置保存到flash（默认为ture）
		+ `ture`断电保存
		+ `false`断电不保存

## wifi.sta.connect（）
在STA模式下连接到已配置的AP。如果禁用了自动连接，则只需要调用此方法`wifi.sta.config()`
用法
`wifi.sta.connect([connected_cb])`
参数：
+ `connected_cb`：当站连接到接入点时执行回调。（可选的）
表中返回的项目：
	+ `SSID`：接入点的SSID。（格式：字符串）
	+ `BSSID`：接入点的BSSID。（格式：字符串）
	+ `channel`：接入点所在的通道。（格式：数字）