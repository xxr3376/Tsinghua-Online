module.exports = (grunt) ->
	'use strict'
	#############
	# plugins
	grunt.loadNpmTasks 'grunt-contrib-clean'

	grunt.registerMultiTask 'template', ->
		for file in @files
		  src=file.src[0]
		  dest=file.dest
		  cont=grunt.template.process grunt.file.read(src, encoding: 'utf-8')
		  cont=cont.replace(/\r\n/g, '\n')
		  grunt.file.write(dest, cont, encoding: 'utf-8')
	

	############
	# main
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		template:
			manifest:
				files: [
					{src: 'src/manifest.json', dest: 'build/manifest.json' }
				]
		clean:
			build: ['build/*']

	grunt.registerTask 'manifest', [
		'template:manifest'
	]
	grunt.registerTask 'default', [
		'manifest'
	]
