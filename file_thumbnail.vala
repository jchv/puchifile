namespace Puchifile {
	public class FileItem : Object {
		public FileInfo info;

		public FileItem(FileInfo info) {
			this.info = info;
		}

        public string name {
            get { return info.get_name(); }
        }

        public Icon get_file_icon(FileInfo info, int icon_size, int scale, Gtk.IconTheme icon_theme) {
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
	}
}