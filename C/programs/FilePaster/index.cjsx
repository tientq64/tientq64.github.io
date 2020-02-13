class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@entries = task.env.entries
		@alter = task.params.alter
		@alterFn = @alter is "copy" and "copyPath" or "movePath"
		@path = task.params.path
		@alterEntry = null

	componentDidMount: ->
		question = yes
		for entry from @entries
			@alterEntry = entry
			@setState {}
			newPath = ap.pathJoin @path, entry.name
			unless entry.fullPath is newPath and @alter is "move"
				if question and await ap.existsPath newPath
					mode = await ap.popup "buttons",
						message: "Tập tin \"#{entry.name}\" đã tồn tại"
						cols: 2
						options: [
							label: "Ghi đè"
							value: "override"
						,
							label: "Ghi đè tất cả"
							value: "overrideAll"
						,
							label: "Đổi tên"
							value: "rename"
						,
							label: "Đổi tên tất cả"
							value: "renameAll"
						,
							label: "Bỏ qua"
							value: "skip"
						,
							label: "Bỏ qua tất cả"
							value: "skipAll"
						]
					mode ?= "skip"
					if mode.endsWith "All"
						mode = mode.replace "All", ""
						question = no
				switch mode
					when "rename"
						basename = ap.pathBasename entry.name
						extname = ap.pathExtname entry.name, yes
						n = 0
						while await ap.existsPath newPath
							filename = "#{basename} (#{++n})#{extname}"
							newPath = ap.pathJoin @path, filename
						await ap[@alterFn] entry.fullPath, newPath
					when "skip" then break
					else await ap[@alterFn] entry.fullPath, newPath
		task.close()
		return

	render: ->
		<div className="p-3">
			{if @alterEntry
				<p>{@alterEntry.fullPath}</p>
			}
		</div>
