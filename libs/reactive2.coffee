class Reactive extends React.Component
	constructor: (props) ->
		super props

		for k from Object.getOwnPropertyNames @constructor::
			if typeof @[k] is "function"
				@[k] = @[k].bind @

	setStateAsync: (state) ->
		new Promise (resolve) =>
			@setState state, resolve
			return
