class FileManager extends React.Component
	constructor: (props) ->
		super props

		@state =
			dir: null
			entries: []
		@connectRef = null

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

	componentDidMount: ->
		@connectRef = app.systemStorageLocalConnect (manager) =>
			@changeDir manager.root
			return
		return

	componentWillUnmount: ->
		app.systemStorageLocalDisconnect @connectRef
		return

	render: ->
		<div className="bp3-dialog-body">
			{if @state.dir
				<p>asd</p>
			else
				<div style={textAlign: "center"}>
					<Spinner intent="primary"/>
				</div>
			}
		</div>
