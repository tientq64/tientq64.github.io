class Icons8 extends React.Component
	render: ->
		<img
			className="bp3-icon"
			src={
				if @props.icon instanceof Element or /https?\:\/\//.test @props.icon
					@props.icon
				else
					"https://png.icons8.com/#{@props.type}/#{@props.size}/#{@props.color}/#{@props.icon}.png"
			}
		/>

	@defaultProps:
		type: "material-rounded"
		color: "5c7080"
		size: 20
