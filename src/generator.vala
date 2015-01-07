namespace Json {
	public class Generator {
		public uint indent { set; get; default = 1; }
		public char indent_char { set; get; default = '\t'; }
		public bool pretty { set; get; default = true; }
		public Json.Node root { set; get; }
		
		public void set_root_array (Json.Array array) {
			root = new Json.Node();
			root.array = array;
		}
		
		public void set_root_object (Json.Object object) {
			root = new Json.Node();
			root.object = object;
		}

		public string to_data() {
			return root.to_data (indent, indent_char, pretty);
		}

		public void to_stream (GLib.OutputStream stream, GLib.Cancellable? cancellable = null) throws GLib.Error {
			stream.write (to_data().data, cancellable);
		}

		public void to_file (string path) throws GLib.Error {
			var stream = File.new_for_path (path).create (FileCreateFlags.NONE);
			to_stream (stream);
		}
	}
}
