await task.import [
	"npm:codemirror@5.51.0/lib/codemirror.min.css"
	"npm:codemirror@5.51.0"
	"npm:codemirror@5.51.0/keymap/sublime.min.js"
]

class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@tabs = []
		@tab = null
		@config =
			mode: ""
			lineSeparator: "\n"
			theme: ""
			indentUnit: 2
			smartIndent: yes
			tabSize: 2
			indentWithTabs: yes
			keyMap: "sublime"
			lineWrapping: yes
			lineNumbers: yes
			showCursorWhenSelecting: yes
			spellcheck: no
		@modes = [
			text: "Brainfuck"
			name: "brainfuck"
			exts: ["brainfuck"]
		,
			text: "CoffeeScript"
			name: "coffeescript"
			exts: ["coffee", "cjsx"]
		,
			text: "C"
			name: "clike"
			exts: ["c"]
		,
			text: "C++"
			name: "clike"
			exts: ["cpp"]
		,
			text: "CSS"
			name: "css"
			exts: ["css"]
		,
			text: "Go"
			name: "go"
			exts: ["go"]
		,
			text: "HTML"
			name: "htmlmixed"
			exts: ["html", "htm", "xhtml"]
			depends: ["xml", "javascript", "css"]
		,
			text: "Java"
			name: "clike"
			exts: ["java"]
		,
			text: "JavaScript"
			name: "javascript"
			exts: ["js", "mjs"]
		,
			text: "JSON"
			name: "javascript"
			exts: ["json"]
			options: json: yes
		,
			text: "JSX"
			name: "jsx"
			exts: ["jsx"]
			depends: ["javascript", "xml"]
		,
			text: "Julia"
			name: "julia"
			exts: ["jl"]
		,
			text: "Kotlin"
			name: "clike"
			exts: ["kt"]
		,
			text: "LESS"
			name: "css"
			exts: ["less"]
		,
			text: "LiveScript"
			name: "livescript"
			exts: ["ls"]
		,
			text: "Lua"
			name: "lua"
			exts: ["lua"]
		,
			text: "Markdown"
			name: "markdown"
			exts: ["md"]
		,
			text: "PHP"
			name: "php"
			exts: ["php"]
			depends: ["xml", "javascript", "css", "htmlmixed", "clike"]
		,
			text: "Plain Text"
			name: ""
			exts: ["txt", ""]
		,
			text: "Pug"
			name: "pug"
			exts: ["pug"]
		,
			text: "Python"
			name: "python"
			exts: ["py"]
		,
			text: "Sass"
			name: "sass"
			exts: ["sass", "scss"]
			depends: ["css"]
		,
			text: "SQL"
			name: "sql"
			exts: ["sql"]
		,
			text: "Stylus"
			name: "stylus"
			exts: ["styl"]
		,
			text: "TypeScript"
			name: "javascript"
			exts: ["ts"]
			options: typescript: yes
		,
			text: "Vue"
			name: "vue"
			exts: ["vue"]
			addons: ["mode/overlay", "mode/simple"]
			depends: ["xml", "javascript", "css", "htmlmixed", "pug", "coffeescript", "stylus"]
		,
			text: "XML"
			name: "xml"
			exts: ["xml"]
		,
			text: "YAML"
			name: "yaml"
			exts: ["yml", "yaml"]
		]
		@themes = [
			"3024-day", "3024-night", "abcdef", "ambiance", "ambiance-mobile", "ayu-dark"
			"ayu-mirage", "base16-dark", "base16-light", "bespin", "blackboard", "cobalt"
			"colorforth", "darcula", "dracula", "duotone-dark", "duotone-light", "eclipse"
			"elegant", "erlang-dark", "gruvbox-dark", "hopscotch", "icecoder", "idea", "isotope"
			"lesser-dark", "liquibyte", "lucario", "material", "material-darker", "material-ocean"
			"material-palenight", "mbo", "mdn-like", "midnight", "monokai", "moxer", "neat", "neo"
			"night", "nord", "oceanic-next", "panda-syntax", "paraiso-dark", "paraiso-light"
			"pastel-on-dark", "railscasts", "rubyblue", "seti", "shadowfox", "solarized", "ssms"
			"the-matrix", "tomorrow-night-bright", "tomorrow-night-eighties", "ttcn", "twilight"
			"vibrant-ink", "xq-dark", "xq-light", "yeti", "yonce", "zenburn"
		]
		@addons =
			"edit/closebrackets":
				options:
					autoCloseBrackets: yes
			"edit/matchbrackets":
				options:
					matchBrackets: yes
			"edit/matchtags":
				options:
					matchTags: yes
				depends: ["fold/xml-fold"]
			"edit/trailingspace":
				options:
					showTrailingSpace: yes
			"edit/closetag":
				options:
					autoCloseTags: yes
				depends: ["fold/xml-fold"]
			"fold/xml-fold": null
			"mode/overlay": null
			"mode/simple": null
			"search/searchcursor": null
		@menubar = [
			text: "Tập tin"
			menu: [
				text: "Tập tin mới"
				onClick: =>
					@newTab()
					return
			,
				text: "Mở tập tin..."
				onClick: =>
					entries = await task.pickEntries
						kind: "file"
						multiple: yes
					if entries
						@newTab entry for entry from entries
					return
			,
				text: "Mở thư mục..."
				onClick: =>
					dir = await task.pickEntries
						kind: "dir"
					return
			,
				text: "Lưu"
				disabled: => not @tab
				onClick: =>
					data = @tab.cm.getValue()
					if @tab.entry
						await ap.writeFile @tab.entry.fullPath, data
					else
						entry = await task.saveFile {data}
						if entry
							@tab.entry = entry
					@setState {}
					return
			,
				text: "Lưu thành..."
				disabled: => not @tab or not @tab.entry
				onClick: =>
					data = @tab.cm.getValue()
					entry = await task.saveFile
						data: data
						name: @tab.entry.name
					if entry
						@tab.entry = entry
					@setState {}
					return
			,
				text: "Lưu tất cả"
				disabled: => not @tab
				onClick: =>
					@tabs.forEach (tab) =>
						data = tab.cm.getValue()
						if tab.entry
							ap.writeFile tab.entry.fullPath, data
						else
							if tab.entry = await task.saveFile {data}
								@setState {}
						return
					return
			,,
				text: "Thoát"
				intent: "danger"
				onClick: =>
					task.close()
					return
			]
		,
			text: "Sửa"
			menu: [
				text: "Cắt"
			,
				text: "Sao chép"
			,
				text: "Dán"
			]
		,
			text: "Hiển thị"
			menu: [
				text: "Toàn màn hình"
				label: "F11"
				onClick: =>
					task.fullscreen()
					return
			,,
				text: "Cú pháp"
				disabled: => not @tab
				submenu: [
					...(
						@modes.map (mode) =>
							text: mode.text
							icon: => "dot" if mode.text is @tab?.mode.text
							onClick: =>
								@setModeTab mode
								return
					)
				]
			,
				text: "Thụt lề"
				submenu: [
					text: "Thụt lề sử dụng tab"
					icon: => "tick" if @config.indentWithTabs
					onClick: =>
						@setOption "indentWithTabs", not @config.indentWithTabs
						return
				,,
					..._.range(1, 9).map (val) =>
						text: "Độ rộng tab: #{val}"
						icon: => "dot" if val is @config.tabSize
						onClick: =>
							@setOption "tabSize", val
							return
				]
			]
		,
			text: "Tùy chọn"
			menu: [
				text: "Thay đổi theme..."
				onClick: =>
					theme = await task.popup "select",
						message: "Chọn theme:"
						options: @themes
						inputProps:
							value: @config.theme
					if theme
						@setTheme theme
					return
			]
		]

	setOption: (key, val) ->
		@config[key] = val
		tab.cm?.setOption key, val for tab from @tabs
		@setState {}
		return

	setTheme: (theme) ->
		await task.import "npm:codemirror@5.51.0/theme/#{theme}.min.css"
		@setOption "theme", theme
		@updateStyle()
		return

	setAddon: (addon) ->
		await task.import "npm:codemirror@5.51.0/addon/#{addon}.min.js"
		if addon = @addons[addon]
			if addon.depends
				for depend from addon.depends
					await @setAddon depend
			if addon.options
				for key, val of addon.options
					@setOption key, val
		return

	setModeTab: (mode, tab = @tab) ->
		unless mode
			ext = ap.pathExtname tab.entry?.name or ""
			mode = @modes.find (v) => ext in v.exts
		if mode
			await @loadMode mode
			options = Object.assign
				name: mode.name
				mode.options
			tab.cm.setOption "mode", options
			tab.mode = mode
			@setState {}
		return

	loadMode: (mode) ->
		if mode.addons
			for addon from mode.addons
				await @setAddon addon
		if mode.depends
			for depend from mode.depends
				depend = _.find @modes, name: depend
				await @loadMode depend
		if mode.name
			await task.import "npm:codemirror@5.51.0/mode/#{mode.name}/#{mode.name}.min.js"
		return

	newTab: (entry) ->
		new Promise (resolve) =>
			((id, tab) =>
				tab =
					id: id
					entry: entry
					mode: @modes.find (mode) => mode.text is "Plain Text"
					cm: null
				@tabs.push tab
				@setState {}, =>
					tab.cm = CodeMirror.fromTextArea document.getElementById(id), @config
					if entry
						tab.cm.setValue await ap.readFile entry.fullPath
					tab.cm.on "contextmenu", (event) =>
						@handleContextMenuTab tab
						return
					@updateStyle()
					@focusTab tab
					@setModeTab()
					resolve()
					return
				return
			) "CodeEditor__tabPanelId#{_.uniqueId()}"
			return

	focusTab: (tab) ->
		@tab = tab
		@setState {}, =>
			if tab is @tab
				tab.cm.refresh()
				tab.cm.focus()
			return
		return

	closeTab: (tab) ->
		index = @tabs.indexOf tab
		tab.cm?.toTextArea()
		@tabs.splice index, 1
		if tab is @tab
			if @tabs.length
				@focusTab @tabs[index - 1] or @tabs[0]
			else
				@tab = null
		@setState {}
		return

	updateStyle: ->
		if el = document.querySelector ".CodeMirror"
			{backgroundColor} = getComputedStyle el
			@refs.style.textContent = """
				.cm-tab:after {
					background: #{backgroundColor};
				}
			"""
		return

	handleContextMenuTab: (tab) ->
		menu = [
			text: "Cắt"
		,
			text: "Sao chép"
		,
			text: "Dán"
		,,
			text: "Chọn tất"
			onClick: =>
				tab.cm.execCommand "selectAll"
				tab.cm.focus()
				return
		]
		ap.showContextMenu menu
		tab.cm.focus()
		return

	onChangeTabs: (id, prevId) ->
		tab = _.find @tabs, {id}
		@focusTab tab
		return

	onChangeMode: (event) ->
		if @tab
			mode = @modes.find (v) => v.text is event.target.value
			@setModeTab mode
		return

	componentDidMount: ->
		await Promise.all [
			@setTheme "monokai"
			@setAddon "edit/closebrackets"
			@setAddon "edit/matchbrackets"
			@setAddon "search/searchcursor"
		]
		if task.env.entries.length
			for entry from task.env.entries
				await @newTab entry
		else
			@newTab()
		return

	render: ->
		<div className="column full bg-dark-gray2 text-white">
			<div className="col-0">
				<Menubar className="bg-dark-gray3 text-white" menu={@menubar}/>
			</div>
			<div className="col row bp3-dark">
				<div className="col-3 p-3">1</div>
				<div className="col-9 relative">
					<Tabs
						id="CodeEditor__tabs"
						className="column top full"
						animate={no}
						selectedTabId={@tab?.id}
						onChange={@onChangeTabs}
					>
						{@tabs.map (tab) =>
							<Tab
								id={tab.id}
								className="row middle pl-3 pr-2 mr-0 text-white bp3-menu-width CodeEditor__tab"
								panelClassName="col w-100 mt-0"
								panel={
									<textarea id={tab.id}/>
								}
							>
								<div className="col text-ellipsis">
									{tab.entry?.name or <i className="text-gray3">Tiêu đề trống</i>}
								</div>
								<div className="col-0">
									<Button
										style={zoom: .8}
										icon="cross"
										small
										minimal
										intent="danger"
										onClick={(event) =>
											event.stopPropagation()
											@closeTab tab
											return
										}
									/>
								</div>
							</Tab>
						}
					</Tabs>
				</div>
			</div>
			<div className="col-0 row bp3-dark">
				<div className="col"></div>
				<div className="col-0">
					<HTMLSelect
						small
						minimal
						disabled={not @tab}
						value={@tab?.mode.text}
						onChange={@onChangeMode}
						options={@modes.map (mode) => mode.text}
					/>
				</div>
			</div>
			<style ref="style"/>
		</div>
