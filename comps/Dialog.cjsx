class Dialog extends Reactive
	constructor: (props) ->
		super props

		desktopHeight = app.getDesktopHeight()
		width = _.clamp @props.sill.width or 600, 180, innerWidth
		height = _.clamp @props.sill.height or 400, 60, desktopHeight
		x = Math.floor _.clamp @props.sill.x ? (innerWidth - width) / 2, 0, innerWidth - width
		y = Math.floor _.clamp @props.sill.y ? (desktopHeight - height) / 3, 0, desktopHeight - height

		@state =
			name: @props.sill.name
			title: @props.sill.title ? @props.sill.name ? @props.path ? ""
			icon: @props.sill.icon ? "application"
			x: x
			y: y
			width: width
			height: height
			order: @props.pid
			isMaximize: no
			isMinimize: no
			isNewly: yes
			isOpen: no

		@pantap = null
		@isMove = no
		@resizeEdge = []
		@resizeEdges = "ct lm rm cb lt rt lb rb".split " "
		@animate = null

	setTitle: (val) ->
		@setState title: val
		return

	minimize: ->
		taskbarTaskEl = document.querySelector ".taskbar-task-" + @props.pid
		dialogEl = @refs.dialog
		rect = taskbarTaskEl.getBoundingClientRect()
		if @animate
			@animate.reverse()
			@setState isMinimize: no
			app.taskFocus @props.pid
			@animate.onfinish = app.update
			@animate = null
		else
			@animate = dialogEl.animate
				left: [dialogEl.offsetLeft + "px", rect.left + "px"]
				top: [dialogEl.offsetTop + "px", rect.top + "px"]
				width: [dialogEl.offsetWidth + "px", rect.width + "px"]
				height: [dialogEl.offsetHeight + "px", rect.height + "px"]
				opacity: [1, 0]
			,
				duration: 200
				easing: "ease-in"
				fill: "forwards"
			@animate.onfinish = =>
				if @animate?.playbackRate is 1 and @animate.playState is "finished"
					@setState isMinimize: yes
					app.taskBlur @props.pid
				return
		return

	maximize: ->
		@setState
			isMaximize: not @state.isMaximize
			isNewly: no
		app.forceUpdate()
		return

	close: (val) ->
		if app.tasks[@props.pid].sill.picker
			app.tasks[@props.pid].resolve(
				if arguments.length then val
				else app.tasks[@props.pid].closeValue
			)
		app.taskKill @props.pid

	splitLeft: ->
		halfWidth = Math.floor innerWidth / 2
		@setState
			x: 0
			y: 0
			width: halfWidth
			height: app.getDesktopHeight()
		return

	splitRight: ->
		halfWidth = Math.floor innerWidth / 2
		@setState
			x: halfWidth
			y: 0
			width: innerWidth - halfWidth
			height: app.getDesktopHeight()
		return

	fillHeight: ->
		@setState
			y: 0
			height: app.getDesktopHeight()
		return

	autoSize: (cb) ->
		unless @props.sill.width?
			@refs.dialog.style.width = ""
			width = _.clamp @refs.dialog.offsetWidth, 180, innerWidth
			@setState {width}, cb
			cb = undefined
		unless @props.sill.height?
			desktopHeight = app.getDesktopHeight()
			@refs.dialog.style.height = ""
			height = _.clamp @refs.dialog.offsetHeight, 60, desktopHeight
			@setState {height}, cb
			cb = undefined
		unless @props.sill.x?
			width ?= @state.width
			x = Math.floor _.clamp (innerWidth - width) / 2, 0, innerWidth - width
			@setState {x}, cb
			cb = undefined
		unless @props.sill.y?
			desktopHeight = app.getDesktopHeight()
			height ?= @state.height
			y = Math.floor _.clamp (desktopHeight - height) / 3, 0, desktopHeight - height
			@setState {y}, cb
			cb = undefined
		return

	compMounted: (appx) ->
		@autoSize =>
			app.tasks[@props.pid].appx = appx
			appx.forceUpdate()
			app.forceUpdate()
			dialogEl = @refs.dialog
			dialogEl.classList.remove "dialog-appear-custom"
			dialogEl.classList.add "dialog-enter-custom"
			animationEnd = =>
				dialogEl.classList.remove "dialog-enter-custom"
				dialogEl.removeEventListener "animationend", animationEnd
				return
			dialogEl.addEventListener "animationend", animationEnd
			return

	classDialog: -> classNames
		"dialog-maximize": @state.isMaximize
		"dialog-minimize": @state.isMinimize
		"dialog-newly": @state.isNewly
		"bp3-dialog"
		@props.className

	style: -> {
		...@props.style
		left: @state.x
		top: @state.y
		width: @state.width
		height: @state.height
		zIndex: @state.order
	}

	onMinimize: (event) ->
		@minimize()
		return

	onMaximize: (event) ->
		@maximize()
		return

	onClose: (event) ->
		@close()
		return

	onMouseDownDialog: (event) ->
		unless app.state.taskPid is @props.pid
			app.taskFocus @props.pid
		return

	onDoubleClickHeader: (event) ->
		@maximize() if event.target is event.currentTarget
		return

	onAnimationEnd: ->
		@setState()
		return

	componentDidMount: ->
		@props.dialogRef @
		@refs.dialog.classList.add "dialog-appear-custom"
		if @props.ap.isSystem
			{Comp} = @props
			that = @
			ReactDOM.render <Comp/>, @refs.comp, ->
				that.compMounted @
				return
		@pantap = new Pantap @refs.dialog,
			panStart: (mx, my, {target}) =>
				desktopTop = app.getDesktopTop()
				my -= desktopTop
				if target is @refs.header
					@isMove = yes
					if @state.isMaximize
						@setState
							x: _.clamp mx - @state.width / 2, 0, innerWidth - @state.width
							y: -2
						@maximize()
				else if target.dataset.dialogEdge
					[edgeX, edgeY] = target.dataset.dialogEdge.split ""
					@resizeEdge[0] = "lcr".indexOf(edgeX) - 1
					@resizeEdge[1] = "tmb".indexOf(edgeY) - 1
				return
			panMove: (dx, dy) =>
				if @isMove
					@setState
						x: @state.x + dx
						y: @state.y + dy
				else if @resizeEdge.length
					if @resizeEdge[0]
						width = @state.width + dx * @resizeEdge[0]
						if @resizeEdge[0] is -1
							if width < 180
								if @state.width >= 180
									@setState x: @state.x + @state.width - 180
							else
								if @state.width < 180
									@setState x: @state.x - width + 180
								else
									@setState x: @state.x + dx
						@setState {width}
					if @resizeEdge[1]
						height = @state.height + dy * @resizeEdge[1]
						if @resizeEdge[1] is -1
							if height < 60
								if @state.height >= 60
									@setState y: @state.y + @state.height - 60
							else
								if @state.height < 60
									@setState y: @state.y - height + 60
								else
									@setState y: @state.y + dy
						@setState {height}
				return
			panEnd: (mx, my) =>
				desktopTop = app.getDesktopTop()
				my -= desktopTop
				if @isMove or @resizeEdge.length
					desktopHeight = app.getDesktopHeight()
					desktopBottom = app.getDesktopBottom()
					if @isMove
						if mx <= 0
							@splitLeft()
						else if mx >= innerWidth - 1
							@splitRight()
						else if my <= 0
							@maximize()
					else
						if my <= 0 or my >= desktopHeight - 1
							@fillHeight()
					width = _.clamp @state.width, 180, innerWidth
					height = _.clamp @state.height, 60, desktopHeight
					x = _.clamp @state.x, 0, innerWidth - width
					y = _.clamp @state.y, 0, desktopHeight - height
					@setState {x, y, width, height}
					@isMove = no
					@resizeEdge = []
				return
		return

	componentWillUnmount: ->
		@pantap.destroy()
		return

	render: ->
		<div
			ref="dialog"
			className={@classDialog()}
			style={@style()}
			onMouseDown={@onMouseDownDialog}
			onAnimationEnd={@onAnimationEnd}
		>
			<div
				ref="header"
				className="bp3-dialog-header"
				onDoubleClick={@onDoubleClickHeader}
			>
				<Popover
					position="bottom-left"
					content={
						<Menu>
							<MenuItem
								text="Thu nhỏ"
								onClick={@onMinimize}
							/>
							<MenuItem
								text="Mở rộng"
								onClick={@onMaximize}
							/>
							<MenuItem
								intent="danger"
								text="Đóng"
								onClick={@onClose}
							/>
						</Menu>
					}
				>
					<Button minimal>
						{typeof @state.icon is "string" and
							<Icons icon={@state.icon}/> or
							<img src={@state.icon} className="dialog-icon"/>
						}
					</Button>
				</Popover>
				<H4>{@state.title}</H4>
				<Button
					icon="minus"
					intent="primary"
					minimal
					onClick={@onMinimize}
				/>
				<Button
					icon="plus"
					intent="primary"
					minimal
					onClick={@onMaximize}
				/>
				<Button
					icon="cross"
					intent="danger"
					minimal
					onClick={@onClose}
				/>
			</div>
			<div className="bp3-dialog-body scoped-css-#{@props.pid}">
				{if @props.ap.isSystem
					<div ref="comp"/>
				else
					<iframe
						srcDoc={@props.code}
						sandbox="allow-same-origin allow-scripts allow-pointer-lock"
					/>
				}
			</div>
			{@state.isMaximize or @resizeEdges.map (edge) =>
				<div key={edge} data-dialog-edge={edge}/>
			}
			<style>{@props.css}</style>
		</div>
