namespace Json.Bson {
	public class Document : GLib.Object {
		
		public void load_from_path (string path) throws GLib.Error {
			load_from_file (File.new_for_path (path));
		}
		
		public void load_from_uri (string uri) throws GLib.Error {
			load_from_file (File.new_for_uri (uri));
		}
		
		internal void load_from_file (GLib.File file) throws GLib.Error {
			load (file.read());
		}
		
		public signal void parsing_start();
		public signal void parsing_end (TimeSpan duration);
		
		internal void load (InputStream stream) throws GLib.Error {
			var dts = new DateTime.now_local();
			parsing_start();
			var reader = new Reader (stream);
			root = new Json.Node (reader.read_object());
			parsing_end (new DateTime.now_local().difference (dts));
		}
		
		public Json.Node root { get; private set; }
	}
}
