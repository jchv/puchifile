project('puchifile', ['c', 'vala'], 
	version: '0.1.0',
	meson_version: '>= 0.50.0',
	default_options: ['warning_level=2'],
)

gnome = import('gnome')

puchifile_app_sources = [
	'file_thumbnail.vala',
	'location_bar.vala',
	'main.vala',
	'window.vala',
]

puchifile_app_sources += gnome.compile_resources('puchifile-resources',
	'puchifile.gresource.xml',
	c_name: 'puchifile'
)


puchifile_app_deps = [
	dependency('gio-2.0', version: '>= 2.50'),
	dependency('gtk4', version: '>= 4.8.0'),
	dependency('libadwaita-1', version: '>= 1.2.2')
]

executable('puchifile', puchifile_app_sources,
	vala_args: '--target-glib=2.74',
	dependencies: puchifile_app_deps,
	install: true,
)
