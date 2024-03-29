// Generated on 2013-10-21 using generator-webapp 0.4.3
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // Show elapsed time at the end
  require('time-grunt')(grunt);
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);

  // Project configuration.
  grunt.initConfig({
    // Metadata
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
      '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
      ' Licensed MIT */\n',
    // configurable paths
    yeoman: {
      bower: 'bower_components',
      src: 'src',
      test: 'spec',
      out: '.tmp',
      dist: 'dist',
      site: 'site',
      docs: 'docs'
    },
    coffee: {
      lib: {
        expand: true,
        cwd: '<%= yeoman.src %>/',
        src: ['**/*.coffee'],
        dest: '<%= yeoman.out %>/src/',
        ext: '.js'
      },
      test: {
        expand: true,
        cwd: 'spec',
        src: ['**/*.coffee'],
        dest: '<%= yeoman.out %>/spec/',
        ext: '.js'
      }
    },

    // Put files not handled in other tasks here
    copy: {
      out: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.src %>',
          dest: '<%= yeoman.out %>',
          src: [
            '**/*.js',
          ]
        }]
      },
      spec: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.test %>',
          dest: '<%= yeoman.out %>/spec/',
          src: [
            '**/*.js',
          ]
        }]
      },
    },

    browserify: {
      dist: {
        src: '<%= yeoman.out %>/src/browser.js',
        dest: '<%= yeoman.dist %>/<%= pkg.name %>.js'
      }
    },
    clean: {
      options: {
      },
      all: {
        files: [{
          dot: true,
          src: [
            // '<%= yeoman.docs %>',
            '<%= yeoman.out %>',
            '<%= yeoman.dist %>'
          ]
        }]
      }
    },
    jasmine: {
      options: {
        specs: [
          '<%= yeoman.bower %>/underscore/underscore.js',
          '<%= yeoman.bower %>/ttm-coffeescript-utilities/dist/ttm-coffeescript-utilities.js',
          '<%= yeoman.dist %>/<%= pkg.name %>.js',
          '<%= yeoman.out %>/spec/spec_helpers.js',
          '<%= yeoman.out %>/spec/**/*_spec.js',
        ]
      },
      ci:{
        options: {
          junit:{
            path: 'tests',
            consolidate: true
          }
        }
      }
    },

    watch: {
      coffee: {
        files: [
          '<%= yeoman.src %>/**/*.{coffee,scss}',
          '<%= yeoman.test %>/**/*.coffee',
        ],
        tasks: ['build'],
        options: {
          interrupt: false
        }
      }
    },

    connect: {
      options: {
        port: 9000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: '0.0.0.0'
      },
      serve: {
        options: {
          open: true,
          base: [
            'html',
            '.tmp',
            'dist',
            'bower_components',
            'vendor/jasmine-standalone-1.3.1',
            '<%= yeoman.src %>',
            '<%= yeoman.site_src %>',
          ]
        }
      },
      dist: {
        options: {
          open: true,
          base: [
            '<%= yeoman.dist %>',
            'bower_components',
            '<%= yeoman.site_src %>',
          ]
        }
      }
    },


    // This is failing to work, and it only really creates some "docs" that are just the spec file contents in an HTML page
    // It blocks building AND testing, so commenting it out for now
    // docco: {
    //   docs: {
    //     src: ['src/**/*.coffee',
    //           'spec/**/*.coffee'],
    //     options: {
    //       output: 'docs/'
    //     }
    //   }
    // },

    uglify: {
      dist: {
        files: {
          '<%= yeoman.dist %>/<%= pkg.name %>.min.js': '<%= yeoman.dist %>/<%= pkg.name %>.js'
        }
      }
    },

    concat: {
      options: {
        banner: '<%= banner %>',
        stripBanners: true,
      },
      spec: {
        src: [
          '<%= yeoman.out %>/spec/*.js'
        ],
        dest: '<%= yeoman.out %>/specs.js'
      }
    }
  });

  grunt.registerTask('serve', [
    'build',
    'connect:serve',
    'watch'
  ]);

  grunt.registerTask('build', [
    'clean',
    // 'docco',
    'coffee',
    'copy:out',
    'copy:spec',
    'concat',
    'browserify',
    'uglify',
  ]);

  grunt.registerTask('test', [
    'build',
    'jasmine'
  ]);

  grunt.registerTask('default', ['build']);
};
