class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@value = ""
		@entry = null
		@menubar = [
			text: "Tập tin"
			menu: [
				icon: "document-open"
				text: "Mở..."
				onClick: =>
					@onClickOpenFile()
					return
			,
				icon: "floppy-disk"
				text: "Lưu"
				onClick: =>
					@onClickSaveFile()
					return
			,
				icon: "cross"
				intent: "danger"
				text: "Thoát"
				onClick: =>
					task.close()
					return
			]
		,
			text: "Sửa"
		]

	onChangeValue: (event) ->
		@value = event.target.value
		@setState {}
		return

	onClickOpenFile: (event) ->
		if entry = await task.pickEntries kind: "file"
			@entry = entry
			@value = await ap.readFile @entry.fullPath
			task.setTitle @entry.fullPath
			@setState {}
		return

	onClickSaveFile: ->
		if @entry
			await ap.writeFile @entry.fullPath, @value
		else if @entry = await task.saveFile data: @value
			task.setTitle @entry.fullPath
		return

	componentDidMount: ->
		if @entry = task.env.entries[0]
			@value = await ap.readFile @entry.fullPath
			task.setTitle @entry.fullPath
			@setState {}
		return

	render: ->
		<div className="column full">
			<div className="col-0">
				<Menubar menu={@menubar}/>
			</div>
			<div className="col relative m-2">
				<TextArea
					className="full no-resize"
					value={@value}
					onChange={@onChangeValue}
				/>
			</div>
		</div>
