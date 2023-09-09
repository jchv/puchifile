namespace Puchifile {
    public class FileThumbnail : Gtk.Widget {
        private Gtk.Image image = new Gtk.Image();
        private Cancellable cancellable;

        private int _icon_size = 96;
        private FileInfo? _info;

        public int icon_size {
            get { return _icon_size; }
            set {
                _icon_size = value;
                cancel_thumbnail();
                get_thumbnail.begin();
            }
        }

        public FileInfo? file_info {
            get { return _info; }
            set {
                _info = value;
                cancel_thumbnail();
                get_thumbnail.begin();
            }
        }

        class construct {
            set_css_name("filethumbnail");
            set_layout_manager_type(typeof(Gtk.BinLayout));
        }

        construct {
            image.set_parent(this);
        }

        public override void dispose() {
            image.unparent();
            base.dispose();
        }

        private static Icon get_file_icon(FileInfo info, int icon_size, int scale, Gtk.IconTheme icon_theme) {
            Icon icon;
            Gdk.Pixbuf pixbuf;
            string? thumbnail_path;

            thumbnail_path = info.get_attribute_byte_string(GLib.FileAttribute.THUMBNAIL_PATH);
            if (thumbnail_path != null) {
                try {
                    pixbuf = new Gdk.Pixbuf.from_file_at_size(thumbnail_path, icon_size*scale, icon_size*scale);
                    if (pixbuf != null) {
                        return pixbuf;
                    }
                } catch(GLib.Error e) {
                    // Nothing to do.
                }
            }

            icon = info.get_icon();
            if (icon != null && icon_theme.has_gicon(icon)) {
                return icon;
            }

            return new ThemedIcon("text-x-generic");
        }

        private bool update_image() {
            if (!this._info.has_attribute(FileAttribute.STANDARD_ICON)) {
                this.image.clear();
                return false;
            }

            var scale = get_scale_factor();
            var icon_theme = Gtk.IconTheme.get_for_display(get_display());

            var icon = get_file_icon(_info, icon_size, scale, icon_theme);
            image.set_from_gicon(icon);
            image.set_pixel_size(icon_size);
            return true;
        }

        private void cancel_thumbnail() {
            if (cancellable != null) {
                cancellable.cancel();
            }
            cancellable = null;
        }

        private async void get_thumbnail() {
            if (file_info == null) {
                this.image.clear();
                return;
            }

            if (!update_image()) {
                File file;
          
                if (_info.has_attribute("filethumbnail::queried")) {
                    return;
                }
          
                assert(cancellable == null);
                cancellable = new Cancellable();
          
                file = (File)_info.get_attribute_object("standard::file");
                
                try {
                    var queried = yield file.query_info_async(@"$(FileAttribute.THUMBNAIL_PATH),$(FileAttribute.THUMBNAILING_FAILED),$(FileAttribute.STANDARD_ICON)", FileQueryInfoFlags.NONE, Priority.DEFAULT, cancellable);
                    _info.set_attribute_string(FileAttribute.THUMBNAIL_PATH, queried.get_attribute_string(FileAttribute.THUMBNAIL_PATH));
                    _info.set_attribute_boolean(FileAttribute.THUMBNAILING_FAILED, queried.get_attribute_boolean(FileAttribute.THUMBNAILING_FAILED));
                    _info.set_attribute_object(FileAttribute.STANDARD_ICON, queried.get_attribute_object(FileAttribute.STANDARD_ICON));
                    cancellable = null;
                } catch(GLib.Error error) {
                    if (!error.matches(GLib.IOError.quark(), GLib.IOError.CANCELLED)) {
                        _info.set_attribute_boolean("filethumbnail::queried", true);
                    }
                    return;
                }
            }
        }
    }
}