namespace Puchifile {
	public class MountOperation : GLib.MountOperation {
		public override void aborted () {
		}

		public override void ask_password (string message, string default_user, string default_domain, GLib.AskPasswordFlags flags) {
		}

		public override void ask_question (string message, [CCode (array_length = false, array_null_terminated = true)] string[] choices) {
		}

		public override void reply (GLib.MountOperationResult result) {
		}

		public override void show_processes (string message, GLib.Array<GLib.Pid> processes, [CCode (array_length = false, array_null_terminated = true)] string[] choices) {
		}

		public override void show_unmount_progress (string message, int64 time_left, int64 bytes_left) {
		}

	}

	[GtkTemplate (ui = "/io/jchw/Puchifile/window.ui")]
	public class Window : Adw.ApplicationWindow {
		[GtkChild]
		private unowned Puchifile.LocationBar location_bar;
		[GtkChild]
		private unowned Gtk.GridView grid;

		private ListStore model;
		private Gtk.MultiSelection selection_model;
		private File current_dir;

		public Window(Gtk.Application app) {
			Object(application: app);

			this.model = new GLib.ListStore(typeof(FileItem));
			this.selection_model = new Gtk.MultiSelection(this.model);
			grid.set_model(this.selection_model);
			grid.set_factory(new Gtk.BuilderListItemFactory.from_resource(null, "/io/jchw/Puchifile/file_thumbnail.ui"));

			location_bar.location_changed.connect(refresh_location);
			location_bar.up_clicked.connect(go_up);
			location_bar.location = GLib.Environment.get_current_dir();

			grid.activate.connect(file_activated);
		}

		private async void refresh_location() {
			File dir;
			if (location_bar.is_local_path) {
				dir = File.new_for_path(location_bar.location);
			} else {
				dir = File.new_for_uri(location_bar.location);
			}
			yield set_directory(dir);
		}

		private async void set_directory(GLib.File dir) {
			current_dir = dir;
			var path = dir.get_path();
			if (path != null) {
				location_bar.overwrite_location(path);
			} else {
				location_bar.overwrite_location(dir.get_uri());
			}
			this.model.remove_all();
			try {
				var e = yield current_dir.enumerate_children_async (FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT);
				while (true) {
					var files = yield e.next_files_async (10, Priority.DEFAULT);
					if (files == null) {
						break;
					}
					foreach (var info in files) {
						this.model.append (new FileItem(info));
					}
				}
			} catch (GLib.Error err) {
				if (err.code == GLib.IOError.NOT_MOUNTED) {
					yield try_mount(current_dir);
					return;
				}
				stderr.printf ("Error: set_directory failed: %s %d\n", err.message, err.code);
			}
		}

		private async void try_mount(GLib.File dir) {
			try {
				yield dir.mount_enclosing_volume(MountMountFlags.NONE, null, null);
				yield set_directory(dir);
			} catch (GLib.Error err) {
				stderr.printf ("Error: try_mount failed: %s %d\n", err.message, err.code);				
			}
		}

		private async void file_activated(uint position) {
			var item = (FileItem) this.model.get_item(position);
			var file = this.current_dir.resolve_relative_path(item.name);
			if (item.info.get_file_type() == FileType.DIRECTORY) {
				yield set_directory(file);
			} else {
				yield AppInfo.launch_default_for_uri_async(file.get_uri(), null);
			}
		}

		private async void go_up() {
			yield set_directory(this.current_dir.resolve_relative_path(".."));
		}
	}
}
