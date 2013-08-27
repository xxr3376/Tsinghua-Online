$ () ->
	tabHistory = -1
	updateTab = (target = -1) ->
		if target is -1
			anchor = ~~(window.location.href.split '#')[1]
		else
			anchor = target
		if tabHistory isnt -1
			($ ('#wrap-' + tabHistory)).hide(500)
			($ ('#menu a[contentid="' + tabHistory + '"]')).removeClass 'active'
		tabHistory = anchor
		($ ('#wrap-' + anchor)).show(500)
		($ ('#menu a[contentid="' + anchor + '"]')).addClass 'active'
	init = () ->
		username = localStorage.getItem 'username', ''
		($ '#username').val(username)
		($ '#menu a').on 'click', () ->
			console.log 'a' + this.getAttribute('contentid')
			updateTab this.getAttribute('contentid')
		($ '#save-token').on 'click', () ->
			username = ($ '#username').val()
			password = ($ '#password').val()
			if not username or not password
				return
			localStorage.setItem 'username', username
			localStorage.setItem 'password', (hex_md5 password)
		updateTab()
	init()
