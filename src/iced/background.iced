parser = new DOMParser()

auto_online_interval = CONST.auto_online_intervals.NORMAL
auto_online_event = CONST.status.auto_online_event_end

# about token

get_token = () ->
	username = localStorage.getItem 'username', null
	password = localStorage.getItem 'password', null
	if not username or not password
		set_error "no_token"
		auto_online_clear()
		throw new Error("no_token")
	return [username, password]

# will convert unit to Byte
unit_convert = (input) ->
	matches = ($.trim input).match /(\d+(.\d+)?)([GMKB])/
	number = parseFloat matches[1]
	unit = matches[3]
	if unit of CONST.unitConvert
 		return number * CONST.unitConvert[unit]
	else
		return number
###
# about error
###
lastError = null
set_error = (errorCode) ->
	lastError = null
	chrome.extension.sendMessage(
		op: CONST.op.passErrorCode
		lastError: errorCode
		() ->
			sendError = chrome.runtime.lastError
			# if popup doesn't open
			if sendError
				chrome.browserAction.setBadgeText(
					text: '!'
				)
				lastError = errorCode
	)
clear_error = (noMessage) ->
	if not noMessage
		chrome.extension.sendMessage(
			op: CONST.op.removeError
		)
	chrome.browserAction.setBadgeText(
		text: ''
	)
	lastError = null
change_icon = (connectStatus) ->
	file = "/icons/19.png"
	if connectStatus is CONST.status.unconnected
		file = "/icons/disable.png"
	chrome.browserAction.setIcon(
		path: file
	)
###
# error end
###
fatal_error_handler = (err_code) ->
	if err_code in CONST.fatal_error
		auto_online_clear()
		localStorage.setItem CONST.storageKey.auto_online, CONST.status.auto_online_off
	else
		auto_online_set_event CONST.auto_online_intervals.NORMAL


auto_online_set_event = (interval) ->
	if auto_online_event == CONST.status.auto_online_event_end
		auto_online_event = setTimeout( () ->
				login_check auto_online_handle_login_status
			interval)

auto_online_login_fail = (err_code) ->
	set_error(err_code)
	switch err_code
		when "ip_exist_error"
			auto_online_set_event CONST.auto_online_intervals.IP_EXIST
		else
			fatal_error_handler err_code

auto_online_login_succ = (res) ->
	console.log res
	auto_online_set_event CONST.auto_online_intervals.NORMAL

auto_online_handle_login_status = (data) ->
	auto_online_event = CONST.status.auto_online_event_end
	if data.status == CONST.status.not_logged_in
		login_net_post auto_online_login_succ,auto_online_login_fail
	else if data.status == CONST.status.logged_in
		auto_online_set_event CONST.auto_online_intervals.NORMAL
	else if data.status == CONST.status.cant_reach_net
		set_error('no_connection')
		auto_online_set_event CONST.auto_online_intervals.NORMAL

auto_online_clear = () ->
	clearTimeout auto_online_event if auto_online_event
	auto_online_event = CONST.status.auto_online_event_end

process_online_setting_change = (nowStatus) ->
	if nowStatus is CONST.status.auto_online_on
		auto_online_set_event CONST.auto_online_intervals.IMMEDIATELY
	else if nowStatus is CONST.status.auto_online_off
		auto_online_clear()

######
# check current login status
# @output: {status: CONST.status.?, username: current_username}
login_check = (callback) ->
	$.post(CONST.url.check, "action=check_online", (response) ->
		matches = response.match /^online$/
		if matches
			$.post(CONST.url.userinfo_net, (response) ->
				matches = response.match /([a-zA-Z0-9]+),\d+,\d+,\d+,\d+,\d+,\d+,\d+,([0-9\.]+),\d+,\d*,([0-9\.]+),\d+/
				if matches
					change_icon CONST.status.connected
					clear_error()
					callback && callback(
						status: CONST.status.logged_in
						username: matches[1]
					)
				else
					change_icon CONST.status.unconnected
					callback && callback(
						status: CONST.status.not_logged_in
					)
			).fail ->
				change_icon CONST.status.unconnected
				callback && callback(
					status: CONST.status.cant_reach_net
				)
		else
			change_icon CONST.status.unconnected
			callback && callback(
				status: CONST.status.not_logged_in
			)
	).fail ->
		change_icon CONST.status.unconnected
		callback && callback(
			status: CONST.status.cant_reach_net
		)

login_net_post = (successCallback, failCallback) ->
	[username, password] = get_token()
	$.post(
		CONST.url.login_net
		{
			username: username
			password: "{MD5_HEX}" + password
			action: "login"
			ac_id: 1
		}
		(result) ->
			if /^Login is successful.$/.test result
				change_icon CONST.status.connected
				clear_error()
				successCallback && successCallback result
			else
				change_icon CONST.status.unconnected
				failCallback && failCallback result
	)
login_ip = (ip, callback) ->
	[username, password] = get_token()
	$.post(
		CONST.url.iplogin_net
		{
			username: username
			password: password
			drop: 0
			type: 10
			n: 100
			is_pad: 1
			user_ip: ip
		}
		callback
	)
