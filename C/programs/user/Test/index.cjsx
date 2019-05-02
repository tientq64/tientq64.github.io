class extends Reactive
	constructor: (props) ->
		super props

		@state =
			num: 45

	render: ->
		<div className="scrollable p-3">
			<Button text={state.getLang()}/>
			<Button intent="primary" text="Primary"/>
			<Button intent="success" text="Success"/>
			<Button intent="warning" text="Warning"/>
			<Button intent="danger" text="Danger"/>
			<Button intent="danger" text="Close" onClick={state.close}/>
			<Button
				intent="success"
				text="Context menu"
				onContextMenu={=>
					ContextMenu.show(
						<Menu>
							<MenuItem text="Heelo"/>
						</Menu>
					)
				}
			/>
			<Popover
				content={
					<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum neque commodi cum maxime excepturi et laboriosam officiis numquam delectus, nostrum odio inventore placeat consectetur dignissimos at, ut aspernatur iure repudiandae.</p>
				}
			>
				<Button text="Popover"/>
			</Popover>
			<Menu>
				<MenuDivider title="Edit"/>
				<MenuItem
					icon="cut"
					text="Cut"
					label="Ctrl+C"
				/>
				<MenuItem
					icon="clipboard"
					text="Paste"
					label="Ctrl+V"
					disabled
				/>
				<MenuItem
					icon="trash"
					text="Detele"
					label="Delete"
					intent="danger"
				/>
				<MenuDivider title="Tools"/>
				<MenuItem
					text="Build"
					label="Ctrl+B"
				/>
				<MenuItem text="Build with..."/>
				<MenuDivider/>
				<MenuItem
					icon="bookmark"
					text="Add bookmark..."
				/>
				<MenuItem
					icon="code"
					text="Languages"
				>
					<MenuItem
						text="HTML5"
						intent="danger"
					>
						<MenuItem
							icon="link"
							text="Learn HTML5"
							href="https://w3schools.com/html"
						/>
					</MenuItem>
					<MenuItem
						text="CSS3"
						intent="primary"
					/>
					<MenuItem
						text="JavaScript"
						intent="warning"
					/>
				</MenuItem>
			</Menu>
			<ProgressBar value={.64}/>
			<br/>
			<ProgressBar value={.64} intent="danger"/>
			<br/>
			<Code>span</Code>
			<br/><br/>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Modi saepe nisi, dolorum vitae suscipit at est doloribus dolorem magnam esse error nulla, natus vel tempora aliquam soluta, necessitatibus veritatis ipsa!</p>
		</div>
