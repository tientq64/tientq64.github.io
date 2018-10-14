fs = require "fs"
coffee = require "./libs/coffee.min"
stylus = require "./libs/stylus.min"
babel = require "./libs/babel.min"
uglify = require "./libs/uglify.min"

js = ""
css = ""
minified = no

read = (path) =>
	fs.readFileSync path, "utf-8"

dirs = fs.readdirSync "components"

js += read "scripts/declare.cjsx"
css += read "main.styl"

for dir from dirs
	js += read "components/#{dir}/index.cjsx"
	if fs.existsSync "components/#{dir}/index.styl"
		css += read "components/#{dir}/index.styl"

js += read "scripts/main.cjsx"

css = stylus.render css

js = babel.transform(
	coffee.compile js, bare: yes
	presets: ["react"]
	plugins: ["syntax-object-rest-spread"]
).code

if minified
	js = uglify.minify js,
		ecma: 8
		ie8: no
		toplevel: yes
		compress:
			dead_code: yes
			unused: no
			unsafe_arrows: yes
			unsafe_comps: no
			unsafe_Function: yes
			unsafe_math: yes
			unsafe_methods: yes
			unsafe_proto: yes
			unsafe_regexp: no
		mangle:
			reserved: []
	.code

js = "(function(){#{js}})();"

fs.writeFileSync "index.js", js
fs.writeFileSync "index.css", css
