gulp = require "gulp"
jade = require "gulp-jade"
sass = require "gulp-sass"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
plumber = require "gulp-plumber"
uglify = require "gulp-uglify"
inject = require "gulp-inject"
gulpif = require "gulp-if"
yargs = require "yargs"
bowerFiles = require "main-bower-files"
browserSync = require "browser-sync"
reload = browserSync.reload

glob = {
	coffee: "./app/**/*.coffee"
	sass: "./app/**/*.scss"
	jade: "./app/**/*.jade"
	files2Copy: ["./app/assets/{!(scss), **}/{!(*.coffee|*.scss|*.jade), *.*}"]
}

args = yargs
	.alias "p", "prod"
	.default "prod", false
	.argv

altExt = if args.prod then ".min" else ""

gulp.task "copy-files", ->
	gulp.src glob.files2Copy
		.pipe gulp.dest "./dist/assets/"
	return

gulp.task "coffee", ->
	gulp.src glob.coffee
		.pipe plumber()
		.pipe coffee()
		.pipe concat "app#{altExt}.js"
		.pipe gulpif args.prod, uglify {mangle: false}
		.pipe gulp.dest "./dist/"
		.pipe reload {stream: true}
	return
		
gulp.task "sass", ->
	gulp.src glob.sass
		.pipe plumber()
		.pipe sass gulpif args.prod, {outputStyle: "compressed"}
		.pipe concat "app#{altExt}.css"
		.pipe gulp.dest "./dist/assets/"
		.pipe reload {stream: true}
	return

gulp.task "jade", ->
	gulp.src glob.jade
		.pipe plumber()
		.pipe jade gulpif not args.prod, {pretty: true}
		.pipe gulp.dest "./dist/"

gulp.task "inject", ["jade"], ->
	gulp.src "./dist/index.html"
		.pipe inject gulp.src(["./dist/assets/app#{altExt}.css", "./dist/app#{altExt}.js"]), {name: "app", addRootSlash: false, relative: true}
		.pipe inject gulp.src(bowerFiles()), {name: "bower", addRootSlash: false, relative: true}
		.pipe gulp.dest "./dist"
		.pipe reload {stream: true}
	return
	
gulp.task "watch", ->
	gulp.watch glob.coffee, ["coffee"]
	gulp.watch glob.sass, ["sass"]
	gulp.watch glob.jade, ["inject"]
	return

gulp.task "browser-sync", ->
	browserSync {server: {baseDir: "./dist/"}}
	return

gulp.task "build", ["sass", "coffee", "inject", "copy-files"]

gulp.task "default", ["build", "watch", "browser-sync"]