WIN = yes
TID = "{{tid}}"
app = null

task = new Proxy
	params: null
	env: null
	messageIfrSysIfrResolves: []
	messageSysIfrListeners: []
	contextMenuEvents: {}
	loadedLibs: []

	import: (paths) ->
		paths = _.castArray paths
			.filter (path) => path not in @loadedLibs
			.map (path) =>
				@loadedLibs.push path
				if exec = /^(npm|gh):(.+)$/.exec path
					path = "https://cdn.jsdelivr.net/#{exec[1]}/#{exec[2]}"
				path
			.map (path) =>
				new Promise (resolve) =>
					ext = task.pathExtname path
					code =
						if /^https?:\/\//.test path then await (await fetch path).text()
						else await task.readFile path
					switch ext
						when "coffee"
							await @import "gh:tiencoffee/libs/coffee.min.js"
							code = coffee.compile code, bare: yes
							resolve [code]
						when "cjsx"
							await @import ["gh:tiencoffee/libs/coffee.min.js", "npm:babel-standalone@6.26.0"]
							code = coffee.compile code, bare: yes
							{code} = Babel.transform code,
								presets: ["react"]
								plugins: ["syntax-object-rest-spread"]
							resolve [code]
						when "styl"
							await @import "gh:tiencoffee/libs/stylus.min.js"
							code = stylus.render code
							resolve [code, "css"]
						when "css"
							resolve [code, "css"]
						else
							resolve [code]
					return
		for [code, type] from await Promise.all paths
			switch type
				when "css"
					el = document.createElement "style"
					el.textContent = code
					document.head.appendChild el
				else
					window.eval code
		return

	showContextMenu: (menu) ->
		@contextMenuEvents = {}
		menuData = []
		do handle = (menu, menuData) =>
			for props from menu
				if props
					if props.onClick
						uuid = uuidv4()
						@contextMenuEvents[uuid] = props.onClick
						props.onClick = uuid
					menuData.push props
					if props.submenu
						submenu = props.submenu
						props.submenu = []
						handle submenu, props.submenu
			return
		uuid = await task["sendContextMenu#{TID}"] menuData
		@contextMenuEvents[uuid]()
		return

	setSizeWinFitContent: ->
		document.body.classList.add "fix-autosize"
		task["iframeDidResize#{TID}"] document.body.offsetWidth, document.body.offsetHeight
		document.body.classList.remove "fix-autosize"
		return

	listen: (messages) ->
		Object.assign @messageSysIfrListeners, messages
		return
,
	get: (target, name) =>
		if name of target
			if typeof target[name] is "function"
				target[name].bind target
			else target[name]
		else (...val) =>
			new Promise (resolve) =>
				mid = uuidv4()
				target.messageIfrSysIfrResolves[mid] = resolve
				window.top.postMessage {name, val, mid, tid: TID}, "*"
				return

	set: (target, name, val) =>
		target[name] = val
		yes

ap = window.ap or task

window.addEventListener "message", (event) =>
	switch event.data.type
		when "ifrSysIfr"
			{val, mid} = event.data
			task.messageIfrSysIfrResolves[mid] val
			delete task.messageIfrSysIfrResolves[mid]
		when "sysIfr"
			{name, val} = event.data
			task.messageSysIfrListeners[name]? val
	return

await do =>
	document.getElementById("script-app").remove()
	[task.params, task.env] = await Promise.all [
		task.getParamsTask()
		task.getEnvTask()
	]
	Object.assign task, ```{{@sharedMethods}}```
	onMouseDownUpApp = ({x, y, type}) =>
		if task.env.isSystem then ap.dispatchMouseDownUpApp x, y, type, TID
		else task["dispatchMouseDownUpApp#{TID}"] x, y, type, TID
		return
	document.addEventListener "mousedown", onMouseDownUpApp, yes
	document.addEventListener "mouseup", onMouseDownUpApp, yes
	return

App = null
await ((TID) =>
	await new Promise (resolve{{tid}}) =>
		{{code}}
		App::__componentWillMount = App::componentWillMount
		App::componentWillMount = ->
			@__componentWillMount?()
			app = @
			return
		if App.defaultParams
			task.params = _.merge {}, App.defaultParams, task.params
		resolve{{tid}}()
		return
	return
)()

ReactDOM.render <App/>, document.getElementById("app"), =>
	await task["iframeDidMount#{TID}"]()
	setTimeout =>
		task.setSizeWinFitContent()
		return
	, 5
	return
