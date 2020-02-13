class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		exts = task.env.entries.map (entry) => ap.pathExtname entry.fullPath
		isShowAddApplExts = exts.length is 1 and exts[0] and exts[0] not in ["lnk", "yml"]
		exts = _.uniq exts.filter Boolean

		@appl = null
		@exts = exts
		@isShowAddApplExts = isShowAddApplExts
		@isAddApplExts = isShowAddApplExts

	handleClickAppl: (@appl) ->
		@setState {}
		return

	handleOk: ->
		ap.runTask "#{@appl.path}/app.yml", null, entries: task.env.entries
		if @isAddApplExts
			ap.addApplExts @appl, @exts
		task.close()
		return

	onChangeIsSetDefaultAppl: (event) ->
		@isAddApplExts = event.target.checked
		@setState {}
		return

	componentDidMount: ->
		task.close() unless task.env.entries.length
		return

	render: ->
		<div className="p-3">
			<p>Chọn một ứng dụng để mở {task.env.entries.length > 1 and "các " or ""}tập tin này:</p>
			<Menu className="col p-0 scroll" style={maxHeight: 280}>
				{_.map ap.appls, (appl) =>
					if appl.exts.length
						<MenuItem
							active={appl is @appl}
							text={appl.name}
							icon={appl.icon}
							onClick={=> @handleClickAppl appl}
							onDoubleClick={=> @handleOk()}
						/>
				}
			</Menu>
			{if @isShowAddApplExts
				<Checkbox
					className="mt-3"
					label="Luôn sử dụng ứng dụng này để mở tập tin .#{@exts[0]}"
					checked={@isAddApplExts}
					onChange={@onChangeIsSetDefaultAppl}
				/>
			}
			<div className="text-right mt-3">
				<ButtonGroup>
					<Button
						style={width: 80}
						disabled={not @appl}
						text="Chọn"
						onClick={=> @handleOk()}
					/>
					<Button
						style={width: 80}
						text="Hủy"
						onClick={=> task.close()}
					/>
				</ButtonGroup>
			</div>
		</div>
