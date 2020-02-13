do ->
	WIN = no
	window.ap = null
	Paths = await fetch2 "paths.json", "json"

	codeShared = ["scripts/boot.cjsx", ...Paths.compns].map (val) => fetch2 val
	codeShared = await Promise.all codeShared
	codeShared = codeShared.join ""

	codeSystem = Paths.compnsSystem.map (val) => fetch2 val
	codeSystem = await Promise.all codeSystem
	codeSystem = codeShared + codeSystem.join ""

	[codeIframe, cssIframe, docIframe, css] = await Promise.all [
		"scripts/codeIframe.cjsx"
		"scripts/cssIframe.styl"
		"scripts/docIframe.html"
		"index.styl"
	].map (val) => fetch2 val
	codeIframe = codeShared + codeIframe

	codeSystem = coffee.compile codeSystem, bare: yes
	codeSystem = Babel.transform codeSystem,
		presets: ["react"]
		plugins: ["syntax-object-rest-spread"]
	.code
	eval codeSystem

	for k, color of Colors
		k = k.toLowerCase().replace("_", "-")
		cssIframe += """
			.bg-#{k}
				background #{color}
			.text-#{k}
				color #{color}\n
		"""
	el = document.createElement "style"
	el.textContent = stylus.render cssIframe + css
	document.head.appendChild el

	ReactDOM.render(
		React.createElement App
		document.getElementById "app"
	)
	return
