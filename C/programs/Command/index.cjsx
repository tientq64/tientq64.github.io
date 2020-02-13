await task.import "https://unpkg.com/filesize@6.0.1/lib/filesize.min.js"

class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@cmds = []
		@cmd = ""
		@path = task.params.path
		@hist = new Hist maxLength: 200
		@inputEl = null

	printTable: (table, heads, pads, rowCb) =>
		text = heads
			.map (head, i) =>
				_.truncate(head, length: pads[i]).padEnd(pads[i], " ")
			.join " "
			.concat "\n"
		text += pads
			.map (pad) =>
				"-".repeat pad
			.join " "
			.concat "\n"
		_.forEach table, (row) =>
			cells = rowCb row
			text += cells
				.map (cell, i) =>
					_.truncate(cell, length: pads[i]).padEnd(pads[i], " ")
				.join " "
				.concat "\n"
			return
		text

	onChangeInput: (event) ->
		@cmd = event.target.value
		@setState {}
		return

	onKeyDownInput: (event) ->
		switch event.key
			when "Enter"
				if cmd = @cmd.trimStart()
					cmdLastIndex = @cmds.length
					@cmd = ""
					@hist.first()
					@hist.back()
					@hist.push cmd
					@hist.push ""
					@cmds[cmdLastIndex] = cmd: "> #{cmd}", result: "...", color: "blue5"
					[cmdName, ...cmd] = cmd.split " "
					cmdName = cmdName.toLowerCase()
					@setState {}, =>
						@refs.cmds.scrollTo 0, @refs.cmds.scrollHeight
						return
					result =
						try
							cmd = window.top.jsyaml.safeLoad "[#{cmd.join " "}]"
							color = "white"
							switch cmdName
								when "tasks"
									@printTable ap.tasks,
										["Tên", "PID", "Đường dẫn"]
										[20, 8, 36]
										(v) => [v.env.name, v.pid, v.env.path]
								when "run"
									await ap.runTask cmd[0], cmd[1]
								when "kill"
									if pid = +cmd[0]
										if ap.killTask pid then "Đã đóng ứng dụng với PID #{pid}"
										else throw "Không tìm thấy ứng dụng với PID #{pid}"
									else throw "PID không hợp lệ"
								when "cd"
									if cmd[0]
										path = ap.pathJoin @path, cmd[0]
										try
											entry = await ap.getEntry path
											if entry.isDirectory
												@path = path
											else throw "Đường dẫn không phải thư mục"
										catch err
											throw err
									else @path
								when "ls"
									dirs = await ap.readDir @path
									@printTable dirs,
										["Tên", "Kích thước", "Ngày sửa đổi"]
										[36, 12, 16]
										(entry) => [
											entry.name
											filesize entry.size
											moment(entry.lastModifiedDate).format("L HH:mm")
										]
								when "read"
									if cmd.length
										await ap.readFile ap.pathJoin @path, cmd[0]
								when "write"
									if cmd.length > 1
										await ap.writeFile ap.pathJoin(@path, cmd[0]), cmd[1..].join(" ")
								when "cls"
									@cmds = []
									""
								when "title"
									if cmd.length
										title = cmd[0..].join " "
										tsk.win.setTitle title
										"Đã đổi tiêu đề cửa sổ"
									else
										tsk.win.title
								when "js"
									if cmd[0]
										res = window.eval "(#{cmd[0..].join " "})"
										switch typeof res
											when "object"
												if res instanceof Date then res
												else (try JSON.stringify res catch then res.constructor)
											when "string"
												"\"#{res}\""
											when "symbol"
												res.toString()
											else res
								when "exit"
									timeout = +cmd[0] or 0
									setTimeout task.close, timeout * 1000
									"Ứng dụng sẽ đóng sau #{timeout}s..."
								when "help"
									if cmd[0]
										cmd[0] = cmd[0].toLowerCase()
										switch cmd[0]
											when "tasks"
												"""
													TASKS
												"""
											when "runtask"
												"""
													RUN path, [args]
													- path          Đường dẫn tập tin ứng dụng (app.yml)
													- args          Tham số truyền vào ứng dụng, là một đôi tượng
													                YAML với các khóa là tên các tham số
												"""
											when "killtask"
												"""
													KILL pid
													- pid           PID của ứng dụng cần đóng
												"""
											when "cd"
												"""
													CD [path]
													- path          Đường dẫn thư mục cần thay đổi, tuyệt đối hoặc
													                tương đối
												"""
											when "read"
												"""
													READ path
													- path          Đường dẫn tập tin cần đọc
												"""
											when "write"
												"""
													WRITE path, data
													- path          Đường dẫn tập tin cần viết
													- data          Dữ liệu cần viết vào
												"""
											when "cls"
												"""
													CLS
												"""
											when "title"
												"""
													TITLE [text]
													- text          Tiêu đề mới
												"""
											when "js"
												"""
													JS code
													- code          Mã JavaScript
												"""
											when "exit"
												"""
													EXIT [timeout=0]
													- timeout       Số giây hẹn giờ đóng cửa sổ này
												"""
											when "help"
												"""
													HELP [cmdName]
													- cmdName       Tên của lệnh cần tra cứu
												"""
											else "Lệnh không xác định"
									else
										"""
											TASKS           Danh sách ứng dụng đang chạy
											RUN             Chạy ứng dụng xác định
											KILL            Đóng ứng dụng xác định
											CD              Thay đổi hoặc trả về thư mục hiện tại
											READ            Đọc tập tin và hiển thị
											WRITE           Viết dữ liệu vào tập tin
											CLS             Xóa màn hình dòng lệnh
											TITLE           Thay đổi hoặc trả về tiêu đề cửa sổ này
											JS              Thực thi mã JavaScript
											EXIT            Đóng cửa sổ này
											HELP            Tra cứu thông tin các lệnh
										"""
								else throw "Lệnh không xác định"
						catch err
							color = "red5"
							err + ""
					result = (result + "") or " "
					if @cmds[cmdLastIndex]
						@cmds[cmdLastIndex].result = result
						@cmds[cmdLastIndex].color = color
					@setState {}, =>
						@refs.cmds.scrollTo 0, @refs.cmds.scrollHeight
						return
			when "ArrowUp"
				event.preventDefault()
				@hist.back (@cmd) =>
					@setState {}, =>
						@inputEl.selectionStart = @cmd.length
						return
					return
			when "ArrowDown"
				event.preventDefault()
				@hist.forward (@cmd) =>
					@setState {}, =>
						@inputEl.selectionStart = @cmd.length
						return
					return
		return

	componentDidMount: ->
		@cmds.push
			cmd: ""
			result: """
				 _____                           _
				|     |___ _____ _____ ___ ___ _| |
				|   --| . |     |     | .'|   | . |
				|_____|___|_|_|_|_|_|_|__,|_|_|___|

				Gõ "help" để xem danh sách các lệnh

			"""
			color: "gray5"
		@setState {}
		return

	render: ->
		<div className="column full select text-code text-wrap bp3-dark bg-dark-gray3">
			<div ref="cmds" className="col scroll m-3 mb-0">
				{@cmds.map ({cmd, result, color}) =>
					<div>
						<div className="text-pre-wrap text-forest5 mb-0">{cmd}</div>
						<div className="text-pre-wrap text-#{color}">{result}</div>
					</div>
				}
			</div>
			<div className="col-0 p-3">
				<InputGroup
					fill
					autoFocus
					inputRef={(@inputEl) =>}
					value={@cmd}
					onChange={@onChangeInput}
					onKeyDown={@onKeyDownInput}
				/>
			</div>
		</div>

	@defaultParams =
		path: "/"
