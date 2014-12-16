'use strict';

var gulp           = require('gulp');
var $              = require('gulp-load-plugins')();
var mainBowerFiles = require('main-bower-files');
var nib            = require('nib');

var AUTOPREFIXER_BROWSERS = [
'ie >= 10',
'ie_mob >= 10',
'ff >= 30',
'chrome >= 34',
'safari >= 7',
'opera >= 23',
'ios >= 7',
'android >= 4.4',
'bb >= 10'
];

gulp.task('styles', function () {
	return gulp.src('app/styles/main.styl')
	.pipe($.plumber())
	.pipe($.stylus({
		use: nib()
	}))
	.pipe($.autoprefixer({ browsers: AUTOPREFIXER_BROWSERS }))
	.pipe(gulp.dest('.tmp/styles'))
	.pipe($.size());
});

gulp.task('templates', function() {
	gulp.src('app/templates/index.jade')
	.pipe($.plumber())
	.pipe($.jade({pretty: true}))
	.pipe(gulp.dest('app/'));
});

gulp.task('scripts', function () {
	return gulp.src('app/scripts/**/*.coffee')
	.pipe($.plumber())
	.pipe($.coffee())
	.pipe($.jshint())
	.pipe($.jshint.reporter(require('jshint-stylish')))
	.pipe(gulp.dest('.tmp/scripts'))
	.pipe($.size());
});

gulp.task('html', ['styles', 'scripts'], function () {
	var jsFilter = $.filter('**/*.js');
	var cssFilter = $.filter('**/*.css');

	return gulp.src('app/*.html')
	.pipe($.useref.assets({searchPath: '{.tmp,app}'}))
	.pipe(jsFilter)
	.pipe($.uglify())
	.pipe(jsFilter.restore())
	.pipe(cssFilter)
	.pipe($.csso())
	.pipe(cssFilter.restore())
	.pipe($.useref.restore())
	.pipe($.useref())
	.pipe(gulp.dest('dist'))
	.pipe($.size());
});

gulp.task('images', function () {
	return gulp.src('app/images/**/*')
	pipe($.plumber())
	.pipe($.cache($.imagemin({
		optimizationLevel: 3,
		progressive: true,
		interlaced: true
	})))
	.pipe(gulp.dest('dist/images'))
	.pipe($.size());
});

gulp.task('fonts', function () {
	return gulp.src(mainBowerFiles())
	.pipe($.filter('**/*.{eot,svg,ttf,woff}'))
	.pipe($.flatten())
	.pipe(gulp.dest('dist/fonts'))
	.pipe($.size());
});

gulp.task('extras', function () {
	return gulp.src(['app/*.*', '!app/*.html'], { dot: true })
	.pipe(gulp.dest('dist'));
});

gulp.task('clean', function () {
	return gulp.src(['.tmp', 'dist'], { read: false }).pipe($.clean());
});

gulp.task('build', ['html', 'images', 'fonts', 'extras']);

gulp.task('default', ['clean'], function () {
	gulp.start('build');
});

gulp.task('connect', function () {
	var connect = require('connect');
	var app = connect()
	.use(require('connect-livereload')({ port: 35729 }))
	.use(connect.static('app'))
	.use(connect.static('.tmp'))
	.use(connect.directory('app'));

	require('http').createServer(app)
	.listen(9000)
	.on('listening', function () {
		console.log('Started connect web server on http://localhost:9000');
	});
});

gulp.task('serve', ['connect'], function () {
	require('opn')('http://localhost:9000');
});

// inject bower components
gulp.task('wiredep', function () {
	var wiredep = require('wiredep').stream;
	gulp.src('app/*.html')
	.pipe(wiredep({
		directory: 'app/bower_components'
	}))
	.pipe(gulp.dest('app'));
});

gulp.task('watch', ['connect', 'serve'], function () {
	var server = $.livereload();

    // watch for changes

    gulp.watch([
    	'app/*.html',
    	'.tmp/styles/**/*.css',
    	'.tmp/scripts/**/*.js',
    	'app/images/**/*'
    	]).on('change', function (file) {
    		server.changed(file.path);
    	});

    	gulp.watch('app/templates/**/*.jade', ['templates']);
    	gulp.watch('app/styles/**/*.styl', ['styles']);
    	gulp.watch('app/scripts/**/*.coffee', ['scripts']);
    	gulp.watch('app/images/**/*', ['images']);
    	gulp.watch('bower.json', ['wiredep']);
    });
