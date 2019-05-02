((o, PID, state, path, opts, Comp, resolve, reject) ->
	PID = ~~pid~~

	state =
		params: o.task.params
		setCloseValue: (val) =>
			app.tasks[PID].closeValue = val
			val
		resolve: (val) =>
			app.tasks[PID].dialog.close val
			return
		close: (val) =>
			app.tasks[PID].dialog.close()
			return

	unless o.task.sill.picker
		o.task.resolve state
		delete o.task.resolve

	o = undefined

	Comp =
		~~component~~

	state.params = _.merge {}, Comp.params, state.params

	Comp
)(o)
