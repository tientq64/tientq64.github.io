class App extends React.Component
	constructor: (props) ->
		super props

		@state =
			system:
				display:
					brightness: 1
				sound:
					volume: .5
				battery:
					level: undefined
					charging: undefined
					env:
						manager: null
				storage:
					env:
						local: null
						drive: null
			personal:
				background:
					type: "image"
					imgSrc: "https://i.imgur.com/wOcQPsq.png"
					size: "cover"
				taskbar:
					location: "bottom"
			apps:
				app:
					list: []
					env:
						tasks: []
						dialogs: []

	set: (path, val, nextTick) ->
		@setState objectPathImmutable.set(@state, path, val), nextTick
		return

	update: (path, updater, nextTick) ->
		@setState objectPathImmutable.update(@state, path, updater), nextTick
		return

	push: (path, val, nextTick) ->
		@setState objectPathImmutable.push(@state, path, val), nextTick
		return

	del: (path, nextTick) ->
		@setState objectPathImmutable.del(@state, path), nextTick
		return

	assign: (path, obj, nextTick) ->
		@setState objectPathImmutable.assign(@state, path, val), nextTick
		return

	insert: (path, val, pos, nextTick) ->
		@setState objectPathImmutable.insert(@state, path, val, pos), nextTick
		return

	systemDisplaySetBrightness: (val) ->
		@set "system.display.brightness", val unless isNaN val = +val
		return

	systemSoundGetIconName: (volume = @state.system.sound.volume) ->
		if volume is 0
			"volume-off"
		else if volume < .5
			"volume-down"
		else
			"volume-up"

	systemSoundSetVolume: (val) ->
		@set "system.sound.volume", val unless isNaN val = +val
		return

	systemBatteryGetIcons8Name: (level) ->
		if level is undefined
			"battery-unknown"
		else if level is 0
			"empty-battery"
		else if level < 1 / 3
			"low-battery"
		else if level < 2 / 3
			"medium-battery"
		else if level < 1
			"high-battery"
		else
			"full-battery"

	systemStorageGetFile: (dir, path, opts, success, error) ->
		dir.getFile path, opts, success, error
		return

	systemStorageWriteFile: (file, data, dataType, success, error) ->
		file.createWriter(
			(writer) =>
				blob = new Blob [data], {dataType}
				writer.onwriteend = success
				writer.onerror = error
				writer.write blob
				return
			error
		)
		return

	systemStorageReadFile: (file, returnType = "text", success, error) ->
		file.file(
			(file) =>
				reader = new FileReader
				reader.onload = =>
					success reader.result
					return
				reader.onerror = (err) =>
					error err
					return
				reader["readAs" + returnType[0].toUpperCase() + returnType[1..]]?()
				return
			error
		)
		return

	systemStorageDeleteFile: (file, success, error) ->
		file.remove success, error
		return

	systemStorageListEntries: (dir, success, error) ->
		reader = dir.createReader()
		entries = []
		fetchEntries = =>
			reader.readEntries(
				(result) =>
					if result.length
						entries = [...entries, ...result]
						fetchEntries()
					else
						success entries.sort().reverse()
				error
			)
			return
		fetchEntries()
		return

	appsAppRun: (path, tasks) ->
		fetch "#{path}/index.cjsx"
			.then (res) => res.text()
			.then (text) =>
				console.log eval text
				return
		return

	componentDidMount: ->
		@appsAppRun "../../programs/FileManager"
		return

	componentWillMount: ->
		app = @

		navigator.getBattery?().then (battery) =>
			battery.onlevelchange = =>
				@set "system.battery.level", battery.level
				return
			battery.onchargingchange = =>
				@set "system.battery.charging", battery.charging
				return
			@set "system.battery.env.manager", battery
			battery.onlevelchange()
			battery.onchargingchange()

		navigator.webkitPersistentStorage?.requestQuota 1024 * 1024 * 4,
			(size) =>
				window.webkitRequestFileSystem? Window.PERSISTENT, size,
					(fs) =>
						@set "system.storage.env.local", fs
						return
					(err) =>
						return
				return
			(err) =>
				return
		return

	rootClass: ->
		backgroundImage: "url(#{@state.personal.background.imgSrc})"
		backgroundSize: @state.personal.background.size
		backgroundPosition: "50%"
		backgroundRepeat: "no-repeat"

	rootNavbarClass: ->
		[@state.personal.taskbar.location]: 0

	render: ->
		<div className="App" style={@rootClass()}>
			{@state.apps.app.env.tasks.map (task) => task.modal}
			{@state.apps.app.env.dialogs.map (dialog) => dialog}
			<Navbar
				className="App-taskbar bp3-dark"
				style={@rootNavbarClass()}
			>
				<NavbarGroup align="left">
					<TaskbarHome/>
					<NavbarDivider/>
				</NavbarGroup>
				<NavbarGroup align="right">
					<NavbarDivider/>
					<ButtonGroup>
						<TaskbarSound/>
						<TaskbarBattery/>
						<TaskbarDatetime/>
						<TaskbarAction/>
					</ButtonGroup>
				</NavbarGroup>
			</Navbar>
			<div
				className="App-brightness"
				style={opacity: 1 - @state.system.display.brightness}
			></div>
		</div>
