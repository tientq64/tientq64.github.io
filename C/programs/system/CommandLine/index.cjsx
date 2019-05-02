class extends Reactive
	constructor: (props) ->
		super props

		@state =
			val: ""
			entry: app.fs
			logs: []

		@hists = [""]
		@histIndex = 0
		@inputEl = null

	log: (val) ->
		@setState (state) =>
			logs: [...state.logs, val + ""]
		, =>
			@refs.box.scrollTop = @refs.box.scrollHeight
			return
		return

	clear: ->
		@setState => logs: []
		return

	pad: (text, length) ->
		_.padEnd _.truncate(text, {length}), length

	onKeyDownInput: (event) ->
		switch event.key
			when "Enter"
				if val = @state.val.trim()
					@log val
					@histIndex = 0
					unless val is @hists[1]
						@hists.splice 1, 0, val
					val = val.split " "
					val[0] = val[0].toLowerCase()
					try
						switch val[0]
							when "cd"
								if val[1]
									@setState entry: await app.fsCd @state.entry, val[1], 2
									@log @state.entry.fullPath
								else
									@log @state.entry.fullPath
							when "clear"
								@clear()
							when "exit"
								setTimeout state.close, 500
								@log "..."
							when "help"
								@log """
									CD path?      Hiển thị hoặc thay đổi thư mục hiện tại
									CLEAR         Xóa màn hình dòng lệnh
									EXIT          Thoát
									HELP          Hiển thị danh sách các lệnh
									KILL pid      Đóng ứng dụng với PID xác định
									LOG msg?      Hiển thị một tin nhắn
									LS            Hiển thị danh sách các mục trong thư mục hiện tại
									READ path     Đọc một tập tin trong thư mục hiện tại
									RUN path      Khởi chạy ứng dụng với đường dẫn xác định
									TASKS         Hiển thị danh sách các ứng dụng đang chạy
									TITLE val?    Hiển thị hoặc thay đổi tiêu đề cửa sổ này
								"""
							when "kill"
								pid = +val[1]
								@log app.tasks[pid]?.dialog.close() and
									"Đã đóng ứng dụng ##{pid}" or
									"Không tìm thấy ứng dụng ##{pid}"
							when "log"
								@log val[1..].join " "
							when "ls"
								@log (await app.fsGets @state.entry).map((v) => v.name).join "\n"
							when "read"
								@log await app.fsRead await app.fsCd @state.entry, val[1], 1
							when "run"
								@log await app.taskRun val[1]
							when "tasks"
								@log(
									"Name               PID    Path                                \n" +
									"================== ====== ====================================\n" +
									_.map app.tasks, (task) => "
										#{@pad task.sill.name, 18}
										#{@pad task.pid, 6}
										#{@pad task.path, 36}"
									.join "\n"
								)
							when "title"
								{dialog} = app.tasks[PID]
								if val[1]
									@log dialog.setTitle val[1..].join " "
								else
									@log dialog.state.title
							else
								@log "Lệnh không xác định"
					catch e
						@log e.message
					@setState val: ""
			when "ArrowUp"
				if @histIndex < @hists.length - 1
					val = @hists[++@histIndex]
					@setState {val}, =>
						setTimeout =>
							@inputEl.selectionStart = @inputEl.selectionEnd = val.length
							return
						return
			when "ArrowDown"
				if @histIndex > 0
					val = @hists[--@histIndex]
					@setState {val}, =>
						setTimeout =>
							@inputEl.selectionStart = @inputEl.selectionEnd = val.length
							return
						return
		return

	render: ->
		<div ref="box" className="box full p-3 scrollable-y">
			{@state.logs.map (log, i) =>
				<pre key={i} className="px-3 m-0 selectable">{log}</pre>
			}
			<InputGroup
				className="input"
				inputRef={(el) => @inputEl = el}
				autoFocus
				placeholder="Gõ 'help' để hiển thị danh sách các lệnh"
				value={@state.val}
				onChange={(event) => @setState val: event.target.value}
				onKeyDown={@onKeyDownInput}
			/>
		</div>
