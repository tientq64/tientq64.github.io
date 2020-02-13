class Win extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		task = app.tasks[props.tid]
		minWidth = 160
		minHeight = 64
		maxWidth = task.env.maxWidth ? app.desktop.width
		maxWidth = _.clamp maxWidth, minWidth, app.desktop.width
		maxHeight = task.env.maxHeight ? app.desktop.height
		maxHeight = _.clamp maxHeight, minHeight, app.desktop.height
		{width = 640, height = 480} = task.env
		width ?= 640
		width = _.clamp width + 2, minWidth, maxWidth
		height = minHeight if height is "auto"
		height = _.clamp height + 38, minHeight, maxHeight
		x = task.env.x ? app.desktop.width // 2 - width // 2
		y = task.env.y ? app.desktop.height // 2 - height // 2

		@task = task
		@title = task.env.title ? task.appl.name
		@icon = task.env.icon
		@x = x
		@y = y
		@width = width
		@height = height
		@x2 = 0
		@y2 = 0
		@width2 = 0
		@height2 = 0
		@minWidth = minWidth
		@minHeight = minHeight
		@maxWidth = maxWidth
		@maxHeight = maxHeight
		@isMinimized = 0
		@isMaximized = 0
		@isFullscreen = no
		@isLoaded = no
		@permRequests = []
		@resizeEdge = ""
		@hammerTitle = null
		@hammerResizer = null
		@animMinimize = null
		@popperUpdatePermRequest = null
		@sandbox = "allow-forms allow-orientation-lock allow-pointer-lock allow-presentation allow-scripts"
		@isAutoSize = task.env.width is "auto" or task.env.height is "auto"

		@sandbox += " allow-same-origin" if task.env.isSystem

	setTitle: (title) ->
		@title = title
		app.setState {}
		return

	minimize: (val) ->
		if @task.env.minimizable
			@isMinimized =
				if arguments.length then Boolean val
				else not @isMinimized
			if @animMinimize
				@animMinimize.reverse()
			else
				winRect =
					if @isMinimized then @refs.win.getBoundingClientRect()
					else {@x, @y, @width, @height}
				winCss =
					left: winRect.x + "px"
					top: winRect.y + "px"
					width: winRect.width + "px"
					height: winRect.height + "px"
					minWidth: @minWidth + "px"
					minHeight: @minHeight + "px"
					visibility: "visible"
				taskBtnRect = document
					.querySelector ".App__taskBtn--#{@task.tid}"
					.getBoundingClientRect()
				taskBtnCss =
					left: taskBtnRect.x + "px"
					top: taskBtnRect.y + "px"
					width: taskBtnRect.width + "px"
					height: taskBtnRect.height + "px"
					minWidth: 0
					minHeight: 0
					visibility: "hidden"
				unless @isMinimized
					[winCss, taskBtnCss] = [taskBtnCss, winCss]
				@animMinimize = @refs.win.animate [winCss, taskBtnCss],
					duration: 200
					easing: "ease"
					fill: "forwards"
				@animMinimize.onfinish = =>
					if @isMinimized
						app.blurTask @task.tid
					return
			app.focusTask @task.tid unless @isMinimized
			@setState {}
		return

	maximize: (val) ->
		if @task.env.maximizable
			@isMaximized =
				if arguments.length then Boolean val
				else not @isMaximized
			@animMinimize = null
			@setState {}
		return

	fullscreenable: ->
		@task.env.fullscreenable and @task.env.resizable

	fullscreen: (val) ->
		if @fullscreenable()
			@isFullscreen =
				if arguments.length
					if typeof val is "string" then val
					else Boolean val
				else not @isFullscreen
			@animMinimize = null
			@setState {}
			app.setState {}
		return

	close: (resolveVal) ->
		@task.resolve? resolveVal
		delete app.tasks[@task.tid]
		app.setState {}
		app.blurTask null
		return

	requestPerm: (name, ...val) ->
		switch name
			when "paths"
				[path] = val
				path =
					if path[0] is "/" then app.pathNormalize path
					else app.pathJoin @task.appl.path, path
				if @task.appl.perms.paths.some (perm) => app.pathInPath path, perm
					path
				else Error "Đường dẫn không được phép"
			when "file"
				if @task.appl.perms[name]?
					@task.appl.perms[name]
				else
					@promptPermRequest name, "
						Cho phép ứng dụng truy cập các tệp tin trong thư mục của ứng dụng này?
						Đường dẫn: #{@task.appl.path}
					", (val) =>
						@task.appl.perms[name] = val
						return

	promptPermRequest: (name, message, cb) ->
		new Promise (resolve) =>
			if (index = _.findIndex @permRequests, {name}) >= 0
				@permRequests[index].resolves.push resolve
			else
				permRequest =
					name: name
					message: message
					resolves: [resolve]
					cb: (val) =>
						cb val
						app.setState {}
						resolve val for resolve from @permRequests[0].resolves
						@permRequests.shift()
						return
				@permRequests.push permRequest
			@setState {}
			return

	alert: (message, isSafeHtml) ->
		app.alert message, isSafeHtml

	confirm: (message, isSafeHtml) ->
		app.confirm message, isSafeHtml

	prompt: (message, inputProps, isSafeHtml) ->
		app.prompt message, inputProps, isSafeHtml

	popup: (kind, params) ->
		app.popup kind, params

	pickEntries: (opts = {}) ->
		entries = await app.pickEntries
			kind: opts.kind
			multiple: opts.multiple
		if entries
			app.addEntriesToApplPermPaths @task.appl, entries
		entries

	pickReadOnlyEntries: (opts = {}) ->
		app.pickEntries
			kind: opts.kind
			multiple: opts.multiple

	saveFile: (opts = {}) ->
		app.saveFile
			name: opts.name
			data: opts.data
			applPath: @task.appl.path

	iframeDidMount: ->
		@isLoaded = yes
		ap.focusTask @task.tid
		@setState {}
		return

	iframeDidResize: (width, height) ->
		if @isAutoSize
			height = _.clamp height + 38, @minHeight, @maxHeight
			@y -= (height - @height) // 2
			@y = _.clamp @y, 0, app.desktop.height - height
			@height = height
			@animMinimize = null
			@setState {}
		return

	classWin: ->
		classNames
			"Win__win--iframeMounted": @isLoaded
			"Win__win--maximize": @isMaximized is yes
			"Win__win--unmaximize": @isMaximized is no
			"Win__win--fullscreen": @isFullscreen is yes
			"Win__win--fullscreenTaskbar": @isFullscreen is "taskbar"
			"Win__win--isDesktop": @task.env.isDesktop

	classResizer: ->
		classNames
			"hidden": @isMinimized or @isMaximized or @isFullscreen or not @task.env.resizable

	styleWin: ->
		left: @x + @x2
		top: @y + @y2
		width: @width + @width2
		height: @height + @height2
		minWidth: @minWidth
		minHeight: @minHeight
		maxWidth: @maxWidth
		maxHeight: @maxHeight
		zIndex: @task.order
		background: Colors[app.taskFocused is @task and "LIGHT_GRAY4" or "WHITE"]

	contentMenuHeader: ->
		<Menu>
			{if @task.env.minimizable
				<MenuItem
					icon="minus"
					text="Thu nhỏ"
					onClick={=> @minimize()}
				/>
			}
			{if @task.env.maximizable
				<MenuItem
					icon="plus"
					text="Phóng to"
					onClick={=> @maximize()}
				/>
			}
			<MenuItem
				intent="danger"
				icon="cross"
				text="Đóng"
				onClick={=> @close()}
			/>
		</Menu>

	onMouseDownWin: ->
		app.focusTask @task.tid
		return

	onAnimationTransitionEndWin: ->
		@popperUpdatePermRequest?()
		return

	onPanTitle: (event) ->
		if @isMaximized
			@maximize no
			@x = _.clamp(app.mouse.x - @width // 2, 0, app.desktop.width - @width) - 1
			@y = - 1
		else
			if event.isFinal
				if @task.env.resizable
					if app.mouse.x <= 0 or app.mouse.x >= app.desktop.width-1
						@width = app.desktop.width // 2
						@height = app.desktop.height // (0 < app.mouse.y < app.desktop.height-1 and 1 or 2)
						@isAutoSize = no
					else if app.mouse.y <= 0
						@maximize yes
				@x = _.clamp @x + @x2, 0, app.desktop.width - @width
				@y = _.clamp @y + @y2, 0, app.desktop.height - @height
				@x2 = 0
				@y2 = 0
			else
				@x2 = event.deltaX
				@y2 = event.deltaY
		@animMinimize = null
		@setState {}
		return

	onDoubleTapTitle: (event) ->
		@maximize()
		return

	onContextMenuTitle: (event) ->
		app.showContextMenu @contentMenuHeader()
		return

	onPanResizer: (event) ->
		if @task.env.resizable
			switch event.type
				when "panstart"
					{pageX, pageY} = event.srcEvent
					pageX -= @x
					pageY -= @y
					ns =
						if pageY < 24 then "n"
						else if pageY >= @height - 24 then "s"
						else "-"
					ew =
						if pageX < 24 then "w"
						else if pageX >= @width - 24 then "e"
						else "-"
					@resizeEdge = ns + ew
					@isAutoSize = no
					@animMinimize = null
					app.setCusrorTouchmove @resizeEdge.replace("-", "") + "-resize"
				when "pan"
					if event.isFinal
						@width = _.clamp @width + @width2, @minWidth, @maxWidth
						@height = _.clamp @height + @height2, @minHeight, @maxHeight
						@x = _.clamp @x + @x2, 0, app.desktop.width - @width
						@y = _.clamp @y + @y2, 0, app.desktop.height - @height
						@x2 = 0
						@y2 = 0
						@width2 = 0
						@height2 = 0
						@resizeEdge = ""
					else
						switch @resizeEdge[0]
							when "n"
								@y2 = event.deltaY
								@height2 = -event.deltaY
								height = @height + @height2
								if height < @minHeight
									offset = @minHeight - height
									@height2 += offset
									@y2 -= offset
								else if height > @maxHeight
									offset = @maxHeight - height
									@height2 += offset
									@y2 -= offset
							when "s"
								@height2 = event.deltaY
						switch @resizeEdge[1]
							when "w"
								@x2 = event.deltaX
								@width2 = -event.deltaX
								width = @width + @width2
								if width < @minWidth
									offset = @minWidth - width
									@width2 += offset
									@x2 -= offset
								else if width > @maxWidth
									offset = @maxWidth - width
									@width2 += offset
									@x2 -= offset
							when "e"
								@width2 = event.deltaX
					@popperUpdatePermRequest?()
			@setState {}
		return

	componentDidMount: ->
		@task.win = @
		if @task.env.isSystem
			{contentWindow} = @refs.iframe
			contentWindow.ap = app
			contentWindow.tsk = @task
		@hammerTitle = new Hammer.Manager @refs.title
		@hammerTitle.add new Hammer.Tap taps: 2
		@hammerTitle.on "tap", @onDoubleTapTitle
		@hammerTitle.add new Hammer.Pan threshold: 0
		@hammerTitle.on "pan", @onPanTitle
		@hammerResizer = new Hammer.Manager @refs.resizer
		@hammerResizer.add new Hammer.Pan threshold: 0
		@hammerResizer.on "panstart pan", @onPanResizer
		@task.resolve @task unless @task.env.picker
		app.setState {}
		return

	componentWillUnmount: ->
		@hammerTitle.destroy()
		@hammerResizer.destroy()
		return

	render: ->
		<div
			ref="win"
			className="bp3-dialog absolute pb-0 m-0 z-1 no-select Win__win #{@classWin()}"
			style={@styleWin()}
			onMouseDown={@onMouseDownWin}
			onTransitionEnd={@onAnimationTransitionEndWin}
			onAnimationEnd={@onAnimationTransitionEndWin}
		>
			<div className="bp3-dialog-header px-2 mx-1 mt-1 z-1 Win__header">
				<Popover
					minimal
					position="bottom"
					boundary={@refs.win}
					usePortal={no}
					content={@contentMenuHeader()}
				>
					<Button className="mr-2" icon={@icon} minimal small/>
				</Popover>
				<h6
					ref="title"
					className="bp3-heading Win__title"
					onContextMenu={@onContextMenuTitle}
				>{@title}</h6>
				{if @permRequests[0]
					<Popover
						isOpen
						position="bottom"
						boundary={@refs.win}
						usePortal={no}
						popperUpdateRef={(@popperUpdatePermRequest) =>}
						content={
							<div
								className="p-3 text-pre-wrap"
								style={width: 260}
							>
								<p>{@permRequests[0].message}</p>
								<ButtonGroup fill>
									<Button
										className="w-50"
										text="Cho phép"
										onClick={=> @permRequests[0].cb yes}
									/>
									<Button
										className="w-50"
										text="Chặn"
										onClick={=> @permRequests[0].cb no}
									/>
								</ButtonGroup>
							</div>
						}
					>
						<Button icon="key" small minimal/>
					</Popover>
				}
				{if @task.env.minimizable
					<Button icon="minus" small minimal onClick={=> @minimize()}/>
				}
				{if @task.env.maximizable
					<Button icon="plus" small minimal onClick={=> @maximize()}/>
				}
				<Button icon="cross" small minimal intent="danger" onClick={=> @close()}/>
			</div>
			<div className="bp3-dialog-body mx-1 mb-1 mt-0 Win__body">
				<iframe
					ref="iframe"
					className="w-100 h-100 border-0 block Win__iframe"
					srcDoc={@task.code}
					sandbox={@sandbox}
				/>
			</div>
			<div
				ref="resizer"
				className="absolute z-2 Win__resizer #{@classResizer()}"
			>
				<div className="Win__resizerEdge" data-edge="n-"/>
				<div className="Win__resizerEdge" data-edge="s-"/>
				<div className="Win__resizerEdge" data-edge="-w"/>
				<div className="Win__resizerEdge" data-edge="-e"/>
				<div className="Win__resizerEdge" data-edge="nw"/>
				<div className="Win__resizerEdge" data-edge="ne"/>
				<div className="Win__resizerEdge" data-edge="sw"/>
				<div className="Win__resizerEdge" data-edge="se"/>
			</div>
		</div>
