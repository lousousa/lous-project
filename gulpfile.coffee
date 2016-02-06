gulp = require 'gulp'
jade = require 'gulp-jade'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
plumber = require 'gulp-plumber'
uglify = require 'gulp-uglify'
inject = require 'gulp-inject'
ngAnnotate = require 'gulp-ng-annotate'
gulpif = require 'gulp-if'
yargs = require 'yargs'
bowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'
reload = browserSync.reload

glob = {
	coffee: './app/**/*.coffee'
	sass: './app/**/*.scss'
	jade: './app/**/*.jade'
	files2Copy: ['./app/assets/{!(scss), **}/{!(*.coffee|*.scss|*.jade), *.*}']
}

args = yargs
	.alias 'p', 'prod'
	.default 'prod', false
	.argv

gulp.task 'copy-files', ()->
	gulp.src glob.files2Copy
		.pipe gulp.dest './dist/assets/'

gulp.task 'coffee', ()->
	gulp.src glob.coffee
		.pipe plumber()
		.pipe coffee()
		.pipe concat 'app.min.js'
		.pipe ngAnnotate()
		.pipe gulpif args.prod, uglify()
		.pipe gulp.dest './dist/'
		.pipe reload {stream: true}
		
gulp.task 'sass', ()->
	gulp.src glob.sass
		.pipe plumber()
		.pipe sass gulpif args.prod, {outputStyle: 'expanded'}
		.pipe concat 'app.min.css'
		.pipe gulp.dest './dist/assets/'
		.pipe reload {stream: true}

gulp.task 'jade', ()->
	gulp.src glob.jade
		.pipe plumber()
		.pipe jade {pretty: true}
		.pipe gulp.dest './dist/'

gulp.task 'bower-inject', ['jade'], ()->
	gulp.src './dist/index.html'
		.pipe inject gulp.src(bowerFiles()), {name: 'bower', addRootSlash: false, relative: true}
		.pipe gulp.dest './dist'
		.pipe reload {stream: true}
	
gulp.task 'watch', ()->
	gulp.watch glob.coffee, ['coffee']
	gulp.watch glob.sass, ['sass']
	gulp.watch glob.jade, ['bower-inject']

gulp.task 'browser-sync', ()->
	browserSync {server: {baseDir: './dist/'}}

gulp.task 'build', ['sass', 'coffee', 'bower-inject', 'copy-files']

gulp.task 'default', ['build', 'watch', 'browser-sync']