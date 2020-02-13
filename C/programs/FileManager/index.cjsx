await task.import "npm:filesize@6.0.1"

class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@entry = null
		@tmpPath = ap.pathNormalize task.params.path
		@selEntries = []
		@tmpSelEntries = []
		@entries = []
		@alter = null
		@hist = new Hist maxLength: 100
		@view = task.params.view
		@isHiddenDesktop = no
		@selector = shown: no, x0: 0, y0: 0, x1: 0, y1: 0
		@hammerSelector = null
		@pickerTypeText = {dir: "thư mục", file: "tập tin"}[task.params.kind] or "mục"
		@filename = task.params.filename + ""
		@data = task.params.data

	loadEntries: (path = @entry.fullPath, pushHist) ->
		@tmpPath = ap.pathNormalize path
		@selEntries = []
		try
			@entry = await ap.getEntry @tmpPath
			@entries = await ap.readDir @entry
			@entries = @entries.sort (entryA, entryB) =>
				entryA.isFile - entryB.isFile or entryA.name.localeCompare(entryB.name)
			@hist.push @entry.fullPath if pushHist
		@setState {}
		return

	getPickerResult: ->
		if task.params.kind is "save" and not @filename then []
		else if @selEntries.length
			entries = @selEntries
			switch task.params.kind
				when "dir"
					entries = entries.filter (entry) => entry.isDirectory
				when "file"
					entries = entries.filter (entry) => entry.isFile
			entries.map (entry) => ap.cloneEntry entry
		else if task.params.kind isnt "file"
			[ap.cloneEntry @entry]
		else []

	getDirPathSave: ->
		if entry = @selEntries[0]
			if entry.isFile
				ap.pathDirname entry.fullPath
			else entry.fullPath
		else @entry.fullPath

	openEntry: (entry) ->
		if entry.isFile
			if entry.fullPath.endsWith "/app.yml"
				ap.runTask entry.fullPath
			else
				ext = ap.pathExtname entry.name
				if ext is "lnk"
					@openEntry await ap.resolveShortcut entry.fullPath, yes
				else
					if appl = ap.exts[ext]?.appls[0]
						entry = ap.cloneEntry entry
						ap.addEntriesToApplPermPaths appl, entry
						ap.runTask "#{appl.path}/app.yml", null, entries: [entry]
					else ap.openFilesWith entry
		else
			if task.env.isDesktop
				ap.runTask "#{tsk.appl.path}/app.yml", path: entry.fullPath
			else
				@loadEntries entry.fullPath, yes
		return

	pasteAlterEntries: (newPath) ->
		alter = @alter
		@alter = null
		await ap.runTask "/C/programs/FilePaster/app.yml",
			alter: alter.act
			path: newPath
		, entries: alter.entries
		@loadEntries()
		return

	classMain: ->
		classNames
			"FileManager__isDesktop": task.env.isDesktop

	classView: ->
		classNames
			"hidden": @isHiddenDesktop

	classEntry: (entry) ->
		classNames
			"bg-selection": @selEntries.includes(entry) + @tmpSelEntries.includes(entry) is 1

	styleMain: ->
		if task.env.isDesktop
			backgroundImage: "url(#{ap.desktop.background.base64})"
			backgroundSize: ap.desktop.background.fit

	styleSelector: ->
		left: Math.min(@selector.x0, @selector.x1) - @refs.entries.scrollLeft
		top: Math.min(@selector.y0, @selector.y1) - @refs.entries.scrollTop
		width: Math.abs @selector.x1 - @selector.x0
		height: Math.abs @selector.y1 - @selector.y0
		display: "none" unless @selector.shown

	updateBorderRadiusEntry: ->
		setTimeout =>
			selEls = document.querySelectorAll ".FileManager__entry"
			for el from selEls
				prevSel = el.previousElementSibling?.classList.contains "bg-selection"
				nextSel = el.nextElementSibling?.classList.contains "bg-selection"
				el.style.borderRadius =
					if el.classList.contains "bg-selection"
						if prevSel and nextSel then 0
						else if not prevSel and not nextSel then "6px"
						else if not prevSel then "6px 6px 0 0"
						else "0 0 6px 6px"
					else ""
			return
		return

	handleDoubleClickEntry: (entry, event) ->
		unless event.ctrlKey
			if task.env.picker and entry.isFile
				@handleSelectBtn()
			else
				@openEntry entry
		return

	handleContextMenuEntry: (entry, event) ->
		if entry in @selEntries
			event.stopPropagation()
		else
			if event.target.cellIndex
				@selEntries = []
				@setState {}
				return
			else
				@selEntries = [entry]
				if task.params.kind is "save"
					if entry.isFile
						@filename = entry.name
				@updateBorderRadiusEntry()
				event.stopPropagation()
				@setState {}
		ext = ap.pathExtname entry.name
		menu = [
			text: "Chọn"
			icon: "tick-circle"
			intent: "primary"
			shown: task.env.picker and task.params.kind isnt "save" and @getPickerResult().length
			onClick: =>
				@handleSelectBtn()
				return
		,,
			text: "Mở"
			icon: "document-open"
			onClick: =>
				@openEntry entry
				return
		,
			text: "Mở bằng..."
			icon: "document-open"
			shown: @selEntries.some (v) => v.isFile
			submenu: [
				...((ap.exts[ext]?.appls or []).map (appl) =>
					text: appl.name
					icon: appl.icon
					onClick: =>
						entries = @selEntries.filter (v) => v.isFile
						ap.addEntriesToApplPermPaths appl, entries
						ap.runTask "#{appl.path}/app.yml", null, {entries}
						return
				) ,,
					text: "Mở bằng ứng dụng khác..."
					icon: "applications"
					onClick: =>
						entries = @selEntries.filter (v) => v.isFile
						ap.openFilesWith entries
						return
			]
		,
			text: "Mở trong cửa sổ mới"
			icon: "applications"
			shown: @selEntries.length is 1 and entry.isDirectory and not task.env.isDesktop
			onClick: =>
				ap.runTask "#{tsk.appl.path}/app.yml", path: entry.fullPath
				return
		,
			text: "Đặt làm hình nền desktop"
			icon: "media"
			shown: @selEntries.length is 1 and /^(png|jpe?g|gif)$/.test ap.pathExtname entry.name
			onClick: =>
				await ap.setDesktopBackgroundPath entry.fullPath
				@setState {}
				return
		,,
			text: "Di chuyển"
			icon: "cut"
			onClick: =>
				@alter =
					act: "move"
					entries: [...@selEntries]
				return
		,
			text: "Sao chép"
			icon: "duplicate"
			onClick: =>
				@alter =
					act: "copy"
					entries: [...@selEntries]
				return
		,
			text: "Dán"
			icon: "clipboard"
			shown: @alter and @selEntries.length is 1 and entry.isDirectory
			onClick: =>
				@pasteAlterEntries entry.fullPath
				return
		,,
			text: "Xóa"
			icon: "trash"
			intent: "danger"
			onClick: =>
				for entry2 from @selEntries
					if entry2.isFile
						await ap.deleteFile entry2
					else
						await ap.deleteDir entry2
				@loadEntries()
				return
		,
			text: "Đổi tên"
			icon: "text-highlight"
			shown: @selEntries.length is 1
			onClick: =>
				newName = await tsk.win.prompt "Nhập tên #{entry.isFile and "tập tin" or "thư mục"} mới:",
					value: entry.name
					validate: "filename"
				if newName
					newPath = ap.pathJoin ap.pathDirname(entry.fullPath), newName
					await ap.movePath entry.fullPath, newPath
					@loadEntries()
				return
		]
		ap.showContextMenu menu
		return

	handleSelectBtn: ->
		entries = @getPickerResult()
		if task.params.kind is "save"
			filename = ap.validateFilename @filename
			if _.isError filename
				task.alert filename.message
			else
				dirname = @getDirPathSave()
				path = ap.pathJoin dirname, @filename
				entry = ap.cloneEntry await ap.writeFile path, @data
				if task.params.applPath
					ap.addEntriesToApplPermPaths ap.appls[task.params.applPath], entry
				task.close entry
		else
			if entries.length
				unless task.params.multiple
					entries = entries[0]
				task.close entries
		return

	onContextMenuList: (event) ->
		@selEntries = []
		menu = [
			text: "Chọn"
			icon: "tick-circle"
			intent: "primary"
			shown: task.env.picker and @getPickerResult().length
			onClick: =>
				@handleSelectBtn()
				return
		,,
			text: "Hiển thị"
			icon: "grid-view"
			submenu: [
				text: "Hiển thị desktop"
				icon: "tick" unless @isHiddenDesktop
				shown: task.env.isDesktop
				onClick: =>
					@isHiddenDesktop = not @isHiddenDesktop
					@setState {}
					return
			]
		,
			text: "Làm mới"
			icon: "refresh"
			onClick: =>
				@loadEntries()
				return
		,,
			text: "Dán"
			icon: "clipboard"
			shown: @alter
			onClick: =>
				@pasteAlterEntries @entry.fullPath
				return
		,
			text: "Mở cửa sổ dòng lệnh ở đây..."
			icon: "console"
			onClick: =>
				ap.runTask "/C/programs/Command/app.yml",
					path: @entry.fullPath
				return
		,,
			text: "Tạo mới"
			icon: "folder-new"
			submenu: [
				text: "Thư mục"
				icon: "folder-close"
				onClick: =>
					if name = await tsk.win.prompt "Nhập tên thư mục:", validate: "filename"
						await ap.createDir ap.pathJoin @entry.fullPath, name
						@loadEntries()
					return
			,
				text: "Tập tin"
				icon: "document"
				onClick: =>
					if name = await tsk.win.prompt "Nhập tên tập tin:", validate: "filename"
						await ap.writeFile ap.pathJoin @entry.fullPath, name
						@loadEntries()
					return
			]
		]
		ap.showContextMenu menu
		@setState {}
		return

	onSubmitForm: (event) ->
		event.preventDefault()
		@loadEntries @tmpPath, yes
		return

	onChangeInput: (event) ->
		@tmpPath = event.target.value
		@setState {}
		return

	onClickBack: (event) ->
		@hist.back @loadEntries
		return

	onClickForward: (event) ->
		@hist.forward @loadEntries
		return

	onClickUpParent: (event) ->
		unless @entry.fullPath is "/"
			@loadEntries ap.pathDirname(@entry.fullPath), yes
		return

	onClickRefresh: (event) ->
		@loadEntries()
		return

	onTapPanSelector: (event) ->
		x = event.center.x - @refs.list.offsetLeft + @refs.entries.scrollLeft
		y = event.center.y - @refs.list.offsetTop + @refs.entries.scrollTop
		switch event.type
			when "panstart"
				if event.srcEvent.ctrlKey
					@tmpSelEntries = @selEntries
				@selEntries = []
				@selector.shown = yes
				@selector.x0 = @selector.x1 = x
				@selector.y0 = @selector.y1 = y
			when "pan", "tap"
				if event.type is "tap"
					@selector.x0 = x
					@selector.y0 = y
				@selector.x1 = x
				@selector.y1 = y
				if entryEls = document.querySelectorAll ".FileManager__entry"
					{x0, y0, x1, y1} = @selector
					[x1, x0] = [x0, x1] if x1 < x0
					[y1, y0] = [y0, y1] if y1 < y0
					if (event.type is "tap" and not event.srcEvent.ctrlKey) or event.type is "pan"
						@selEntries = []
					for entryEl, i in entryEls
						if x1 >= entryEl.offsetLeft and
						x0 < entryEl.offsetLeft + entryEl.offsetWidth and
						y1 >= entryEl.offsetTop and
						y0 < entryEl.offsetTop + entryEl.offsetHeight
							if event.type is "tap" and event.srcEvent.ctrlKey and @entries[i] in @selEntries
								_.pull @selEntries, @entries[i]
							else @selEntries.push @entries[i]
		if event.isFinal
			@selector.shown = no
			@selEntries = _.xor @selEntries, @tmpSelEntries
			if task.env.picker and not task.params.multiple
				@selEntries.splice 1
			if task.params.kind is "save"
				[entry] = @selEntries
				if entry and entry.isFile
					@filename = entry.name
			@tmpSelEntries = []
		@updateBorderRadiusEntry()
		@setState {}
		return

	onChangeFilename: (event) ->
		@filename = event.target.value
		@setState {}
		return

	componentDidMount: ->
		if task.env.isDesktop
			ap.desktop.task = tsk
		@entry = await ap.getEntry @tmpPath
		await @loadEntries @entry.fullPath, yes
		@hammerSelector = new Hammer.Manager @refs.list
		@hammerSelector.add new Hammer.Tap threshold: 100, time: 9e9
		@hammerSelector.on "tap", @onTapPanSelector
		if not task.env.picker or task.params.multiple
			@hammerSelector.add new Hammer.Pan threshold: 0
			@hammerSelector.on "panstart pan", @onTapPanSelector
		task.listen
			refresh: =>
				@loadEntries()
				return
			update: =>
				@setState {}
				return
		return

	render: ->
		if @entry
			pickerPaths = @getPickerResult()
			<div
				className="column nowrap full p-3 no-scroll FileManager__main #{@classMain()}"
				style={@styleMain()}
			>
				{unless task.env.isDesktop
					<form className="col-0 row nowrap" onSubmit={@onSubmitForm}>
						<ButtonGroup className="col-0">
							<Button
								icon="arrow-left"
								disabled={not @hist.canBack()}
								onClick={@onClickBack}
							/>
							<Button
								icon="arrow-right"
								disabled={not @hist.canForward()}
								onClick={@onClickForward}
							/>
							<Button icon="arrow-up" disabled={@entry.fullPath is "/"} onClick={@onClickUpParent}/>
						</ButtonGroup>
						<Divider className="mx-3"/>
						<div className="col">
							<ControlGroup fill>
								<InputGroup
									value={@tmpPath}
									onChange={@onChangeInput}
								/>
								<Button className="bp3-fixed" icon="repeat" onClick={@onClickRefresh}/>
								<Button className="bp3-fixed" type="submit" icon="key-enter"/>
							</ControlGroup>
						</div>
					</form>
				}
				<div
					ref="list"
					className="col relative mt-3 no-scroll FileManager__list"
					onContextMenu={@onContextMenuList}
				>
					{switch @view
						when "icons"
							<div ref="entries" className="full scroll FileManager__view #{@classView()}">
								<Menu className="bg-transparent FileManager__viewIcons">
									{@entries.map (entry) =>
										<MenuItem
											key={entry.fullPath}
											className="FileManager__entry #{@classEntry entry}"
											icon={entry.icon}
											text={entry.name}
											onDoubleClick={(event) => @handleDoubleClickEntry entry, event}
											onContextMenu={(event) => @handleContextMenuEntry entry, event}
										/>
									}
								</Menu>
							</div>
						else
							<HTMLTable className="text-ellipsis #{@classView()}" fill fixed small interactive>
								<thead>
									<tr>
										<th className="col-6">Tên</th>
										<th className="col-3">Kích thước</th>
										<th className="col-3">Ngày sửa đổi</th>
									</tr>
								</thead>
								<tbody ref="entries">
									{@entries.map (entry) =>
										<tr
											key={entry.fullPath}
											className="cursor-default rounded FileManager__entry #{@classEntry entry}"
											onDoubleClick={(event) => @handleDoubleClickEntry entry, event}
											onContextMenu={(event) => @handleContextMenuEntry entry, event}
										>
											<td className="col-6">
												<Icon className="mr-3" icon={entry.icon}/>
												{entry.name}
											</td>
											<td className="col-3">{filesize entry.size}</td>
											<td className="col-3">{moment(entry.lastModifiedDate).format("L HH:mm")}</td>
										</tr>
									}
								</tbody>
							</HTMLTable>
					}
					{if @selector.shown
						<div
							className="absolute bg-selection no-pointer-events border-shadow"
							style={@styleSelector()}
						/>
					}
				</div>
				{if task.params.kind is "save"
					<InputGroup
						className="col-0 mt-3"
						value={@filename}
						onChange={@onChangeFilename}
					/>
				}
				{if task.env.picker
					<div className="col-0 row nowrap middle mt-3">
						<div ref="infoSel" className="col text-ellipsis">
							{
								if task.params.kind is "save"
									"Lưu vào: #{@getDirPathSave()}"
								else
									(pickerPaths.length and "Đã chọn: " or "") +
									switch pickerPaths.length
										when 0 then ""
										when 1 then pickerPaths[0].fullPath
										else "#{pickerPaths.length} #{@pickerTypeText}"
							}
						</div>
						<div className="pl-2">
							<ButtonGroup>
								<Button
									style={width: 80}
									disabled={not pickerPaths.length}
									intent="primary"
									text={task.params.kind is "save" and "Lưu" or "Chọn"}
									onClick={=> @handleSelectBtn()}
								/>
								<Button
									style={width: 80}
									text="Hủy"
									onClick={=> task.close null}
								/>
							</ButtonGroup>
						</div>
					</div>
				}
			</div>
		else null

	@defaultParams =
		path: "/"
		kind: "entry"
		multiple: no
		view: "details"
		filename: ""
		data: ""
		applPath: null
