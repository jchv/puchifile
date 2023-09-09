int main (string[] args) {
	var app = new Adw.Application("io.jchw.puchifile", ApplicationFlags.FLAGS_NONE);
	app.activate.connect(() => {
		var css_provider = new Gtk.CssProvider();
        css_provider.load_from_resource("/io/jchw/Puchifile/style.css");
        Gtk.StyleContext.add_provider_for_display(
			Gdk.Display.get_default(), css_provider,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

		typeof(Puchifile.FileThumbnailItem);
		typeof(Puchifile.FileThumbnail);
		typeof(Puchifile.LocationBar);

		var win = app.active_window;
		if (win == null) {
			win = new Puchifile.Window(app);
		}
		win.present();
	});
	return app.run(args);
}
