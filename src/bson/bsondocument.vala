namespace MeeJson.Bson {
	public class Document : GLib.Object {
		
		public void load_from_path (string path) throws GLib.Error {
			load_from_file (File.new_for_path (path));
		}
		
		public void load_from_uri (string uri) throws GLib.Error {
			load_from_file (File.new_for_uri (uri));
		}
		
		public void load_from_file (GLib.File file) throws GLib.Error {
			load (file.read());
		}
		
		public signal void parsing_start();
		public signal void parsing_end (Mee.TimeSpan duration);
		
		public void load (InputStream stream) throws GLib.Error {
			var dts = new DateTime.now_local();
			parsing_start();
			var reader = new Reader (stream);
			root = new MeeJson.Node (reader.read_object());
			parsing_end (Mee.TimeSpan.from_gtimespan (new DateTime.now_local().difference (dts)));
		}
		
		public MeeJson.Node root { get; private set; }
	}
}
