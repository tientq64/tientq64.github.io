{
	FocusStyleManager
	Classes
	Keys
	Utils
	AbstractComponent
	AbstractPureComponent
	Alignment
	Colors
	Intent
	Position
	ContextMenu
	Alert
	Breadcrumb
	Button
	AnchorButton
	ButtonGroup
	Callout
	Elevation
	Card
	AnimationStates
	Collapse
	CollapseFrom
	CollapsibleList
	ContextMenuTarget
	Dialog
	EditableText
	ControlGroup
	Switch
	Radio
	Checkbox
	FileInput
	FormGroup
	InputGroup
	Label
	NumericInput
	RadioGroup
	TextArea
	H1
	H2
	H3
	H4
	H5
	H6
	Blockquote
	Code
	Pre
	OL
	UL
	Hotkey
	KeyCombo
	HotkeysTarget
	Hotkeys
	Icon
	Menu
	MenuDivider
	MenuItem
	Navbar
	NavbarDivider
	NavbarGroup
	NavbarHeading
	NonIdealState
	Overlay
	Table
	Text
	PopoverInteractionKind
	Popover
	Portal
	ProgressBar
	RangeSlider
	Slider
	Spinner
	Tab
	Expander
	Tabs
	Tag
	TagInput
	Toast
	Toaster
	Tooltip
	Tree
	TreeNode
} = Blueprint.Core

{
	IconContents
	IconNames
	IconSvgPaths16
	IconSvgPaths20
} = Blueprint.Icons

{
	Omnibar
	QueryList
	MultiSelect
	Select
	Suggest
} = Blueprint.Select

{
	DateRangeBoundary
	DateInput
	DatePicker
	DateTimePicker
	DateRangeInput
	DateRangePicker
	TimePicker
	TimePickerPrecision
} = Blueprint.Datetime

Classes = {
	...Blueprint.Core.Classes
	...Blueprint.Select.Classes
	...Blueprint.Datetime.Classes
}

reactElementToJsxString = (el) ->
	if el then reactElementToJsxString el
	else el

setTimer = (timer, cb) => setTimeout cb, timer
app = null
