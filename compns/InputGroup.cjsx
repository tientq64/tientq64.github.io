Blueprint.Core._InputGroup = Blueprint.Core.InputGroup

class InputGroup extends Blueprint.Core._InputGroup
	constructor: (props) ->
		super props
		autoBind @

		@inputEl = null

	inputRef: (@inputEl) =>
		@props.inputRef? @inputEl
		return

	onCut: (event) ->
		if data = getSelection() + ""
			ap.addClipboard data
		@props.onCut? event
		return

	onCopy: (event) ->
		if data = getSelection() + ""
			ap.addClipboard data
		@props.onCopy? event
		return

	onPaste: (event) ->
		event.preventDefault()
		if data = await ap.getClipboard()
			document.execCommand "insertText", no, data
			@props.onPaste? event
		return

	onContextMenu: (event) ->
		ap.showContextMenu [
			text: "Hoàn tác"
			icon: "undo"
			label: "Ctrl+Z"
			onClick: =>
				document.execCommand "undo"
				@inputEl.focus()
				return
		,
			text: "Làm lại"
			icon: "redo"
			label: "Ctrl+Shift+Z"
			onClick: =>
				document.execCommand "redo"
				@inputEl.focus()
				return
		,,
			text: "Cắt"
			icon: "cut"
			label: "Ctrl+X"
			onClick: =>
				document.execCommand "cut"
				@inputEl.selectionEnd = @inputEl.selectionStart
				@inputEl.focus()
				return
		,
			text: "Sao chép"
			icon: "duplicate"
			label: "Ctrl+C"
			onClick: =>
				document.execCommand "copy"
				@inputEl.focus()
				return
		,
			text: "Dán"
			icon: "clipboard"
			label: "Ctrl+V"
			onClick: =>
				@onPaste new ClipboardEvent "paste"
				@inputEl.focus()
				return
		,
			text: "Chọn tất cả"
			label: "Ctrl+A"
			onClick: =>
				@inputEl.select()
				@inputEl.focus()
				return
		]
		@props.onContextMenu? event
		return

	onFocus: (event) ->
		if @props.selectAllOnFocus
			if @inputEl
				@inputEl.selectionEnd = @inputEl.selectionStart
				@inputEl.select()
		@props.onFocus? event
		return

	render: ->
		<Blueprint.Core._InputGroup
			{...@props}
			inputRef={@inputRef}
			onCut={@onCut}
			onCopy={@onCopy}
			onPaste={@onPaste}
			onContextMenu={@onContextMenu}
			onFocus={@onFocus}
		/>

Blueprint.Core.InputGroup = InputGroup
