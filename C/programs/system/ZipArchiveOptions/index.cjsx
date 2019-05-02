class extends Reactive
	constructor: (props) ->
		super props

		@state =
			name: ""
			path: "/"
			level: 5
			deleteFilesAfterArchive: no

	onSubmit: (event) ->
		event.preventDefault()
		state.resolve
			name: @state.name
			path: @state.path
			zipArchiveOpts:
				compression: @state.level and "DEFLATE" or "STORE"
				compressionOptions: @state.level and (level: @state.level) or null
		return

	onClickPath: ->
		if path = await app.pickPath "dir"
			@setState {path}
		return

	componentDidMount: ->
		{name, path} = await app.fsZipArchiveMeta state.params.entries
		@setState {name, path}
		return

	render: ->
		<form className="p-3" onSubmit={@onSubmit}>
			<FormGroup label="Tên tập tin nén">
				<InputGroup
					{...app.fileNameValidate}
					value={@state.name}
					onChange={(event) => @setState name: event.target.value}
				/>
			</FormGroup>
			<FormGroup label="Lưu tập tin nén vào thư mục">
				<InputGroup
					{...app.pathValidate}
					value={@state.path}
					onClick={@onClickPath}
				/>
			</FormGroup>
			<FormGroup label="Kiểu nén">
				<HTMLSelect
					fill
					options={[
						label: "Chỉ lưu trữ", value: 0
					, label: "Nhanh nhất", value: 1
						label: "Nhanh", value: 3
					, label: "Thường", value: 5
						label: "Tốt", value: 7
					, label: "Tốt nhất", value: 9
					]}
					value={@state.level}
					onChange={(event) => @setState level: +event.currentTarget.value}
				/>
			</FormGroup>
			<FormGroup label="Tùy chọn khác">
				<Checkbox
					label="Xóa các tập tin sau khi nén"
					checked={@state.deleteFilesAfterArchive}
					onChange={(event) => @setState deleteFilesAfterArchive: event.target.checked}
				/>
			</FormGroup>
			<div className="bp3-dialog-footer-actions">
				<Button
					type="submit"
					text="OK"
				/>
			</div>
		</form>
