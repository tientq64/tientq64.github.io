class Icons extends React.Component
	constructor: (props) ->
		super props

	classIcon: ->
		classNames @props.className

	render: ->
		{icon} = @props
		if icon.includes ":"
			icon = icon.split ":"
			if /^(fa[srb]?)$/.test icon[0]
				<i className="bp3-icon #{icon[0]} fa-#{icon[1]} #{@classIcon()}"/>
		else
			<Icon {...@props}/>
