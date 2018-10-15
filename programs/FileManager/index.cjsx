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
				app.set.call @, "entries", entries, =>
					entries.map (entry, i) =>
						entry.file (file) =>
							app.set.call @, "entries.#{i}.file2", file
							return
						return
					return
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
				<Table
					className="bp3-small bp3-interactive"
					style={width: "100%"}
				>
					<thead>
						<tr>
							<th>Tên</th>
							<th>Kích thước</th>
							<th>Loại</th>
							<th>Ngày sửa đổi</th>
						</tr>
					</thead>
					<tbody>
						{@state.entries.map (entry, i) =>
							<tr key={i}>
								<td>{entry.file2?.name}</td>
								<td>{entry.file2?.size / 1000} KB</td>
								<td>{entry.file2?.type}</td>
								<td>{moment(entry.file2?.lastModified).format "DD/MM/YYYY HH:mm"}</td>
							</tr>
						}
					</tbody>
				</Table>
			else
				<div style={textAlign: "center"}>
					<Spinner intent="primary"/>
				</div>
			}
		</div>

	@modal =
		title: "Quản lý tập tin"
		style:
			width: 800
