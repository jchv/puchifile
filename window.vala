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
		[GtkChild]
		private unowned Adw.Banner error_banner;

		private ListStore model;
		private Gtk.MultiSelection selection_model;
		private Gtk.DirectoryList dir_list = new Gtk.DirectoryList(@"standard::*,time::modified,$(GLib.FileAttribute.THUMBNAIL_PATH)", null);
		private File current_dir;

		public Window(Gtk.Application app) {
			Object(application: app);

			this.model = new GLib.ListStore(typeof(FileInfo));
			this.selection_model = new Gtk.MultiSelection(this.model);
			grid.set_model(this.selection_model);

			var factory = new Gtk.SignalListItemFactory ();
			factory.bind.connect ((item) => {
				item.child = new FileThumbnailItem((FileInfo)item.item);
			});
			grid.set_factory(factory);

			location_bar.location_changed.connect(refresh_location);
			location_bar.up_clicked.connect(go_up);
			location_bar.location = GLib.Environment.get_current_dir();

			grid.activate.connect(file_activated);
			dir_list.items_changed.connect ((position, removed, added) => {
				this.model.splice (position, removed, new GLib.Object[0]);
				for (int i = 0; i < added; i++) {
					this.model.insert (position + i, dir_list.get_item(position + i));
				}
			});
			dir_list.notify.connect (() => {
				if (dir_list.error != null) {
					this.error_banner.revealed = true;
					this.error_banner.title = @"Failed to load directory: $(dir_list.error.message)";
				} else {
					this.error_banner.revealed = false;
					this.error_banner.title = "";
				}
			});
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
			this.error_banner.revealed = false;
			this.error_banner.title = "";
			dir_list.file = current_dir;
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
			var item = (FileInfo) this.model.get_item(position);
			var file = this.current_dir.resolve_relative_path(item.get_name());
			// TODO: handle resolving symlink
			if (item.get_file_type() == FileType.DIRECTORY) {
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
