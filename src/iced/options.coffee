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
			updateTab this.getAttribute('contentid')

		save_token = () ->
			username = ($ '#username').val()
			password = ($ '#password').val()
			if not username or not password
				return
			localStorage.setItem 'username', username
			localStorage.setItem 'password', (hex_md5 password)
			($ '#saved').css('opacity', 1)
			($ '#myonoffswitch').attr('checked', null)
			chrome.extension.sendMessage(
				op: CONST.op.reset
			)
			setTimeout(() ->
				($ '#saved').css('opacity', 0)
			1000)
			return false

		($ '#save-token').on 'click', save_token
		($ '#token-form').on 'submit', save_token

		current = localStorage.getItem CONST.storageKey.auto_online, CONST.status.auto_online_off
		if current is CONST.status.auto_online_off
			($ '#myonoffswitch').attr('checked', null)

		($ '#myonoffswitch').change ()->
			now = CONST.status.auto_online_off
			if ($ this).is ':checked'
				now = CONST.status.auto_online_on
			localStorage.setItem CONST.storageKey.auto_online, now
			chrome.extension.sendMessage(
				op: CONST.op.keepOnlineChange
				now: now
			)
		updateTab()
	init()
