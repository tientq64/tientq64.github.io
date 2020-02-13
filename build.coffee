fs = require "fs"
root = "F:/JS/ThwOS"

Paths =
	compns: []
	compnsSystem: []
	fs: []
readdir = (path, list, deep) =>
	entries = fs.readdirSync "#{root}/#{path}", withFileTypes: yes
	if entries.length
		for entry from entries
			entryPath = "#{path}/#{entry.name}"
			if entry.isFile()
				list.push entryPath
			else if deep
				readdir entryPath, list, deep
	else
		list.push "#{path}/"
	return
readdir "compns", Paths.compns
readdir "compns/system", Paths.compnsSystem
readdir "C", Paths.fs, yes
readdir "A", Paths.fs, yes
fs.writeFileSync "#{root}/paths.json", JSON.stringify Paths
