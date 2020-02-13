Blueprint.Core._FileInput = Blueprint.Core.FileInput

class FileInput extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@kindText = {dir: "thư mục", file: "tập tin"}[@props.kind] or "mục"
		@text = "Chọn #{@kindText}..."
		@entries = null
		@id = uuidv4()
		@selecting = no

	classMain: ->
		classNames
			"bp3-large": @props.large
			"bp3-fill": @props.fill
			"bp3-file-input-has-selection": @entries

	onClickMain: (event) ->
		unless @props.disabled or @selecting
			@selecting = yes
			func =
				if WIN
					if @props.readOnly then task.pickReadOnlyEntries
					else task.pickEntries
				else app.pickEntries
			entries = await func
				kind: @props.kind in ["dir", "file"] and @props.kind or "entry"
				multiple: @props.multiple
			if entries
				@entries = entries
				entries = _.castArray entries
				@text =
					if entries.length is 1 then entries[0].name
					else "Đã chọn #{entries.length} #{@kindText}"
				@props.onChange? entries
				@setState {}
			@selecting = no
		return

	render: ->
		if @props.external
			<Blueprint.Core._FileInput {...@props}/>
		else
			<div
				id={@id}
				className="bp3-file-input FileInput__main #{@classMain()}"
				onClick={@onClickMain}
			>
				<input
					type="file"
					disabled={@props.disabled}
				/>
				<span className="bp3-file-upload-input">{@text}</span>
				<style>
					#{@id} .bp3-file-upload-input:after &#123;
						content: "{@props.buttonText or 'Chọn'}"
					&#125;
				</style>
			</div>

	@defaultProps =
		kind: "entry"

Blueprint.Core.FileInput = FileInput
