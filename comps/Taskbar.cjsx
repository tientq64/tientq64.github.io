class Taskbar extends Reactive
	classTaskbar: -> classNames(
		@props.className
		"taskbar row nowrap"
	)

	styleTaskbar: ->
		[app.getTaskbarLocation()]: 0
		height: app.getTaskbarHeight()

	onContextMenuTaskbarTasks: (event) ->
		if event.target is event.currentTarget
			ContextMenu.show(
				<Menu>
					<MenuItem text="Vị trí taskbar">
						<MenuItem
							text="Trên"
							onClick={=> app.setTaskbarLocation "top"}
						/>
						<MenuItem
							text="Dưới"
							onClick={=> app.setTaskbarLocation "bottom"}
						/>
					</MenuItem>
				</Menu>
			)
		return

	handleClickTaskbarTask: (task) ->
		if app.state.taskPid is task.pid
			task.dialog.minimize()
		else
			app.taskFocus task.pid
			if task.dialog.state.isMinimize
				task.dialog.minimize()
		return

	render: ->
		<Navbar
			className={@classTaskbar()}
			style={@styleTaskbar()}
		>
			<NavbarGroup className="col-0">
				<Popover
					position="bottom"
					content={null}
				>
					<Button icon="key-command" minimal/>
				</Popover>
				<NavbarDivider/>
			</NavbarGroup>
			<NavbarGroup
				className="col"
				onContextMenu={@onContextMenuTaskbarTasks}
			>
				{_.map app.tasks, (task) =>
					task.appx and
					<Popover
						key={task.pid}
						targetClassName="taskbar-task-wrap"
						isContextMenu
						position="bottom"
						content={
							<Menu>
								<MenuDivider title={task.dialog.state.name}/>
								<MenuItem
									intent="danger"
									text="Đóng"
									onClick={task.dialog.close}
								/>
							</Menu>
						}
					>
						<Button
							className="taskbar-task taskbar-task-#{task.pid}"
							active={app.state.taskPid is task.pid and not task.dialog.state.isMinimize}
							alignText="left"
							minimal
							icon={<Icons icon={task.dialog.state.icon}/>}
							textClassName="ellipsis"
							text={task.dialog.state.title}
							onClick={=> @handleClickTaskbarTask task}
						/>
					</Popover>
				}
			</NavbarGroup>
			<NavbarGroup className="col-0">
				<NavbarDivider/>
				<TaskbarTray/>
			</NavbarGroup>
		</Navbar>
