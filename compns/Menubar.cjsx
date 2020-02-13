class Menubar extends React.Component
	constructor: (props) ->
		super props

		@isOpens = @props.menu.map (item) => no

	render: ->
		<Navbar {...@props} className="bp3-menubar px-2 py-1 #{@props.className}">
			{@props.menu?.map (item, i) =>
				if item.menu
					<Popover
						key={i}
						popoverClassName="bp3-menubar-popover"
						minimal
						isOpen={@isOpens[i]}
						position="bottom-left"
						onInteraction={(isOpen) =>
							@isOpens[i] = isOpen
							@setState {}
							return
						}
						content={(app.menuToJsx or task.menuToJsx) item.menu, null, =>
							@isOpens[i] = no
							@setState {}
							return
						}
					>
						<Button small minimal text={item.text}/>
					</Popover>
				else
					<Button key={i} small minimal text={item.text}/>
			}
		</Navbar>
