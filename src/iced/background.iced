parser = new DOMParser()

login_usereg = (username, password, callback) ->
	$.post(
		CONST.url.login
		{
			action: "login"
			user_login_name: username
			user_password: (hex_md5 password)
		}
		callback
	)

window.test = (username, password) ->
	login_usereg username, password, (data) ->
		console.log data

online_usereg = (callback) ->
	$.get(
		CONST.url.online
		{}
		callback
	)
window.online_stats = () ->
	online_usereg (data)->
		elms = (parser.parseFromString data,"text/html").querySelectorAll "td.maintd"
		count = elms.length/12
		console.log (elms[i*12+j].innerText for j in [2,3] for i in [1..count-1]) 

stats_usereg = (callback) ->
	$.get(
		CONST.url.stats
		{}
		callback
	)	

window.get_stats = () ->
	stats_usereg	(data) ->
		doc = parser.parseFromString data,"text/html"
		elms = doc.querySelectorAll "td.maintd"
		wired_in = parseFloat elms[1].innerText
		wireless_in = parseFloat elms[7].innerText	
		console.log [wired_in,wireless_in,wired_in+wireless_in]

