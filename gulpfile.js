var gulp = require("gulp")
var webServer = require("gulp-webserver")
var sourceMaps = require("gulp-sourcemaps")
var plumber = require("gulp-plumber")
var wrapCommonJS = require("gulp-wrap-commonjs")
var concat = require("gulp-concat")
var gif = require("gulp-if")
var del = require("del")
var runSequence = require("gulp-run-sequence")
var coffee = require("gulp-coffee")
var gutil = require("gulp-util")
var sass = require("gulp-sass")

var scriptsPath = "./src/**/*.coffee"
var vendorPath = "./src/vendor/**/*.js"
var stylesPath = "./src/**/*.scss"

gulp.task("build-scripts", function () {
  return gulp.src(scriptsPath)
    .pipe(plumber())
    .pipe(sourceMaps.init())
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(wrapCommonJS({
      pathModifier: function (path) {
        path = path.replace(/.js$/, "")
        path = path.replace(__dirname + "/src/", "")
        return path
      }
    }))
    .pipe(concat("app.js"))
    .pipe(sourceMaps.write("."))
    .pipe(gulp.dest("./build/scripts"))
})

gulp.task("build-styles", function () {
  gulp.src(stylesPath)
    .pipe(sourceMaps.init())
    .pipe(sass().on("error", sass.logError))
    .pipe(concat("app.css"))
    .pipe(sourceMaps.write("."))
    .pipe(gulp.dest("./build/css"));
});


gulp.task("watch", function () {
  gulp.watch(scriptsPath, ["build-scripts"])
  gulp.watch(vendorPath, ["build-vendor"])
  gulp.watch(stylesPath, ["build-styles"])
  gulp.watch("./src/index.html", ["build-static"])
})

gulp.task("serve", function () {
  gulp.src("./build")
    .pipe(webServer({
      livereload: true,
      open: true
    }))
})

gulp.task("build-static", function () {
  gulp.src("./src/index.html")
    .pipe(gulp.dest("./build"))
  gulp.src("./src/images/**.*")
    .pipe(gulp.dest("./build/images"))
})

gulp.task("build-clean", function () {
  del(["./build"])
})

gulp.task("build", function () {
  runSequence("build-clean", ["build-static", "build-scripts", "build-vendor", "build-styles"])
})

gulp.task("build-vendor", function () {
  gulp.src("./src/vendor/**/*.js")
    .pipe(plumber())
    .pipe(sourceMaps.init())
    .pipe(concat("vendor.js"))
    .pipe(sourceMaps.write("."))
    .pipe(gulp.dest("./build/scripts"))
})

gulp.task("default", ["build", "watch", "serve"])