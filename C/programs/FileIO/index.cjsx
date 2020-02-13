class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@list = []
		@disabledUpload = no

	onClickUpload: (event) ->
		@disabledUpload = yes
		@setState {}
		entries = await task.pickReadOnlyEntries
			kind: "file"
			multiple: yes
		if entries
			newList = []
			for entry from entries
				item =
					entry: entry
					fileio: null
				newList.push item
				@list.push item
			@setState {}
			for item from newList
				formData = new FormData
				formData.append "file", item.entry.file
				item.fileio = await fetch2 "https://file.io/?expires=1w",
					method: "post"
					body: formData
					"json"
				@setState {}
		@disabledUpload = no
		@setState {}
		return

	onClickReceive: (event) ->
		key = await task.prompt "Nhập key tập tin:",
			max: 6
			pattern: /[a-zA-Z0-9]{6}/
		if key
			res = await fetch "https://file.io/#{key}"
			if res.ok
				data = await res.arrayBuffer()
				ap.saveFile {data, name: key}
			else
				task.alert "Không tìm thấy tập tin"
		return

	render: ->
		<div className="column full p-3 text-center">
			<H3 className="col-0 mt-2">Chia sẻ tập tin</H3>
			<p className="col text-left scroll">
				<HTMLTable className="text-ellipsis" fill fixed small interactive>
					<thead>
						<tr>
							<th className="col-8">Tên tập tin</th>
							<th className="col-4">Key</th>
						</tr>
					</thead>
					<tbody>
						{@list.map (item) =>
							<tr className="middle" style={height: 32}>
								<td className="col-8">{item.entry.name}</td>
								<td className="col-4">
									{if item.fileio
										if item.fileio.success
											<InputGroup
												inputClassName="h-100"
												selectAllOnFocus
												value={item.fileio.key}
											/>
										else
											<div className="text-red3">Lỗi: {item.fileio.message}</div>
									else
										<div class="text-gray3">Đang tải lên...</div>
									}
								</td>
							</tr>
						}
					</tbody>
				</HTMLTable>
			</p>
			<div className="col-0">
				<p>
					<Button
						disabled={@disabledUpload}
						icon="export"
						text="Tải lên tập tin..."
						onClick={@onClickUpload}
					/>
					<Button
						className="ml-2"
						icon="import"
						text="Nhận một tập tin..."
						onClick={@onClickReceive}
					/>
				</p>
				<div>Sử dụng API của <a href="https://file.io">file.io</a></div>
			</div>
		</div>
