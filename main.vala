int main (string[] args) {
	var app = new Gtk.Application("io.jchw.puchifile", ApplicationFlags.FLAGS_NONE);
	app.activate.connect(() => {
		var win = app.active_window;
		if (win == null) {
			typeof(Puchifile.LocationBar);
			win = new Puchifile.Window(app);
		}
		win.present();
	});
	return app.run(args);
}
