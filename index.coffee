do ->
	cache =
		css: ""
		lib: ""
		comp: ""
		boot: ""
		system: ""
		user: ""

	get = (url) =>
		res = await fetch url
		res.ok and res.text() or ""
	code = ""
	styl = ""

	text = await get "index.styl"
	text = stylus.render text.replace /\)\n\t+\(/g, ") ("
	styl += text
	cache.css += text

	libs = "
		reactive2
		pantap
	"
	for lib from libs.split " "
		text = await get "libs/#{lib}.coffee"
		code += text
		cache.lib += text

	code += await get "scripts/defs.cjsx"

	comps = "
		App
		Dialog
		Icons
		Taskbar
		TaskbarTray
	"
	for comp from comps.split " "
		code += await get "comps/#{comp}.cjsx"

	code += cache.boot = await get "scripts/boot.cjsx"
	code += await get "scripts/main.cjsx"

	cache.system = await get "scripts/system.cjsx"
	cache.user = await get "scripts/user.cjsx"

	{code} = Babel.transform(
		coffee.compile code, bare: yes
		presets: ["react"]
		plugins: ["syntax-object-rest-spread"]
	)
	eval code

	styl = stylus.render styl
	el = document.createElement "style"
	el.textContent = styl
	document.head.appendChild el

	document.body.hidden = no
	return
