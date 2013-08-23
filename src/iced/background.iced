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
