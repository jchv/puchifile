namespace Puchifile {
    // Widget that acts as a location bar. Usually a text entry, but can also
    // be breadcrumbs for local directories.
	[GtkTemplate (ui = "/io/jchw/Puchifile/location_bar.ui")]
	public class LocationBar : Gtk.Box {
        [GtkChild]
        unowned Gtk.Stack stack;
        [GtkChild]
        unowned Gtk.Box breadcrumbs;
        [GtkChild]
        unowned Gtk.Entry entry;
        [GtkChild]
        unowned Gtk.Button back_button;
        [GtkChild]
        unowned Gtk.Button forward_button;

        private Array<string> _history = new Array<string>();
        private Array<string> _future = new Array<string>();
        private string _location;
        private bool _is_local_path;
        private bool _edit_mode;

        public string location {
            get { return _location; }
            set { 
                if (value == "") { return; }
                if (_location == value) { return; }
                if (_location != null) { add_history_item(value); }
                overwrite_location(value);
                location_changed();
            }
        }

        public bool edit_mode {
            get { return _edit_mode; }
            set {
                if (_is_local_path && !value) {
                    _edit_mode = false;
                    stack.set_visible_child_name("breadcrumbs");
                } else {
                    _edit_mode = true;
                    stack.set_visible_child_name("entry");
                    entry.grab_focus_without_selecting();
                }
            }
        }

        public bool is_local_path {
            get { return _is_local_path; }
        }

		public LocationBar(string location) {
            stack.set_visible_child_name("breadcrumbs");
            this.location = location;
		}

        public void overwrite_location(string value) {
            _location = value;
            _is_local_path = _location.has_prefix("/");
            entry.set_text(_location);
            clear_breadcrumbs();
            if (_is_local_path) {
                build_path_breadcrumbs();
            }
        }

        public signal void location_changed();

        private void add_history_item(string location) {
            _history.append_val(_location);
            _future.remove_range(0, _future.length);
            back_button.sensitive = true;
            forward_button.sensitive = false;
        }

        [GtkCallback]
        private void on_edit_clicked(Gtk.Button button) {
            edit_mode = true;
        }

        [GtkCallback]
        private void on_back_clicked(Gtk.Button button) {
            if (_history.length > 0) {
                _future.append_val(_location);
                overwrite_location(_history.index(_history.length - 1));
                location_changed();
                _history.remove_index(_history.length - 1);
                forward_button.sensitive = true;
            }
            if (_history.length == 0) {
                back_button.sensitive = false;
            }
        }

        [GtkCallback]
        private void on_forward_clicked(Gtk.Button button) {
            if (_future.length > 0) {
                _history.append_val(_location);
                overwrite_location(_future.index(_future.length - 1));
                location_changed();
                _future.remove_index(_future.length - 1);
                back_button.sensitive = true;
            }
            if (_future.length == 0) {
                forward_button.sensitive = false;
            }
        }

        [GtkCallback]
        private void on_finish_editing(Gtk.Entry entry) {
            location = entry.text;
            edit_mode = false;
        }

        private void path_button_clicked(Gtk.Button button) {
            string path = button.get_data("path");
            if (path == null) {
                return;
            }
            location = path;
        }

        private void clear_breadcrumbs() {
            var child = breadcrumbs.get_first_child();
            while (child != null) {
                breadcrumbs.remove(child);
                child = breadcrumbs.get_first_child();
            }
        }

        private void build_path_breadcrumbs() {
            unichar wc;
            int i, begin = 1;
            add_breadcrumb_button("/", "/");
            for (i = begin; _location.get_next_char(ref i, out wc); ) {
                if (wc == '/') {
                    var end = i;
                    var path = _location.substring(0, end);
                    var component = _location.substring(begin, end-begin-1);
                    add_breadcrumb_separator();
                    add_breadcrumb_button(path, component);
                    begin = end;
                }
            }
            if (begin != i) {
                add_breadcrumb_separator();
                add_breadcrumb_button(_location, _location.substring(begin));
            }
        }

        private void add_breadcrumb_button(string path, string component) {
            var button = new Gtk.Button();
            var label = new Gtk.Label(component);
            button.set_child(label);
            breadcrumbs.insert_child_after(button, breadcrumbs.get_last_child());
            button.set_visible(true);
            button.set_has_frame(false);
            button.set_data("path", path);
            button.clicked.connect(path_button_clicked);
            label.set_visible(true);
        }

        private void add_breadcrumb_separator() {
            var label = new Gtk.Label("›");
            label.set_visible(true);
            breadcrumbs.insert_child_after(label, breadcrumbs.get_last_child());
        }
	}
}
