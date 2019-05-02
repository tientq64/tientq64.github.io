app = window.parent.app
appx = null
pid = ~~pid~~

state =
	params: app.tasks[pid].params
	setCloseValue: (val) =>
		app.tasks[pid].closeValue = val
		val
	resolve: (val) =>
		app.tasks[PID].dialog.close val
		return
	close: (val) =>
		app.tasks[PID].dialog.close()
		return
	_renderCb: (appx) =>
		app.tasks[pid].dialog.compMounted appx
		return
	getLang: =>
		app.getLang()
	setLang: (val) =>
		app.setLang val
		appx.forceUpdate()
		return

~~script~~

ContextMenu =
	show: window.parent.ContextMenu.show
	hide: window.parent.ContextMenu.hide

Toaster =
	show: window.parent.Toaster.show

window.ContextMenu = ContextMenu
window.Toaster = Toaster

unless app.tasks[pid].sill.picker
	app.tasks[pid].resolve state
	delete app.tasks[pid].resolve

window.addEventListener "mousedown", (event) =>
	{x, y} = frameElement.getBoundingClientRect()
	mouseEvent = new MouseEvent "mousedown",
		clientX: x + event.clientX
		clientY: y + event.clientY
	window.parent.document.dispatchEvent mouseEvent
	unless app.state.taskPid is pid
		app.taskFocus pid
	return

window.addEventListener "message", (event) =>
	if event.data is 1
		appx.forceUpdate()
	return

((ContextMenu, app, pid, parent, top, frameElement) ->
	window = new Proxy self,
		get: (target, prop) =>
			unless prop in ["top", "parent", "frameElement", "ContextMenu"]
				if typeof target[prop] is "function"
					target[prop].bind target
				else
					target[prop]

	ContextMenu =
		show: ContextMenu.show

	Comp =
		~~component~~

	state.params = _.merge {}, Comp.params, state.params

	appx = ReactDOM.render(
		<Comp/>
		document.getElementById "app"
		->
			state._renderCb @
			return
	)
	return
)(ContextMenu)