login_net = (successCallback) ->
	login_net_post(
		successCallback
		(result) ->
			set_error result
	)
logout_net = (callback) ->
	$.post(
		CONST.url.logout_net
		{
			action: "logout"
		}
		(res) ->
			callback && callback res
			change_icon CONST.status.unconnected
	)

login_usereg = (successCallback, failCallback) ->
	[ username, password] = get_token()
	$.post(
		CONST.url.login
		{
			action: "login"
			user_login_name: username
			user_password: password
		}
		(result) ->
			if result is CONST.flag.login_ok
				last_login = localStorage.setItem(
					CONST.storageKey.last_time_login_usereg
					new Date().getTime()
				)
				successCallback?()
			else
				failCallback?(result)
	)
login_guarantee = (successCallback) ->
	last_login = localStorage.getItem CONST.storageKey.last_time_login_usereg, 0
	now = new Date().getTime()
	if (now - last_login) < CONST.guarantee_intervals.usereg
		successCallback?()
	login_usereg successCallback, (failReason) ->
		if failReason in CONST.flag.password_error
			set_error 'password_error'

drop_user = (userIP,callback) ->
	console.log "IP:"+userIP
	$.post(
		CONST.url.online
		{
			action: "drop"
			user_ip: userIP
		}
		(result) ->
			if result == "ok"
				callback?(1)
			else
				callback?(0)
	)

dropall_usereg = (callback) ->
	await online_usereg defer online
	while online.length > 0
		await drop_user online[0][0], defer suc
		await online_usereg defer online
	callback && callback 0
drop_by_ip = (ip, callback) ->
	ip = ($.trim ip)
	await online_usereg defer onlineArray
	for online in onlineArray
		if ip == ($.trim online[0])
			drop_user online[0], callback
			return true
	return false
drop = (ip) ->
	console.log(ip)

online_usereg = (callback) ->
	login_guarantee ()->
		$.get(
			CONST.url.online
			(data)->
				elms = (parser.parseFromString data,"text/html").querySelectorAll "td.maintd"
				count = elms.length/14
				rtn = []
				if count > 1
					rtn = (elms[i*14+j].innerText for j in [1,3,11] for i in [1..count-1])
				callback(rtn)
		)
stats_usereg = (callback) ->
	await login_guarantee defer foo
	$.get( CONST.url.stats, (data) ->
			doc = parser.parseFromString data,"text/html"
			elms = doc.querySelectorAll "td.maintd"
			wired_in = unit_convert elms[1].innerText
			wireless_in = unit_convert elms[7].innerText
			callback wired_in + wireless_in
		)

real_time_userreg = (callback) ->
	await
		stats_usereg defer old
		online_usereg defer online
	total = old
	total += (unit_convert online[i][1]) for i in [0..online.length - 1] if online.length > 0
	callback(total, online.length, online)


##############
# interface
chrome.runtime.onMessage.addListener (feeds, sender, sendResponse) ->
	if feeds.op is CONST.op.updateFlow
		real_time_userreg (flow, onlineNum, onlineArray) ->
			sendResponse(
				data: flow
				onlineNum: onlineNum
				onlineArray: onlineArray
			)
		return true
	else if feeds.op is CONST.op.dropAll
		dropall_usereg (result) ->
			sendResponse(
				msg: 'ok'
			)
		return true
	else if feeds.op is CONST.op.connectNow
		login_net()
		return false
	else if feeds.op is CONST.op.disconnect
		process_online_setting_change CONST.status.auto_online_off
		logout_net()
		return false
	else if feeds.op is CONST.op.keepOnlineChange
		process_online_setting_change feeds.now
		return false
	else if feeds.op is CONST.op.getLastError
		if lastError
			sendResponse(
				lastError: lastError
			)
			clear_error(true)
			return true
		else
			return false
	else if feeds.op is CONST.op.reset
		auto_online_switch = localStorage.setItem CONST.storageKey.auto_online, CONST.status.auto_online_off
		clear_error(true)
		auto_online_clear()
		change_icon CONST.status.unconnected
		localStorage.removeItem CONST.storageKey.last_time_login_usereg
		login_check()
		return false
	else if feeds.op is CONST.op.drop
		drop_by_ip feeds.target, () ->
			sendResponse()
		return true
		
##########
# do when background.js start

onInstall = () ->
	console.log "install"
	localStorage.setItem CONST.storageKey.auto_online, CONST.status.auto_online_off
	chrome.tabs.create
		'url' : 'options.html'

onUpdate = () ->
	console.log "Extension Updated"

getVersion = () ->
	details = chrome.app.getDetails()
	return details.version
currVersion = getVersion()
prevVersion = localStorage['version']
if currVersion isnt prevVersion
	if typeof prevVersion is 'undefined'
		onInstall()
	else
	  onUpdate()
localStorage['version'] = currVersion

login_check()

auto_online_switch = localStorage.getItem CONST.storageKey.auto_online

process_online_setting_change auto_online_switch
