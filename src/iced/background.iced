parser = new DOMParser()
login_usereg = (username, md5_password, successCallback, failCallback) ->
	$.post(
		CONST.url.login
		{
			action: "login"
			user_login_name: username
			user_password: md5_password
		}
		(result) ->
			if result == CONST.flag.login_ok
				successCallback()
			else
				failCallback result
	)
login_guarantee = (callback) ->
	username = localStorage.getItem 'username', ''
	password = localStorage.getItem 'password', ''
	if not username or not password
		console.log "haven't set token, use setToken first"
	login_usereg username, password, callback, (failReason) ->
		console.log("登录失败：" + failReason)
online_usereg = (callback) ->
	login_guarantee ()->
		$.get(
			CONST.url.online
			(data)->
				elms = (parser.parseFromString data,"text/html").querySelectorAll "td.maintd"
				count = elms.length/12
				callback((elms[i*12+j].innerText for j in [2,3] for i in [1..count-1]))
		)
stats_usereg = (callback) ->
	login_guarantee ()->
		$.get( CONST.url.stats, (data) ->
			doc = parser.parseFromString data,"text/html"
			elms = doc.querySelectorAll "td.maintd"
			wired_in = parseFloat elms[1].innerText
			wireless_in = parseFloat elms[7].innerText
			callback([wired_in,wireless_in,wired_in+wireless_in])
		)

##############
# interface
window.get_stats = () ->
	stats_usereg (result) ->
		console.log result
window.setToken = (username, password) ->
	localStorage.setItem 'username', username
	localStorage.setItem 'password', (hex_md5 password)
window.online_stats = () ->
	online_usereg (result) ->
		console.log(result)
