class extends Reactive
	constructor: (props) ->
		super props

		{@entries} = state.params
		[@entry] = @entries
		ext = (/(?<=\.)[^.]+$/.exec @entry.name)?[0] or ""
		@formatNum = Intl.NumberFormat("en").format

		@state =
			name: @entries.length is 1 and @entry.name or ""
			path: ""
			type:
				if @entries.length is 1
					if @entry.isFile
						"Tập tin #{ext.toUpperCase()} (.#{ext})"
					else "Thư mục"
				else
					"Nhiều loại"
			size: 0
			lastModified: @entries.length is 1 and @entry.isFile and
				(moment @entry.fileObj.lastModified).format "L LT"
			fileCount: 0
			dirCount: 0

	componentDidMount: ->
		await @setStateAsync
			path: (@entries.length is 1 and @entry or await app.fsParent @entry).fullPath
		handle = (entries, isFirst) =>
			for entry in entries
				if entry.isFile
					await @setStateAsync
						size: @state.size + entry.fileObj.size
						fileCount: @state.fileCount + 1
				else
					if isFirst and entries.length > 1 or not isFirst
						await @setStateAsync
							dirCount: @state.dirCount + 1
					await handle await app.fsReadDir entry
			return
		handle @entries, yes
		return

	render: ->
		<div className="p-3">
			<HTMLTable fill small>
				<tbody>
					{@state.name and
						<tr>
							<td>Tên:</td>
							<td><EditableText value={@state.name}/></td>
						</tr>
					}
					<tr>
						<td>Đường dẫn:</td>
						<td><EditableText value={@state.path}/></td>
					</tr>
					<tr>
						<td>Loại:</td>
						<td>{@state.type}</td>
					</tr>
					<tr>
						<td>Kích thước:</td>
						<td>{filesize @state.size} ({@formatNum @state.size} bytes)</td>
					</tr>
					{if @state.lastModified
						<tr>
							<td>Sửa đổi lần cuối:</td>
							<td>{@state.lastModified}</td>
						</tr>
					if @entries.length > 1 or @entry.isDirectory
						<tr>
							<td>Chứa:</td>
							<td>{@state.fileCount} tập tin, {@state.dirCount} thư mục</td>
						</tr>
					}
				</tbody>
			</HTMLTable>
			<div className="bp3-dialog-footer-actions">
				<Button
					text="Đóng"
					onClick={state.close}
				/>
			</div>
		</div>
