var 
	gulp = require('gulp'),
	jade = require('gulp-jade'),
	sass = require('gulp-sass'),
	coffee = require('gulp-coffee'),
	concat = require('gulp-concat'),
	plumber = require('gulp-plumber'),
	uglify = require('gulp-uglify'),
	inject = require('gulp-inject'),
	ngAnnotate = require('gulp-ng-annotate'),
	gulpif = require('gulp-if'),
	bowerFiles = require('main-bower-files'),
	browserSync = require('browser-sync'),
	reload = browserSync.reload;

var 
	styles = ['app/assets/vendor/**/*.css', 'app/assets/scss/app.scss'],
	scripts = ['app/**/*.coffee'],
	resources = ['app/assets/{!(scss|vendor), **}/*'];

var args = require('yargs')
  .alias('p', 'prod')
  .default('prod', false)
  .argv;

gulp.task('sass', function() {
	gulp.src(styles)
		.pipe(plumber())
		.pipe(sass(gulpif(args.prod, {outputStyle: 'compressed'})))
		.pipe(concat('app.min.css'))
		.pipe(gulp.dest('./dist/assets/css/'))
		.pipe(reload({stream: true}));
});
gulp.task('coffee', function() {
	gulp.src(scripts)
		.pipe(plumber())
		.pipe(coffee())
		.pipe(concat('app.min.js'))		
		.pipe(ngAnnotate())
		.pipe(gulpif(args.prod, uglify()))
		.pipe(gulp.dest('./dist/'))
		.pipe(reload({stream: true}));
});
gulp.task('jade', function() {
	return gulp.src('app/**/*.jade')
		.pipe(plumber())
		.pipe(jade({pretty: true}))
		.pipe(gulp.dest('./dist/'));
});
gulp.task('bower-inject', ['jade'], function() {
	gulp.src('./dist/index.html')
		.pipe(inject(gulp.src(bowerFiles()), {name: 'bower', addRootSlash: false, relative: true}))
		.pipe(gulp.dest('./dist/'))
		.pipe(reload({stream: true}));
});
gulp.task('resources', function() {
	gulp.src(resources).pipe(gulp.dest('./dist/assets/'));
});
gulp.task('watch', function() {
	gulp.watch('./app/**/*.jade', ['bower-inject']);
	gulp.watch('app/assets/scss/**/*.scss', ['sass']);
	gulp.watch(scripts, ['coffee']);
});
gulp.task('browser-sync', function() {
	browserSync({server: {baseDir: './dist/'}});
});
gulp.task('default', ['watch', 'browser-sync', 'sass', 'coffee', 'bower-inject', 'resources']);