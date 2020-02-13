class App extends React.Component
	constructor: (props) ->
		super props

		sharedMethods = "
			readFileObj
			pathDirname pathFilename pathBasename pathExtname pathJoin pathNormalize pathInPath
			menuToJsx
		"
			.split " "
			.map (name) => @[name] + ""
			.join ","
		sharedMethods = "{#{sharedMethods}}"

		autoBind @

		taskbarHeight = 36
		desktopX = 0
		desktopY = 0
		desktopWidth = innerWidth - desktopX
		desktopHeight = innerHeight - desktopY - taskbarHeight

		@desktop =
			x: 0
			y: 0
			width: desktopWidth
			height: desktopHeight
			path: "/A/desktop"
			background:
				path: "/A/files/imgs/galaxy.jpg"
				base64: ""
				fit: "cover"
				color: "#fff"
			task: null
		@taskbar =
			height: taskbarHeight
			placement: "bottom"
		@moment = moment()
		@appls = {}
		@tasks = {}
		@taskFocused = null
		@exts = {}
		@clipboard = []
		@maxLevelShortcut = 16
		@mouse =
			x: 0
			y: 0
		@cursorTouchmove = ""
		@sharedMethods = sharedMethods
		@textEncoder = new TextEncoder

	validateFilename: (name) ->
		name = (name + "").trim()
		unless name
			Error "Tên không được để trống"
		else if name in [".", ".."]
			Error "Tên không hợp lệ"
		else if /[\0\\\/:*?"<>|]/.test name
			Error 'Tên không được chứa các ký tự \\ / : * ? " < > |'
		else name

	setDesktopBackgroundPath: (path) ->
		new Promise (resolve) =>
			@desktop.background.path = path
			@desktop.background.base64 = await @readFile path, "DataURL"
			@message @desktop.task, "update"
			@setState {}
			resolve()
			return

	readFile: (path, type) ->
		path = await @resolveShortcut path
		fs.readFile path, {type}

	writeFile: (path, data = "", isAppend) ->
		path = await @resolveShortcut path
		unless _.isArrayBuffer data
			data = @textEncoder.encode(data).buffer
		entry = @statsEntry await fs[isAppend and "appendFile" or "writeFile"] path, data
		if @desktop.task and ap.pathDirname(path) is @desktop.path
			@message @desktop.task, "refresh"
		entry

	appendFile: (path, data) ->
		@writeFile path, data

	deleteFile: (path, moveToTrash) ->
		if moveToTrash then @movePathToTrash path
		else fs.unlink path

	saveFile: (opts) ->
		app.pickEntries
			kind: "save"
			filename: opts.name
			data: opts.data
			applPath: opts.applPath

	readFileObj: (file, type = "Text") ->
		new Promise (resolve) =>
			reader = new FileReader
			reader.onload = (event) =>
				resolve event.target.result
				return
			reader["readAs#{type}"] file
			return

	createDir: (path) ->
		@statsEntry await fs.mkdir path

	readDir: (path, deep) ->
		entries = await fs.readdir path, {deep}
		handle = (entries) =>
			for entry from entries
				await @statsEntry entry
				if entry.children
					await handle entry.children
			return
		await handle entries
		entries

	deleteDir: (path, moveToTrash) ->
		if moveToTrash then @movePathToTrash path
		else fs.rmdir path

	movePathToTrash: (path) ->
		dirname = @pathDirname path
		filename = @pathFilename path
		filename = "#{filename} #{uuidv4()}|#{encodeURI dirname}"
		@statsEntry await fs.rename path, @pathJoin("/C/trash", filename)

	movePath: (path, newPath, create) ->
		@statsEntry await fs.rename path, newPath, {create}

	copyPath: (path, newPath, create) ->
		@statsEntry await fs.copy path, newPath, {create}

	existsPath: (path) ->
		fs.exists path

	usageFs: ->
		fs.usage()

	getEntry: (path) ->
		entry = await @resolveShortcut path, yes
		@statsEntry entry

	statsEntry: (entry) ->
		if entry.isFile
			entry.file = await fs.readFile entry, type: "File"
			entry.size = entry.file.size
			entry.lastModifiedDate = entry.file.lastModifiedDate
		else
			stats = await fs.stat entry
			entry.size = stats.size
			entry.lastModifiedDate = stats.modificationTime
		entry.icon = await @iconEntry entry
		entry

	cloneEntry: (entry) ->
		if entry.isClonedEntry
			entry
		else
			clone =
				name: entry.name
				isFile: entry.isFile
				isDirectory: entry.isDirectory
				fullPath: entry.fullPath
				size: entry.size
				lastModifiedDate: entry.lastModifiedDate
				icon: entry.icon
				isClonedEntry: yes
			if entry.isFile
				clone.file = entry.file
				clone.url = "filesystem:#{location.origin}/persistent#{entry.fullPath}"
			if entry.children
				clone.children = entry.children.map (v) => @cloneEntry v
			clone

	iconEntry: (entry) ->
		if entry.isFile
			ext = @pathExtname entry.name
			icon =
				if entry.name is "app.yml"
					dirname = @pathDirname entry.fullPath
					@appls[dirname]?.icon
				else if ext is "lnk"
					entry = await @resolveShortcut entry.fullPath, yes
					await @iconEntry entry
				else if /^(png|jpe?g|gif)$/.test ext
					"media"
				else if /^(mp3|wav|ogg)$/.test ext
					"music"
				else if /^(mp4)$/.test ext
					"video"
				else if /^(zip|tar)$/.test ext
					"archive"
				else if /^(html?|pug|s?css|styl(us)?|c?jsx|js|coffee|ts|xml|vue)$/.test ext
					"code"
			icon or "document"
		else "folder-close"

	createShortcut: (targetPath, shortcutPath) ->
		new Promise (resolve) =>
			basename = @pathBasename targetPath
			shortcutPath ?= "#{@desktop.path}/#{basename}.lnk"
			entry = @statsEntry await fs.writeFile shortcutPath, targetPath
			@message @desktop.task, "update"
			resolve entry
			return

	resolveShortcut: (path, returnEntry) ->
		count = 0
		while "lnk" is @pathExtname path
			if count++ >= @maxLevelShortcut
				throw Error "Shortcut quá nhiều cấp lồng nhau"
			entry = await fs.getEntry path
			if entry.isFile
				text = await fs.readFile path
				unless text[0] is "/"
					text = @pathJoin path, text
				path = text
			else break
		if returnEntry
			@statsEntry await fs.getEntry path
		else path

	openFilesWith: (files) ->
		files = _.castArray files
		@runTask "/C/programs/OpenFilesWith/app.yml", null, entries: files
		return

	pathDirname: (path) ->
		path.split("/")[...-1].join("/") or "/"

	pathFilename: (path) ->
		path = path.split "/"
		path[path.length - 1] or ""

	pathBasename: (path) ->
		name = @pathFilename(path).split(".")
		if name.length > 1 then name[...-1].join(".") else name[0]

	pathExtname: (path, keepDot) ->
		path = @pathFilename(path).split(".")[1..]
		ext = path[path.length - 1] or ""
		if keepDot then (ext and "." or "") + ext else ext

	pathJoin: (...paths) ->
		paths2 = []
		for path from paths
			path += ""
			paths2 = [] if path[0] is "/"
			paths2.push path
		@pathNormalize paths2.join "/"

	pathNormalize: (path, isSubPath) ->
		paths = (path + "").split /\/+/
		paths = paths.filter (v) => not /^(\.|\s+)?$/.test v
		while (index = paths.findIndex (v) => v is "..") >= 0
			if index then paths.splice index - 1, 2
			else paths.shift()
		path = paths.join "/"
		path = "/" + path unless isSubPath or path[0] is "/"
		path.replace /(?<=.)\/+$/, ""

	pathInPath: (path, parentPath) ->
		path = @pathNormalize(path) + "/"
		parentPath = @pathNormalize(parentPath) + "/"
		path.startsWith parentPath

	installApp: (files, {createShortcut} = {}) ->
		new Promise (resolve) =>
			if file = files.find (v) => v.endsWith "/app.yml"
				data = jsyaml.safeLoad await fetch2 file
				name = @validateFilename data.name
				unless _.isError name
					path = @pathDirname file
					appl =
						name: data.name
						path: path
						icon: data.icon or "application"
						title: data.title
						exts: data.exts or []
						x: data.x
						y: data.y
						width: data.width
						height: data.height
						maxWidth: data.maxWidth
						maxHeight: data.maxHeight
						minimizable: data.minimizable ? yes
						maximizable: data.maximizable ? yes
						resizable: data.resizable ? yes
						fullscreenable: data.fullscreenable ? yes
						picker: data.picker
						isSystem: data.isSystem
						perms:
							paths: [path]
					for file from files
						res = await fetch file
						if res.status is 200
							text = await res.text()
							await @writeFile file, text
					@addApplExts appl, appl.exts
					if createShortcut
						@createShortcut "#{path}/app.yml", "#{@desktop.path}/#{appl.name}.lnk"
					@appls[path] = appl
					@setState {}
			resolve()
			return

	addApplExts: (appl, exts) ->
		for ext from exts
			@exts[ext] ?= appls: []
			{appls} = @exts[ext]
			appls.splice appls.indexOf(appl), 1 if appl in appls
			appls.unshift appl
		return

	runTask: (filePath, params, env) ->
		file = await @resolveShortcut @pathNormalize(filePath), yes
		if file.isFile and file.name is "app.yml"
			new Promise (resolve) =>
				tid = uuidv4()
				pid = +_.uniqueId()
				path = @pathDirname filePath
				code = await @readFile "#{path}/index.cjsx"
				code = code.replace /\n/g, "\n\t\t"
				css = cssIframe
				try css += await @readFile "#{path}/index.styl"
				css = stylus.render css
				appl = @appls[path]
				env = _.merge
					entries: []
					appl
					env
				env.entries = await Promise.all env.entries.map (entry) =>
					if entry.isFile and entry.name.endsWith ".lnk"
						entry = await @resolveShortcut entry.fullPath, yes
					@cloneEntry entry
				task =
					tid: tid
					pid: pid
					appl: appl
					env: env
					code: code
					params: params ? {}
					win: null
					order: pid
					resolve: resolve
				code = codeIframe
					.replace /\{\{([=@]?)([\w.]+)\}\}/g, (s, s1, s2) =>
						switch s1
							when "=" then eval s2
							when "@" then eval "this.#{s2}"
							else _.get task, s2
					.replace /^|\n/g, (s) => s + "\t"
				code = coffee.compile "window.onload = ->\n#{code}\n\treturn", bare: yes
				{code} = Babel.transform code,
					presets: ["react"]
					plugins: ["syntax-object-rest-spread"]
				task.code = docIframe.replace /\{\{(code|css)\}\}/g, (s, s1) =>
					if s1 is "code" then code else css
				@tasks[tid] = task
				@setState {}
				return

	focusTask: (tid) ->
		task = @tasks[tid]
		unless task.env.isDesktop or @taskFocused is task
			task.order = +_.uniqueId()
			@taskFocused = task
			@setState {}
		return

	blurTask: (tid) ->
		task = @tasks[tid]
		if @taskFocused is task or not tid
			task.order = 0 if tid
			tasks = _.filter @tasks, (v) =>
				not v.win?.isMinimized and not v.env.isDesktop
			taskMaxOrder = _.maxBy(tasks, "order")
			@taskFocused = taskMaxOrder
			@setState {}
		return

	killTask: (pid) ->
		if task = _.find @tasks, {pid}
			task.win.close()
			yes

	addClipboard: (data) ->
		data += ""
		if data
			@clipboard.unshift data
			@clipboard.pop() if @clipboard.length > 16
		return

	getClipboard: ->
		@clipboard[0]

	jsxToMenu: (jsx) ->
		return jsx if null
		if Array.isArray jsx
			jsx.map @jsxToMenu
		else if React.isValidElement jsx
			menuItem = {...jsx.props}
			switch jsx.type.displayName
				when "Blueprint3.MenuDivider"
					menuItem.divider = yes
				else
					if submenu = menuItem.children
						delete menuItem.children
						menuItem.submenu = @jsxToMenu submenu
			menuItem
		else jsx

	menuToJsx: (menu, resolve, clickCb) ->
		if menu?.length
			hasItem = no
			key = 0
			menuEl = React.createElement Menu, null, []
			do handle = (menu, menuEl) =>
				hasSubItem = no
				for props from menu
					props = props and {...props} or divider: yes
					props.key = key++
					if props.divider
						delete props.divider
						for k, prop of props
							props[k] = prop() if typeof prop is "function"
						menuItemEl = React.createElement MenuDivider, props
						menuEl.props.children.push menuItemEl
					else
						props.shown = props.shown() if typeof props.shown is "function"
						if "shown" not of props or props.shown
							delete props.shown
							hasItem = yes
							hasSubItem = yes
							for k, prop of props
								props[k] = prop() if typeof prop is "function" and k isnt "onClick"
							if submenu = props.submenu
								props.tabIndex = ""
							delete props.submenu
							props.icon ?= "blank"
							if typeof props.onClick is "string"
								((uuid) =>
									props.onClick = =>
										resolve uuid
										return
								) props.onClick
							else if clickCb
								((onClick) =>
									props.onClick = =>
										clickCb()
										onClick?()
										return
								) props.onClick
							menuItemEl = React.createElement MenuItem, props, submenu and [] or null
							menuEl.props.children.push menuItemEl
							if submenu
								unless handle submenu, menuItemEl
									_.pull menuEl.props.children, menuItemEl
				hasSubItem
			hasItem and menuEl or null
		else null

	showContextMenu: (menu) ->
		new Promise (resolve) =>
			if (React.isValidElement menu) or (menu = @menuToJsx menu, resolve)
				ContextMenu.show menu
			return

	alert: (message, isSafeHtml) ->
		@runTask "/C/programs/Popup/app.yml",
			kind: "alert"
			message: message
			isSafeHtml: isSafeHtml

	confirm: (message, isSafeHtml) ->
		@runTask "/C/programs/Popup/app.yml",
			kind: "confirm"
			message: message
			isSafeHtml: isSafeHtml

	prompt: (message, inputProps, isSafeHtml) ->
		@runTask "/C/programs/Popup/app.yml",
			kind: "prompt"
			message: message
			inputProps: inputProps
			isSafeHtml: isSafeHtml

	popup: (kind, params) ->
		@runTask "/C/programs/Popup/app.yml", {...params, kind}

	pickEntries: (params) ->
		@runTask "/C/programs/FileManager/app.yml", params, picker: yes

	addEntriesToApplPermPaths: (appl, entries) ->
		if entries
			for entry from _.castArray entries
				path = entry.fullPath
				unless appl.perms.paths.some (v) => @pathInPath path, v
					appl.perms.paths = appl.perms.paths
						.filter (v) => not @pathInPath v, path
						.concat path
					@setState {}
		return

	setCusrorTouchmove: (cursor) ->
		@cursorTouchmove = cursor
		@setState {}
		return

	dispatchMouseDownUpApp: (x, y, type, tid) ->
		task = @tasks[tid]
		if task.win
			document.dispatchEvent new MouseEvent type
			task.win.onMouseDownWin() if type is "mousedown"
			rect = task.win.refs.iframe.getBoundingClientRect()
			@mouse.x = rect.x + x
			@mouse.y = rect.y + y
		return

	classApp: ->
		classNames
			"App__app--fullscreen": @taskFocused?.win?.isFullscreen is yes
			"App__app--fullscreenTaskbar": @taskFocused?.win?.isFullscreen is "taskbar"

	classMain: ->
		classNames
			"reverse": @taskbar.placement is "top"

	styleTaskbar: ->
		height: @taskbar.height

	styleTouchmove: ->
		cursor: @cursorTouchmove

	onContextMenuTaskBtns: (event) ->
		if event.target is event.currentTarget
			@showContextMenu [
				text: "Vị trí"
				submenu: [
					text: "Trên"
					onClick: =>
						@taskbar.placement = "top"
						@desktop.y = @taskbar.height
						@setState {}
						return
				,
					text: "Dưới"
					onClick: =>
						@taskbar.placement = "bottom"
						@desktop.y = 0
						@setState {}
						return
				]
			]
		return

	handleClickTaskBtn: (task) ->
		if @taskFocused is task
			task.win.minimize()
		else
			@focusTask task.tid
			if task.win.isMinimized
				task.win.minimize no
		return

	onMouseMove: (event) ->
		@mouse.x = event.pageX - @desktop.x
		@mouse.y = event.pageY - @desktop.y
		return

	touchmoveCallback: (type) ->
		if type is 4
			@setCusrorTouchmove ""
		return

	message: (task, name, val) ->
		task = @tasks[task] unless _.isPlainObject task
		task?.win?.refs.iframe.contentWindow.postMessage
			type: "sysIfr"
			name: name
			val: val
			"*"
		return

	listen: (event) ->
		((name, val, mid, tid, task) =>
			{name, val, mid, tid} = event.data
			if task = @tasks[tid]
				returnVal =
					switch name
						when "readFile"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else await @readFile path, val[1]

						when "writeFile", "appendFile"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else @cloneEntry await @[name] path, val[1]

						when "deleteFile", "deleteDir"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else await @[name] path

						when "createDir"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else @cloneEntry await @createDir path

						when "readDir"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else
								entries = await @readDir path
								entries.map (entry) => @cloneEntry entry

						when "movePath", "copyPath"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else
								newPath = await task.win.requestPerm "paths", val[1]
								if _.isError newPath then newPath
								else @cloneEntry await @[name] path, newPath, val[2]

						when "existsPath"
							path = await task.win.requestPerm "paths", val[0]
							if _.isError path then path
							else await @existsPath path

						when "minimize", "maximize", "close", "fullscreen", "setTitle"
						, "alert", "confirm", "prompt", "popup"
							task.win[name] ...val

						when "getTitle"
							task.win.title

						when "pickEntries", "pickReadOnlyEntries"
							await task.win[name] val[0]

						when "saveFile"
							await task.win.saveFile val[0]

						when "addClipboard"
							await @addClipboard val[0]

						when "getClipboard"
							await @getClipboard()

						when "getParamsTask"
							task.params

						when "getEnvTask"
							entries: task.env.entries
							picker: task.env.picker
							isSystem: task.env.isSystem
							isDesktop: task.env.isDesktop

						when "sendContextMenu#{tid}"
							await @showContextMenu val[0]

						when "dispatchMouseDownUpApp#{tid}"
							@dispatchMouseDownUpApp val[0], val[1], val[2], tid
							undefined

						when "iframeDidMount#{tid}"
							task.win.iframeDidMount()
							undefined

						when "iframeDidResize#{tid}"
							task.win.iframeDidResize val[0], val[1]
							undefined
				task.win?.refs.iframe.contentWindow.postMessage
					type: "ifrSysIfr"
					val: returnVal
					mid: mid
					"*"
		)()
		return

	componentWillMount: ->
		window.ap = app = @
		return

	componentDidMount: ->
		setInterval =>
			@moment = moment()
			@setState {}
			return
		, 1000
		await fs.init
			type: window.PERSISTENT
			bytes: 1024 * 1024 * 100
		await Promise.all Paths.fs.map (path) =>
			filePath = "/#{path}"
			if path.endsWith "/app.yml"
				@installApp [filePath], createShortcut: yes
			else if path.endsWith "/"
				@createDir filePath[...-1]
			else @writeFile filePath, await fetch2 path, "arrayBuffer"
		paths = [
			"roms/FIFA 2007.gba"
			"roms/Grand Theft Auto Advance.gba"
			"roms/Megaman Zero 4.gba"
			"roms/Pokemon - Fire Red Version.gba"
			"roms/Super Street Fighter II Turbo - Revival.gba"
		]
		await Promise.all paths.map (path) =>
			filePath = "/A/files/#{path}"
			url = "https://cdn.jsdelivr.net/gh/tiencoffee/data/#{path}"
			@writeFile filePath, await fetch2 url, "arrayBuffer"
		await @setDesktopBackgroundPath @desktop.background.path
		window.addEventListener "message", @listen
		document.addEventListener "mousemove", @onMouseMove, yes
		Hammer.touchmoveCallback = @touchmoveCallback
		task = await @runTask "/C/programs/FileManager/app.yml",
			path: @desktop.path
			view: "icons"
		, isDesktop: yes
		task.win.fullscreen "taskbar"
		# @runTask "/C/programs/CodeEditor/app.yml", null,
		# 	entries: [
		# 		await @getEntry "/C/programs/FileManager/index.styl"
		# 		await @getEntry "/test.cjsx"
		# 	]
		# @runTask "/C/programs/FileIO/app.yml"
		@runTask "/C/programs/CodeEditor/app.yml"
		return

	render: ->
		<div className="full no-scroll #{@classApp()}">
			<div className="column full App__main #{@classMain()}">
				<div className="col relative z-2">
					<TransitionGroup>
						{_.map @tasks, (task) =>
							<CSSTransition
								key={task.pid}
								classNames="Win__win--transition"
								timeout={enter: 0, exit: 300}
							>
								<Win tid={task.tid}/>
							</CSSTransition>
						}
					</TransitionGroup>
				</div>
				<Navbar className="col-0 row nowrap z-2 App__taskbar" style={@styleTaskbar()}>
					<NavbarGroup className="col-0">
						<TaskbarHome/>
						<NavbarDivider/>
					</NavbarGroup>
					<NavbarGroup className="col App__taskBtns" onContextMenu={@onContextMenuTaskBtns}>
						{_.map @tasks, (task) =>
							if task.win?.isLoaded and not task.env.isDesktop
								<Popover
									key={task.pid}
									targetClassName="w-100"
									position="top"
									minimal
									isContextMenu
									content={
										<Menu className="App__taskBtnContextMenu">
											<MenuDivider title={task.win.title}/>
											<MenuItem intent="danger" text="Đóng" onClick={=> task.win.close()}/>
										</Menu>
									}
								>
									<Button
										className="w-100 text-ellipsis App__taskBtn App__taskBtn--#{task.tid}"
										active={task is @taskFocused}
										alignText="left"
										icon={task.win.icon}
										text={task.win.title or " "}
										onClick={=> @handleClickTaskBtn task}
									/>
								</Popover>
						}
					</NavbarGroup>
					<NavbarGroup className="col-0">
						<NavbarDivider/>
						<Popover
							minimal
							position="top"
							content={
								<div className="p-3 text-center">
									<h1>{@moment.format "HH:mm:ss"}</h1>
									<DatePicker defaultValue={@moment.toDate()}/>
								</div>
							}
						>
							<Button
								className="text-capitalize"
								minimal
								text={@moment.format "dd, L, HH:mm"}
							/>
						</Popover>
					</NavbarGroup>
				</Navbar>
			</div>
			<div className="full App__touchmove" style={@styleTouchmove()}></div>
		</div>

	renderHotkeys: ->
		<Hotkeys>
			<Hotkey
				global
				combo="h"
				label="Menu chính"
				preventDefault
				onKeyDown={=> TaskbarHome__btn?.click()}
			/>
		</Hotkeys>

HotkeysTarget App
