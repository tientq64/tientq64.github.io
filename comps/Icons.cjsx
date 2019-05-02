class Icons extends Reactive
	classIcon: -> classNames(
		@props.className
		"bp3-icon fa-" + @props.icon
	)

	render: ->
		if /\ fa[rsb]?$/.test @props.icon
			<i {...@props} className={@classIcon()}/>
		else
			<Icon {...@props} icon={@props.icon}/>
