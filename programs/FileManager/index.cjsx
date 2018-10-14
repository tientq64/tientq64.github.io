class FileManager extends React.Component
	constructor: (props) ->
		super props

		@state =
			dir: app.state.system.storage.env.local?.root
			entries: []

		@changeDir()

	changeDir: (dir = @state.dir) ->
		return unless dir
		app.systemStorageListEntries dir,
			(entries) =>
				app.set.call @, "dir", dir
				app.set.call @, "entries", entries
				return
			(err) =>
				return
		return

	componentWillReceiveProps: (props) ->
		@changeDir app.state.system.storage.env.local?.root
		return

	render: () ->
		<div className="bp3-dialog-body">
			{if @state.dir
				<p>asd</p>
			else
				<p>loading...</p>
			}
		</div>
