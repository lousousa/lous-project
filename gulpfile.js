var 
	gulp = require('gulp'),
	concat = require('gulp-concat'),
	plumber = require('gulp-plumber'),
	sass = require('gulp-sass'),
	uglify = require('gulp-uglify'),
	jade = require('gulp-jade'),
	inject = require('gulp-inject'),
	ngAnnotate = require('gulp-ng-annotate'),
	bowerFiles = require('main-bower-files'),
	browserSync = require('browser-sync'),
	reload = browserSync.reload;

var 
	styles = ['app/assets/vendor/**/*.css', 'app/assets/scss/app.scss'],
	scripts = ['app/scripts/**/*.js'],
	resources = ['app/assets/{!(scss|vendor), **}/*'];

gulp.task('styles', function() {
	return gulp.src(styles)
		.pipe(plumber())
		.pipe(sass({outputStyle: 'compressed'}))
		.pipe(concat('app.min.css'))
		.pipe(gulp.dest('./dist/assets/css/'))
		.pipe(reload({stream: true}));
});
gulp.task('scripts', function() {
	return gulp.src(scripts)
		.pipe(plumber())
		.pipe(ngAnnotate())
		.pipe(uglify())
		.pipe(concat('app.min.js'))
		.pipe(gulp.dest('./dist/scripts/'))
		.pipe(reload({stream: true}));
});
gulp.task('templates', function() {
	return gulp.src('app/**/*.jade')
		.pipe(plumber())
		.pipe(jade({pretty: true}))
		.pipe(gulp.dest('./dist/'))
		.pipe(reload({stream: true}));
});
gulp.task('bower-inject', ['templates'], function() {
	gulp.src('./dist/index.html')
		.pipe(inject(gulp.src(bowerFiles()), {name: 'bower', addRootSlash: false, relative: true}))
		.pipe(gulp.dest('./dist/'));
});
gulp.task('resources', function() {
	return gulp.src(resources).pipe(gulp.dest('./dist/assets/'));
});
gulp.task('watch', ['styles', 'scripts', 'bower-inject', 'resources'], function() {
	gulp.watch('./app/**/*.jade', ['bower-inject']);
	gulp.watch(styles, ['styles']);
	gulp.watch(scripts, ['scripts']);
});
gulp.task('browser-sync', function() {
	browserSync({server: {baseDir: './dist/'}});
});
gulp.task('default', ['watch', 'browser-sync']);