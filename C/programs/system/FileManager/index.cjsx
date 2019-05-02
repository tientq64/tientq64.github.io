class extends Reactive
	constructor: (props) ->
		super props

		@state =
			path: "/"
			entryPath: null
			tmpPath: "/"
			entries: []
			selEntries: []
			tmpEntries: []
			tmpMethod: undefined
			x0: 0
			y0: 0
			x1: 0
			y1: 0
			isPanning: no

		@task = app.tasks[PID]
		@pantap = null

	loadEntries: (entryPath = @state.entryPath) ->
		entries = await app.fsReadDir entryPath
		@setState {entries, selEntries: []}
		return

	load: (entryPath = @state.entryPath) ->
		entryPath = await app.fsDir entryPath
		path = app.fsPath entryPath.fullPath
		await @loadEntries entryPath
		@setState
			path: path
			entryPath: entryPath
			tmpPath: path
		unless @task.sill.picker
			@task.dialog.setTitle (_.last app.fsPathSplit path) or "FileManager"
		return

	iconEntry: (entry) ->
		if entry.isFile
			ext = /(?<=\.)[^.]+$/.exec(entry.name)?[0]
			if /^(txt|md)$/.test ext
				"file-alt fas"
			else if /^(png|jpe?g|gif|webm|svg|ico)$/.test ext
				"file-image fas"
			else if /^(mp3|wav|ogg)$/.test ext
				"file-audio fas"
			else if /^(mp4|3gp)$/.test ext
				"file-video fas"
			else if /^(html?|css|jsx?|cjsx|coffee|styl(us)?|pug|json|xml|yaml)$/.test ext
				"file-code fas"
			else if /^(csv)$/.test ext
				"file-csv fas"
			else if /^(sill)$/.test ext
				"file-medical-alt fas"
			else if /^(zip|rar)$/.test ext
				"file-archive fas"
			else if /^(pdf)$/.test ext
				"file-pdf fas"
			else if /^(doc)$/.test ext
				"file-word fas"
			else if /^(exl)$/.test ext
				"file-excel fas"
			else if /^(ppt)$/.test ext
				"file-powerpoint fas"
			else
				"file fas"
		else
			"folder fas"

	typeEntry: (entry) ->
		if entry.isFile
			"Tập tin " + (/(?<=\.)[^.]+$/.exec(entry.name)?[0].toUpperCase() or "")
		else "Thư mục"

	classEntry: (entry) -> classNames(
		"entry"
		"selected" if @state.selEntries.includes entry
	)

	styleSelectRect: ->
		left: Math.min @state.x0, @state.x1
		top: Math.min @state.y0, @state.y1
		width: Math.abs @state.x1 - @state.x0
		height: Math.abs @state.y1 - @state.y0

	onContextMenuList: (event) ->
		if event.target is event.currentTarget
			ContextMenu.show(
				<Menu>
					{if (
						@state.tmpEntries.length and
						@state.selEntries.length < 2 and (
							not @state.selEntries[0] or
							@state.selEntries[0].isDirectory
						)
					)
						<MenuItem
							text="Dán"
							icon={<Icons icon="paste fa"/>}
							onClick={@onClickEntryPaste}
						/>
					}
					<MenuItem
						text="Thư mục mới"
						icon={<Icons icon="folder fas"/>}
						onClick={@onClickListNewDir}
					/>
					<MenuItem
						text="Tập tin mới"
						icon={<Icons icon="file fas"/>}
						onClick={@onClickListNewFile}
					/>
				</Menu>
			)
		return

	onClickListNewFile: ->
		fileName = await app.prompt "Nhập tên tập tin", "", app.fileNameValidate
		await app.fsFile fileName, entry: @state.entryPath, flag: "+x"
		@loadEntries()
		return

	onClickListNewDir: ->
		dirName = await app.prompt "Nhập tên thư mục", "", app.fileNameValidate
		await app.fsDir dirName, entry: @state.entryPath, flag: "+x"
		@loadEntries()
		return

	handleDoubleClickEntry: (entry) ->
		if entry.isDirectory
			@load entry
		return

	onClickEntry: (event, entry) ->
		if event.ctrlKey and not @task.sill.picker
			selEntries = [...@state.selEntries]
			if (index = selEntries.indexOf entry) >= 0
				selEntries.splice index, 1
			else
				selEntries.push entry
		else
			selEntries = [entry]
		@setState {selEntries}
		return

	onContextMenuEntry: (event, entry) ->
		unless @state.selEntries.includes entry
			await @setStateAsync selEntries: [entry]
		ContextMenu.show(
			<Menu>
				{if @task.sill.picker and not @disabledOKButton()
					<MenuItem
						text="Chọn"
						icon="tick-circle"
						intent="primary"
						onClick={@onClickOKButton}
					/>
				}
				{if @state.selEntries.length is 1 then [
					<MenuItem
						text="Mở"
						icon="document-open"
						onClick={@onClickEntryOpen}
					/>
					<MenuItem
						text="Mở bằng..."
						icon="document-open"
					/>
				]}
				<MenuItem
					text="Cắt"
					icon={<Icons icon="cut fa"/>}
					onClick={@onClickEntryMove}
				/>
				<MenuItem
					text="Sao chép"
					icon={<Icons icon="copy fa"/>}
					onClick={@onClickEntryCopy}
				/>
				{if (
					@state.tmpEntries.length and
					@state.selEntries.length < 2 and (
						not @state.selEntries[0] or
						@state.selEntries[0].isDirectory
					)
				)
					<MenuItem
						text="Dán"
						icon={<Icons icon="paste fa"/>}
						onClick={@onClickEntryPaste}
					/>
				}
				<MenuItem
					text="Tạo tệp nén \"#{(await app.fsZipArchiveMeta @state.selEntries).name}\""
					icon={<Icons icon="file-archive fa"/>}
					onClick={=> @handleClickEntryZipArchive()}
				/>
				<MenuItem
					text="Tạo tệp nén tùy chọn..."
					icon={<Icons icon="file-archive fa"/>}
					onClick={@onClickEntryZipArchiveOptions}
				/>
				{if @state.selEntries.length is 1 and @state.selEntries[0].isFile
					<MenuItem
						text="Giải nén ở đây"
						icon={<Icons icon="file-archive fa"/>}
						onClick={@onClickEntryZipExtractHere}
					/>
				}
				<MenuItem
					text="Tạo shortcut"
					icon={<Icons icon="external-link-square-alt fa"/>}
				/>
				<MenuItem
					text="Xóa"
					icon="trash"
					intent="danger"
					onClick={@onClickEntryDelete}
				/>
				{if @state.selEntries.length is 1
					<MenuItem
						text="Đổi tên"
						icon="text-highlight"
						onClick={@onClickEntryRename}
					/>
				}
				<MenuItem
					text="Xem chi tiết"
					icon="info-sign"
					onClick={@onClickEntryDetails}
				/>
			</Menu>
		)
		return

	onClickEntryOpen: ->
		entry = @state.selEntries[0]
		if entry.isDirectory
			@handleDoubleClickEntry entry
		return

	onClickEntryMove: ->
		@setState
			tmpEntries: [...@state.selEntries]
			tmpMethod: "fsMove"
		return

	onClickEntryCopy: ->
		@setState
			tmpEntries: [...@state.selEntries]
			tmpMethod: "fsCopy"
		return

	onClickEntryPaste: ->
		try
			newDir = @state.selEntries[0] or @state.entryPath
			await Promise.all @state.tmpEntries.map (entry) =>
				app[@state.tmpMethod] entry, newDir
		catch err
			Toaster.show err.message, intent: "danger"
		await @setStateAsync
			tmpEntries: []
			tmpMethod: undefined
		@loadEntries()
		return

	handleClickEntryZipArchive: (entries = @state.selEntries, zipArchiveOptions) ->
		result = await app.fsZipArchive entries, zipArchiveOptions
		await app.fsZipArchiveWrite result
		@loadEntries()
		return

	onClickEntryZipArchiveOptions: ->
		entries = [...@state.selEntries]
		zipArchiveOptions = await app.taskRun "C/programs/system/ZipArchiveOptions",
			params: {entries}
		if zipArchiveOptions
			@handleClickEntryZipArchive entries, zipArchiveOptions
		return

	onClickEntryZipExtractHere: ->
		file = @state.selEntries[0]
		result = await app.fsZipExtract file, @state.path
		await app.fsZipExtractWrite result
		@load()
		return

	onClickEntryDelete: ->
		await Promise.all @state.selEntries.map (entry) =>
			if entry.isFile
				app.fsRemove entry
			else
				app.fsRemoveRecursive entry
		@loadEntries()
		return

	onClickEntryRename: ->
		entry = @state.selEntries[0]
		if newName = await app.prompt "Nhập tên mới", entry.name, app.fileNameValidate
			newName = newName.trim()
			unless entry.name is newName
				await app.fsMove entry, @state.entryPath, {newName}
				@loadEntries()
		return

	onClickEntryDetails: ->
		app.taskRun "C/programs/system/FileDetails",
			params:
				entries: @state.selEntries
		return

	onSubmitForm: (event) ->
		event.preventDefault()
		tmpPath = app.fsPath @state.tmpPath
		unless @state.path is tmpPath
			@load @state.tmpPath
		return

	onClickButtonParent: ->
		entryPath = await app.fsParent @state.entryPath
		@load entryPath
		@setState {entryPath}
		return

	onChangeInputPath: (event) ->
		@setState tmpPath: event.target.value
		return

	disabledOKButton: ->
		entry = @state.selEntries[0]
		@state.selEntries.length and (
			state.params.pickerType is "file" and entry.isDirectory or
			state.params.pickerType is "dir" and entry.isFile
		)

	onClickOKButton: ->
		state.resolve @state.selEntries[0]?.fullPath or @state.path
		return

	componentDidMount: ->
		await @load @state.path
		@pantap = new Pantap @refs.list,
			container: @task.dialog.refs.dialog
			tapRightButton: yes
			panStart: (mx, my) =>
				unless @task.sill.picker
					@setState
						x0: mx
						y0: my
						x1: mx
						y1: my
						isPanning: yes
				return
			panMove: (dx, dy) =>
				@setState
					x1: @state.x1 + dx
					y1: @state.y1 + dy
				return
			panEnd: (mx, my, {offsetX, offsetY, event}) =>
				if event.ctrlKey
					selEntries = [...@state.selEntries]
				else
					selEntries = []
				@refs.main.querySelectorAll(".entry").forEach (el) =>
					{x, y, right, bottom} = el.getBoundingClientRect()
					{x0, y0, x1, y1} = @state
					x -= offsetX
					y -= offsetY
					right -= offsetX
					bottom -= offsetY
					[x0, x1] = [x1, x0] if x0 > x1
					[y0, y1] = [y1, y0] if y0 > y1
					if x1 > x and x0 < right and y1 > y and y0 < bottom
						selEntry = @state.entries[el.dataset.index]
						if event.ctrlKey
							if (index = selEntries.indexOf selEntry) >= 0
								selEntries.splice index, 1
							else
								selEntries.push selEntry
						else
							selEntries.push selEntry
					return
				@setState
					isPanning: no
					selEntries: selEntries
				return
			tap: ({target, el, event}) =>
				if target is el and not event.ctrlKey
					@setState selEntries: []
				return
		return

	render: ->
		<div
			ref="main"
			className="row vertical full p-3"
		>
			<div className="col-0">
				<form onSubmit={@onSubmitForm}>
					<ControlGroup fill>
						<Button
							className="bp3-fixed"
							disabled={@state.path is "/"}
							icon="arrow-up"
							onClick={@onClickButtonParent}
						/>
						<InputGroup
							value={@state.tmpPath}
							onChange={@onChangeInputPath}
						/>
						<Button
							className="bp3-fixed"
							icon="key-enter"
							type="submit"
						/>
					</ControlGroup>
				</form>
			</div>
			<br/>
			<div
				ref="list"
				className="list col overflow-clip"
				onContextMenu={@onContextMenuList}
			>
				<HTMLTable
					interactive={not @state.isPanning}
					sticky
					small
					fill
				>
					<thead>
						<tr>
							<th>Tên</th>
							<th>Loại</th>
							<th>Kích thước</th>
							<th>Sửa đổi lần cuối</th>
						</tr>
					</thead>
					<tbody>
						{@state.entries.map (entry, i) =>
							<tr
								key={entry.name}
								className={@classEntry entry}
								data-index={i}
								onClick={(event) => @onClickEntry event, entry}
								onContextMenu={(event) => @onContextMenuEntry event, entry}
								onDoubleClick={=> @handleDoubleClickEntry entry}
							>
								<td>
									<Icons
										className="mr-3"
										style={color: "#f90" if entry.isDirectory}
										icon={@iconEntry entry}
									/>
									{entry.name}
								</td>
								<td>{@typeEntry entry}</td>
								<td>{entry.isFile and filesize entry.fileObj.size}</td>
								<td>{moment(entry.fileObj.lastModified).format "L LT" if entry.isFile}</td>
							</tr>
						}
					</tbody>
				</HTMLTable>
				{@state.isPanning and
					<div
						className="select-rect fixed z-1"
						style={@styleSelectRect()}
					/>
				}
			</div>
			{if @task.sill.picker
				<div className="bp3-dialog-footer-actions row nowrap">
					<div className="col row middle ellipsis">
						{unless @disabledOKButton()
							"Đường dẫn đã chọn: #{@state.selEntries[0]?.fullPath or @state.path}"
						}
					</div>
					<ButtonGroup className="col-0 right">
						<Button
							onClick={@onClickOKButton}
							intent="primary"
							disabled={@disabledOKButton()}
							text="Chọn"
						/>
						<Button
							onClick={state.close}
							text="Hủy"
						/>
					</ButtonGroup>
				</div>
			}
		</div>

	@params =
		pickerType: "any"
