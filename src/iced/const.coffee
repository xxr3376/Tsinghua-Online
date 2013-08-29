window.CONST =
	url:
		login_net: "http://net.tsinghua.edu.cn/cgi-bin/do_login"
		logout_net: "http://net.tsinghua.edu.cn/cgi-bin/do_logout"
		login_suc: "http://net.tsinghua.edu.cn/succeed.html?"
		login: "http://usereg.tsinghua.edu.cn/do.php",
		online: "http://usereg.tsinghua.edu.cn/online_user_ipv4.php",
		stats: "http://usereg.tsinghua.edu.cn/user_detail_statistics.php"
		check: "http://net.tsinghua.edu.cn/cgi-bin/do_login"
	flag:
		login_ok: 'ok'
	op:
		updateFlow: 'updateFlow'
		updateConnectNumber: 'updateCN'
		dropAllConnect: 'dropAll'
		connectNow: 'CN'
		disconnect: 'disconnect'
		keepOnlineChange: 'changeOnlineSetting'
		getLastError: 'getLastError'
	unitConvert:
		'B' : 1
		'K' : Math.pow(2, 10)
		'M' : Math.pow(2, 20)
		'G' : Math.pow(2, 30)
		'T' : Math.pow(2, 40)
	status:
		logged_in: 1
		not_logged_in: 2
		cant_reach_net: 3

		auto_online_on: "1"
		auto_online_off: "0"
		auto_online_event_end: 0

		connected: 4
		unconnected: 5
	auto_online_intervals:
		IP_EXIST: 25000
		NORMAL: 10000
		IMMEDIATELY: 0
	err_code_list:
		username_error: "用户名错误"
		password_error: "密码错误"
		user_tab_error: "认证程序未启动"
		user_group_error: "您的计费组信息不正确"
		non_auth_error: "您无须认证，可直接上网"
		status_error: "用户已欠费，请尽快充值"
		available_error: "您的帐号已停用"
		delete_error: "您的帐号已删除"
		ip_exist_error: "IP已存在，请稍后再试"
		usernum_error: "用户数已达上限"
		online_num_error: "该帐号的登录人数已超过限额"
		mode_error: "系统已禁止WEB方式登录，请使用客户端"
		time_policy_error: "当前时段不允许连接"
		flux_error: "您的流量已超支"
		minutes_error: "您的时长已超支"
		ip_error: "您的 IP 地址不合法"
		mac_error: "您的 MAC 地址不合法"
		sync_error: "您的资料已修改，正在等待同步，请 2 分钟后再试"
		ip_alloc: "您不是这个地址的合法拥有者，IP 地址已经分配给其它用户"
		ip_invaild: "您是区内地址，无法使用"
		no_connection: "无法连接到校园网"
	fatal_error: [
		"username_error"
		"password_error"
		"available_error"
		"delete_error"
		"status_error"
	]
	storageKey:
		auto_online: 'sp_key_auto_online'
