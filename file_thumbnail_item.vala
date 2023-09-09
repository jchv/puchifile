namespace Puchifile {
	[GtkTemplate (ui = "/io/jchw/Puchifile/file_thumbnail_item.ui")]
    public class FileThumbnailItem : Gtk.Box {
        [GtkChild]
        unowned FileThumbnail thumbnail;
        [GtkChild]
        unowned Gtk.Label label;

        public FileThumbnailItem(FileInfo info) {
            thumbnail.file_info = info;
            label.set_text (info.get_name());
        }
    }
}
