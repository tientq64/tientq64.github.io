await task.import [
	"util.js", "core.js", "arm.js", "thumb.js", "mmu.js", "io.js"
	"audio.js", "video.js", "video/proxy.js", "video/software.js"
	"irq.js", "keypad.js", "savedata.js", "gpio.js", "gba.js"
]

class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@gba = null

	loadRomFromFile: (file) ->
		@gba.pause()
		@gba.reset()
		@gba.loadRomFromFile file, (result) =>
			@gba.runStable() if result
			return
		return

	componentDidMount: ->
		GameBoyAdvance.workerURL = await task.readFile "video/worker.js", "DataURL"
		@gba = new GameBoyAdvance
		@gba.setCanvas @refs.canvas
		@gba.setBios await task.readFile "resources/bios.bin", "ArrayBuffer"
		@loadRomFromFile entry.file if entry = task.env.entries[0]
		return

	render: ->
		<div className="column full bg-black">
			<div className="col-0">
				<Menubar className="bg-dark-gray3 text-white" menu={[
					text: "Tập tin"
					menu: [
						text: "Nhập tập tin ROM..."
						onClick: =>
							if entry = await task.pickReadOnlyEntries kind: "file"
								@loadRomFromFile entry.file
							return
					,
						text: "Thoát"
						onClick: =>
							task.close()
							return
					]
				,
					text: "Trợ giúp"
					menu: [
						text: "Bàn phím"
						onClick: =>
							task.alert """
								<div class="row">
									<p class="col-6">Up</p>
									<p class="col-6"><kbd>&uarr;</kbd></p>
									<p class="col-6">Down</p>
									<p class="col-6"><kbd>&darr;</kbd></p>
									<p class="col-6">Left</p>
									<p class="col-6"><kbd>&larr;</kbd></p>
									<p class="col-6">Right</p>
									<p class="col-6"><kbd>&rarr;</kbd></p>
									<p class="col-6">A</p>
									<p class="col-6"><kbd>Z</kbd></p>
									<p class="col-6">B</p>
									<p class="col-6"><kbd>X</kbd></p>
									<p class="col-6">L</p>
									<p class="col-6"><kbd>A</kbd></p>
									<p class="col-6">R</p>
									<p class="col-6"><kbd>S</kbd></p>
									<p class="col-6">Start</p>
									<p class="col-6"><kbd>Enter</kbd></p>
									<p class="col-6">Select</p>
									<p class="col-6"><kbd>\\</kbd></p>
								</div>
							""", yes
							return
					]
				]}/>
			</div>
			<div className="col relative flex center middle">
				<canvas ref="canvas" className="img-pixelated" width={480} height={320}>
					Không hỗ trợ HTML5 Canvas
				</canvas>
			</div>
		</div>
