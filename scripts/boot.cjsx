{
	CSSTransition, ReplaceTransition, Transition, TransitionGroup
} = ReactTransitionGroup
{
	AbstractComponent, AbstractPureComponent, Alert, Alignment, AnchorButton
	AnimationStates, Blockquote, Boundary, Breadcrumb, Button, ButtonGroup, Callout
	Card, Checkbox, Code, Collapse, CollapsibleList, Colors, ContextMenu
	ContextMenuTarget, ControlGroup, Divider, Dialog, EditableText, Elevation
	Expander, FileInput, FocusStyleManager, FormGroup, H1, H2, H3, H4, H5, H6
	HTMLSelect, HTMLTable, HandleInteractionKind, HandleType, Hotkey, Hotkeys
	HotkeysTarget, Icon, InputGroup, Intent, KeyCombo, Keys, Label, Menu, MenuDivider
	MenuItem, MultiSlider, Navbar, NavbarDivider, NavbarGroup, NavbarHeading
	NonIdealState, NumericInput, OL, OverflowList, Overlay, PanelStack, Popover
	PopoverInteractionKind, Portal, Position, Pre, ProgressBar, Radio, RadioGroup
	RangeSlider, ResizeSensor, Slider, Spinner, Switch, Tab, Tabs, Tag, TagInput
	Text, TextArea, Toast, Toaster, Tooltip, Tree, TreeNode, UL, Utils, comboMatches
	getKeyCombo, getKeyComboString, hideHotkeysDialog, isPositionHorizontal
	isPositionVertical, parseKeyCombo, removeNonHTMLProps, setHotkeysDialogProps
} = Blueprint.Core
{
	IconContents, IconNames, IconSvgPaths16, IconSvgPaths20
} = Blueprint.Icons
{
	MultiSelect, Omnibar, QueryList, Select, Suggest, getFirstEnabledItem
	renderFilteredItems
} = Blueprint.Select
{
	DateInput, DatePicker, DateRangeInput, DateRangePicker, DateTimePicker
	TimePicker, TimePrecision
} = Blueprint.Datetime

app = null

uuidv4 = ->
	"_#{Date.now()}_#{_.uniqueId()}_#{_.random 9e9}_#{_.random 9e9}"

autoBind = (self, ctor = self.constructor) ->
	for key from Object.getOwnPropertyNames ctor::
		prop = self[key]
		unless typeof prop isnt "function" or
		(prop + "").startsWith("class ") or
		prop.name.startsWith("bound ")
			self[key] = prop.bind self
	return

class Hist
	constructor: ({@list = [], @index = 0, @maxLength = Infinity} = {}) ->
	canBack: ->
		@index < @list.length - 1
	canForward: ->
		@index > 0
	back: (cb) ->
		if @canBack()
			@index++
			cb? @list[@index]
		return
	last: (cb) ->
		if @canBack()
			@index = @list.length - 1
			cb? @list[@index]
		return
	forward: (cb) ->
		if @canForward()
			@index--
			cb? @list[@index]
		return
	first: (cb) ->
		if @canForward()
			@index = 0
			cb? @list[@index]
		return
	push: (data, cb) ->
		if @index
			@list.splice 0, @index
			@index = 0
		if not @list.length or @list[0] isnt data
			@list.unshift data
			@list.pop() if @list.length > @maxLength
			cb? data
		return
	clear: ->
		if @list.length
			@list = []
			@index = 0
		return

ContextMenu.show = (menu, onClose, isDarkTheme = app.state.darkTheme) =>
	ContextMenu.show2 menu, left: app.mouse.x, top: app.mouse.y, onClose, isDarkTheme
	return

Toaster.toast = Toaster.create
	position: "bottom-right"
Toaster.show = (message, props) =>
	Toaster.toast.show {message, ...props}
Toaster.clear = =>
	Toaster.toast.clear()

window.ContextMenu = ContextMenu

FocusStyleManager.onlyShowFocusOnTabs()

window.addEventListener "contextmenu", (event) =>
	event.preventDefault()
	return
, yes

window.addEventListener "keydown", (event) =>
	{ctrlKey, shiftKey, altKey} = event
	if ctrlKey and !shiftKey and !altKey
		if /^(Key[SDF])$/.test event.code
			event.preventDefault()
	return
