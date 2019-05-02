class App extends Reactive
	constructor: (props) ->
		super props

		@state =
			loaded: no
			brightness: 1
			nightLight: no
			orient: 0
			volume: .5
			battery: 0
			pcName: "My PC"
			ram: 0
			osName: "Ant"
			osVersion: "1.00"
			bluetooth: null
			dataUsageWifi: 0
			backgroundType: "picture"
			backgroundPath: ""
			backgroundFit: "fill"
			backgroundColor: "#edede6"
			darkTheme: no
			fonts: []
			taskbarLock: no
			taskbarAutoHide: no
			taskbarSmall: yes
			taskbarUsePeek: no
			taskbarCombineButtons: no
			taskbarLocation: "bottom"
			taskbarHeight: 36
			acctName: "Anonymous"
			acctPassword: ""
			acctPIN: ""
			lang: "vi"
			langs: ["vi", "en"]
			country: "vn"
			speechLang: "vi"
			speechSpeed: 1
			moment: new moment
			taskPid: 0
			apps: []

		@fs = null
		@battery = null
		@tasks = {}
		@mx = 0
		@my = 0
		@fileNameValidate =
			pattern: /^[^\\//:*?">|<]{1,255}$/
			minLength: 1
			maxLength: 255
		@pathValidate =
			pattern: /^[^\\:*?">|<]{1,}$/
			minLength: 1

	getNightLight: ->
		@state.nightLight

	setNightLight: (val = not @state.nightLight) ->
		val = !!val
		@setState nightLight: val
		val

	getBrightness: ->
		@state.brightness

	setBrightness: (val) ->
		val = _.round val, 2
		unless isNaN val
			@setState brightness: val
			val

	getVolume: ->
		@state.volume

	setVolume: (val) ->
		val = _.round val, 2
		unless isNaN val
			@setState volume: val
			val

	getBattery: ->
		@state.battery

	batteryInit: ->
		new Promise (resolve, reject) =>
			try
				@battery = await navigator.getBattery()
				@battery.onlevelchange = (event) =>
					@setState battery: event.target.level
					return
				@setState battery: @battery.level, resolve
			catch err
				reject err
			return

	getDarkTheme: ->
		@state.darkTheme

	setDarkTheme: (val = not @state.darkTheme) ->
		val = !!val
		@setState darkTheme: val
		val

	getDesktopTop: ->
		if @getTaskbarLocation() is "top"
			@getTaskbarHeight()
		else 0

	getDesktopHeight: ->
		innerHeight - @getTaskbarHeight()

	getDesktopBottom: ->
		if @getTaskbarLocation() is "bottom"
			@getDesktopHeight()
		else innerHeight

	getTaskbarLocation: ->
		@state.taskbarLocation

	setTaskbarLocation: (val) ->
		if val in ["top", "bottom"]
			@setState taskbarLocation: val
			val

	getTaskbarHeight: ->
		@state.taskbarHeight

	setTaskbarHeight: (val) ->
		val = +val
		unless isNaN val
			@setState taskbarHeight: val
			val

	getLang: ->
		@state.lang

	setLang: (val) ->
		if @state.langs.includes val
			@setState lang: val
			val

	fsPath: (...paths) ->
		"/" + paths.join("/").replace /^[\s\/]+|(\/)\/+|[\s\/]+$/g, "$1"

	fsPathSplit: (path) ->
		path.replace(/^\//, "").split "/"

	fsPathSafe: (path) ->
		path = @fsPath path
		path.replace(/^\.{2,}$|^\.{2,}\/|\/\.{2,}$|\/\.{2,}(\/)/g, "$1") or "/"

	fsEntry: (path, {entry = @fs, flag = "", mode, fileObj = yes} = {}) ->
		return path unless typeof path is "string"
		new Promise (resolve, reject) =>
			path = @fsPath path
			recursive = not flag.includes "1"
			flag =
				create: flag.includes "+"
				exclusive: flag.includes "x"
			nodes = @fsPathSplit path
			i = 0
			handle = (entry) =>
				node = nodes[i++]
				if i is nodes.length
					if mode is 2
						entry.getDirectory node, flag, resolve, reject
					else
						entry.getFile node, flag, (file) =>
							file.fileObj = await @fsFileObj file if fileObj
							resolve file
							return
						, (err) =>
							if mode is 1
								reject err
							else
								entry.getDirectory node, flag, resolve, reject
							return
				else
					entry.getDirectory node,
						create: if recursive then flag.create
						handle
						reject
				return
			handle entry
			return

	fsFile: (path, opts) ->
		return path unless typeof path is "string"
		new Promise (resolve, reject) =>
			try
				resolve await @fsEntry path, {...opts, mode: 1}
			catch err
				reject err
			return

	fsDir: (path, opts) ->
		return path unless typeof path is "string"
		new Promise (resolve, reject) =>
			try
				resolve await @fsEntry path, {...opts, mode: 2}
			catch err
				reject err
			return

	fsReadFile: (file, {entry = @fs, type = "text"} = {}) ->
		new Promise (resolve, reject) =>
			try
				file = await @fsFile file, {entry} if typeof file is "string"
				fileObj = file.fileObj or await @fsFileObj file
				reader = new FileReader
				reader.onloadend = =>
					resolve reader.result
					return
				reader.onerror = reject
				reader["readAs" + _.upperFirst type] fileObj
			catch err
				reject err
			return

	fsWriteFile: (file, data, {entry = @fs, flag, append, mime = "text/plain"} = {}) ->
		new Promise (resolve, reject) =>
			try
				file = await @fsFile file, {entry, flag} if typeof file is "string"
				blob =
					if data instanceof Blob then data
					else new Blob [data], type: mime
				handle = (writer) =>
					writer.onwrite = resolve
					writer.onerror = reject
					writer.write blob
				file.createWriter (writer) =>
					if append
						handle writer
					else
						writer.truncate 0
						file.createWriter handle
					return
			catch err
				reject err
			return

	fsMove: (entr, newDir, {newName} = {}) ->
		new Promise (resolve, reject) =>
			try
				entr = await @fsEntry entr if typeof file is "string"
				newDir = await @fsDir newDir if typeof newDir is "string"
				entr.moveTo newDir, newName, resolve, reject
			catch err
				reject err
			return

	fsCopy: (entr, newDir, {newName} = {}) ->
		new Promise (resolve, reject) =>
			try
				entr = await @fsEntry entr if typeof file is "string"
				newDir = await @fsDir newDir if typeof newDir is "string"
				entr.copyTo newDir, newName, resolve, reject
			catch err
				reject err
			return

	fsRemove: (entr, {entry} = {}) ->
		new Promise (resolve, reject) =>
			try
				entr = await @fsEntry entr, {entry} if typeof entr is "string"
				entr.remove resolve, reject
			catch err
				reject err
			return

	fsRemoveRecursive: (entr, {entry} = {}) ->
		new Promise (resolve, reject) =>
			try
				entr = await @fsEntry entr, {entry} if typeof entr is "string"
				entr.removeRecursively resolve, reject
			catch err
				reject err
			return

	fsReadDir: (dir, {entry, fileObj = yes} = {}) ->
		new Promise (resolve, reject) =>
			try
				dir = await @fsDir dir, {entry} if typeof dir is "string"
				reader = dir.createReader()
				reader.readEntries (entries) =>
					if fileObj
						for entr from entries
							entr.fileObj = await @fsFileObj entr if entr.isFile
					entries.sort (a, b) => a.isFile - b.isFile or a.name.localeCompare b.name
					resolve entries
					return
				, reject
			catch err
				reject err
			return

	fsFileObj: (entr) ->
		new Promise (resolve, reject) =>
			entr.file resolve, reject
			return

	fsParent: (entr) ->
		new Promise (resolve, reject) =>
			try
				entr = await @fsEntry entr if typeof entr is "string"
				entr.getParent resolve, reject
			catch err
				reject err
			return

	fsZipArchiveMeta: (entries, {name, path} = {}) ->
		new Promise (resolve, reject) =>
			try
				entries = [...entries]
				path ?= (await app.fsParent entries[0]).fullPath
				if entries.length is 1
					rootEntry = entries[0]
					entries.unshift rootEntry
					replacePath = rootEntry.fullPath.replace /\/[^\/]+$/, ""
				else
					rootEntry = await app.fsParent entries[0]
					replacePath = rootEntry.fullPath
				replacePath += "/" unless replacePath.endsWith "/"
				name ?= rootEntry.isDirectory and
					rootEntry.name or
					rootEntry.name.replace /\.[^.]+$/, ""
				name = name + ".zip" unless name.endsWith ".zip"
				resolve {entries, name, path, replacePath}
			catch err
				reject err
			return

	fsZipArchive: (entries, {name, path, zipArchiveOpts, deleteFilesAfterArchive, onUpdate} = {}) ->
		new Promise (resolve, reject) =>
			try
				{entries, name, path, replacePath} = await app.fsZipArchiveMeta entries, {name, path}
				jsZip = new JSZip
				handle = (entries) =>
					for entry from entries
						if entry.isFile
							relPath = entry.fullPath.replace replacePath, ""
							jsZip.file relPath,
								await app.fsReadFile entry, type: "binaryString"
								binary: yes
						else
							await handle await app.fsReadDir entry, fileObj: no
				await handle entries
				zipArchiveOpts = _.merge
					type: "blob"
					compression: "DEFLATE"
					compressionOptions: level: 5
					zipArchiveOpts
				zipArchiveOpts = {
					type: "blob"
					...zipArchiveOpts
				}
				data = await jsZip.generateAsync zipArchiveOpts, onUpdate
				resolve {name, path, data, deleteFilesAfterArchive}
			catch err
				reject err
			return

	fsZipArchiveWrite: ({path, name, data} = {}) ->
		new Promise (resolve, reject) =>
			try
				await app.fsWriteFile @fsPath(path, name),
					data
					flag: "+1"
				resolve()
			catch err
				reject err
			return

	fsZipExtract: (file, path, {zipExtractOpts, deleteFilesAfterExtract} = {}) ->
		new Promise (resolve, reject) =>
			try
				data = await @fsReadFile file, type: "binaryString"
				jsZip = new JSZip
				zip = await jsZip.loadAsync data, zipExtractOpts
				resolve {file, path, zip, deleteFilesAfterExtract}
			catch err
				reject err
			return

	fsZipExtractWrite: ({file, path, zip, deleteFilesAfterExtract} = {}) ->
		new Promise (resolve, reject) =>
			try
				for zipPath, zipObj of zip.files
					unless zipObj.dir
						await @fsWriteFile @fsPath(path, zipPath),
							await zipObj.async "blob"
							flag: "+"
				resolve()
			catch err
				reject err
			return

	fsInit: ->
		new Promise (resolve, reject) =>
			navigator.webkitPersistentStorage.requestQuota 1024*1024*100,
				(size) =>
					webkitRequestFileSystem PERSISTENT, size,
						({root: @fs}) =>
							resolve()
							return
						reject
					return
				reject
			return

	taskRun: (path, opts) ->
		new Promise (resolve, reject) =>
			try
				o = {}
				path = @fsPath path
				opts ?= {}
				opts.params ?= {}
				o.pid = +_.uniqueId()
				o.ap = _.find @state.apps, {path}
				o.sill = jsyaml.safeLoad await @fsReadFile path + "/index.sill"
				o.sill = {...o.sill, ...opts.sill}
				o.task =
					pid: o.pid
					path: path
					sill: o.sill
					ap: o.ap
					params: opts.params
					closeValue: undefined
					dialog: null
					resolve: resolve
				try
					o.styl = await @fsReadFile path + "/index.styl"
					o.styl = scopeCSS stylus.render(o.styl), ".scoped-css-" + o.pid
				Comp = await @fsReadFile path + "/index.cjsx"
				Comp = Comp.replace /(^|\n\t?(?!\n))/g, "$1\t\t"
				if o.ap.isSystem
					o.code = cache.system
						.replace "~~pid~~", o.pid
						.replace "\t\t~~component~~\n", Comp
				else
					o.code = cache.lib + cache.comp + cache.boot
					o.code = cache.user
						.replace "~~pid~~", o.pid
						.replace "~~script~~\n", o.code
						.replace "\t\t~~component~~\n", Comp
				o.code = Babel.transform(
					coffee.compile o.code, bare: yes
					presets: ["react"]
					plugins: ["syntax-object-rest-spread"]
				).code
				if o.ap.isSystem
					Comp = eval o.code
					o.task.Comp = Comp
					o.task.css = o.styl
				else
					o.code = """
						<link rel="stylesheet" href="https://unpkg.com/normalize.css@8.0.1/normalize.css">
						<link rel="stylesheet" href="https://unpkg.com/@blueprintjs/icons@3.3.0/lib/css/blueprint-icons.css">
						<link rel="stylesheet" href="https://unpkg.com/@blueprintjs/core@3.4.0/lib/css/blueprint.css">
						<link rel="stylesheet" href="https://unpkg.com/@blueprintjs/select@3.3.0/lib/css/blueprint-select.css">
						<link rel="stylesheet" href="https://unpkg.com/@blueprintjs/datetime@3.4.0/lib/css/blueprint-datetime.css">
						<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css">
						<script>delete module</script>
						<script src="https://cdn.jsdelivr.net/gh/tiencoffee/libs/tslib.min.js"></script>
						<script src="https://unpkg.com/classnames@2.2.6/index.js"></script>
						<script src="https://unpkg.com/dom4@2.1.3/build/dom4.js"></script>
						<script src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
						<script src="https://unpkg.com/react-dom@16.8.6/umd/react-dom.development.js"></script>
						<script src="https://unpkg.com/react-transition-group@4.0.0/dist/react-transition-group.min.js"></script>
						<script src="https://unpkg.com/popper.js@1.15.0/dist/umd/popper.min.js"></script>
						<script src="https://unpkg.com/react-popper@1.3.3/dist/index.umd.min.js"></script>
						<script src="https://unpkg.com/react-day-picker@7.2.4/lib/daypicker.min.js"></script>
						<script src="https://unpkg.com/@blueprintjs/icons@3.3.0/dist/icons.bundle.js"></script>
						<script src="libs/blueprint-core.js"></script>
						<script src="https://unpkg.com/@blueprintjs/select@3.3.0/dist/select.bundle.js"></script>
						<script src="https://unpkg.com/@blueprintjs/datetime@3.4.0/dist/datetime.bundle.js"></script>
						<script src="https://unpkg.com/lodash@4.17.11/lodash.min.js"></script>
						<style>
							#{cache.css}
							#{o.styl}
						</style>
						<script>
							window.onload = function() {
								#{o.code}
							}
						</script>
						<div id="app" class="scoped-css-#{o.pid}"></div>
					"""
					o.task.code = o.code
				@tasks[o.pid] = o.task
				@setState taskPid: o.pid
			catch err
				reject err
			return

	taskKill: (pid) ->
		if @tasks[pid]
			order = @tasks[@state.taskPid].dialog.state.order
			delete @tasks[pid]
			if _.isEmpty @tasks
				@setState taskPid: 0
			else
				@taskFocus _.maxBy(Object.values(@tasks), "dialog.state.order").pid, order
			yes

	taskFocus: (pid, order) ->
		if @state.taskPid
			task1 = @tasks[pid]
			order ?= @tasks[@state.taskPid].dialog.state.order
			for k, task of @tasks
				unless task.pid is pid
					if task.dialog.state.order > task1.dialog.state.order
						task.dialog.setState order: task.dialog.state.order - 1
			task1.dialog.setState {order}
		@setState taskPid: pid, @update
		yes

	taskBlur: (pid) ->
		if @state.taskPid is pid
			tasksArr = Object.values(@tasks).filter (task) =>
				task.pid isnt pid and
				not task.dialog.state.isMinimize
			task1 = @tasks[pid]
			if task2 = _.maxBy tasksArr, "dialog.state.order"
				order = task2.dialog.state.order
				task2.dialog.setState order: task1.dialog.state.order
				task1.dialog.setState {order}
				@setState taskPid: task2.pid
			returnValue = yes
		app.forceUpdate()
		returnValue

	appInstall: (url, dir, {flag, isSystem}) ->
		new Promise (resolve, reject) =>
			try
				dir = await @fsDir dir, {flag} if typeof dir is "string"
				path = @fsPath dir.fullPath
				res = await fetch url + "/index.sill"
				if res.ok and res.status is 200
					sill = await res.text()
					await @fsWriteFile "index.sill", sill, {entry: dir, flag}
				else throw new Error
				res = await fetch url + "/index.cjsx"
				if res.ok and res.status is 200
					cjsx = await res.text()
					await @fsWriteFile "index.cjsx", cjsx, {entry: dir, flag}
				else throw new Error
				res = await fetch url + "/index.styl"
				if res.ok and res.status is 200
					styl = await res.text()
					await @fsWriteFile "index.styl", styl, {entry: dir, flag}
				sill = jsyaml.safeLoad sill
				ap =
					name: sill.name
					path: path
					url: url
					isSystem: isSystem
				@setState apps: [...@state.apps, ap], =>
					resolve app
					return
			catch err
				reject err
			return

	appUninstall: (path) ->
		new Promise (resolve, reject) =>
			try
				path = @fsPath path
				await @fsRemoveRecursive path
				@setState apps: @state.apps.filter((ap) => ap.path isnt path), =>
					resolve()
					return
			catch err
				reject err
			return

	appInit: ->
		new Promise (resolve, reject) =>
			try
				programs = "
					Calendar
					CommandLine
					FileDetails
					FileManager
					Popup
					Settings
					ZipArchiveOptions
					ZipExtractOptions
				"
				for program from programs.split " "
					path = "C/programs/system/" + program
					await @appInstall path, path, flag: "+", isSystem: yes
				programs ="
					Test
				"
				for program from programs.split " "
					path = "C/programs/user/" + program
					await @appInstall path, path, flag: "+"
				resolve()
			catch err
				reject err
			return

	alert: (message) ->
		@taskRun "C/programs/system/Popup",
			params:
				popupType: "alert"
				message: message

	confirm: (message) ->
		@taskRun "C/programs/system/Popup",
			params:
				popupType: "confirm"
				message: message

	prompt: (message, defaultValue, opts) ->
		@taskRun "C/programs/system/Popup",
			params: {
				required: yes
				...opts
				popupType: "prompt"
				message: message
				defaultValue: defaultValue
			}

	pickPath: (pickerType) ->
		title = {
			file: "tập tin"
			dir: "thư mục"
		}[pickerType] or "tập tin hoặc thư mục"
		await @taskRun "C/programs/system/FileManager",
			params: {pickerType}
			sill:
				title: "Chọn một #{title}"
				width: 800
				height: 600
				picker: yes

	update: ->
		@forceUpdate()
		return

	classApp: -> classNames
		"bp3-dark": @state.darkTheme

	styleDesktop: ->
		top: @getDesktopTop()
		height: @getDesktopHeight()

	styleBrightness: ->
		opacity: .5 - @getBrightness() * .5

	componentDidUpdate: ->
		for k, task of @tasks
			task.appx?.forceUpdate()
		return

	componentDidMount: ->
		await @fsInit()
		await @batteryInit()
		await @appInit()
		setInterval =>
			@setState moment: new moment
			return
		, 1000
		document.addEventListener "mousedown", (event) =>
			@mx = event.clientX
			@my = event.clientY
			selection = getSelection()
			selection.empty() if selection.focusNode?.nodeType is 3
			return
		@setState loaded: yes
		# await @taskRun "C/programs/system/Calendar"
		# await @taskRun "C/programs/system/CommandLine"
		await @taskRun "C/programs/system/FileManager"
		# await @taskRun "C/programs/user/Test"
		# await @taskRun "C/programs/system/Settings"
		# console.log await @prompt "Hello", "asd"
		# console.log await @pickPath "file"
		return

	render: ->
		<div className={@classApp()}>
			<div className="full z-0">
				{if @state.loaded
					<div>
						<Taskbar/>
						<div
							className="desktop"
							style={@styleDesktop()}
						>
							<p>{@state.taskPid}</p>
							<p>{@getLang()}</p>
							<TransitionGroup>
								{_.map @tasks, (task) =>
									<CSSTransition
										key={task.pid}
										classNames="dialog"
										timeout={enter: 0, exit: 300}
									>
										<Dialog
											pid={task.pid}
											path={task.path}
											sill={task.sill}
											ap={task.ap}
											Comp={task.Comp}
											code={task.code}
											css={task.css}
											resolve={task.resolve}
											dialogRef={(dialog) => @tasks[task.pid].dialog = dialog; return}
										/>
									</CSSTransition>
								}
							</TransitionGroup>
						</div>
					</div>
				else
					<p>Loading...</p>
				}
			</div>
			{ReactDOM.createPortal(
				<div className="top-layer full z-3">
					<div
						className="night-light full"
						data-night-light={@getNightLight()}
					/>
					<div
						className="brightness full"
						style={@styleBrightness()}
					/>
				</div>
				document.body
			)}
		</div>
