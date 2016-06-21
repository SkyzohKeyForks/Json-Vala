namespace Json.Bson {
	public class Document : GLib.Object {
		
		public void load_from_path (string path) throws GLib.Error {
			load_from_file (File.new_for_path (path));
		}
		
		public async void load_from_path_async (string path) throws GLib.Error {
			ThreadFunc<void*> run = () => {
				load_from_file (File.new_for_path (path));
				Idle.add (load_from_path_async.callback);
				return null;
			};
			Thread.create<void*>(run, false);
			yield;
		}
		
		public void load_from_uri (string uri) throws GLib.Error {
			load_from_file (File.new_for_uri (uri));
		}
		
		public async void load_from_uri_async (string uri) throws GLib.Error {
			ThreadFunc<void*> run = () => {
				load_from_file (File.new_for_uri (uri));
				Idle.add (load_from_uri_async.callback);
				return null;
			};
			Thread.create<void*>(run, false);
			yield;
		}
		
		public void load_from_file (GLib.File file) throws GLib.Error {
			load (file.read());
		}
		
		public async void load_from_file_async (File file) throws GLib.Error {
			ThreadFunc<void*> run = () => {
				load (file.read());
				Idle.add (load_from_file_async.callback);
				return null;
			};
			Thread.create<void*>(run, false);
			yield;
		}
		
		public signal void parsing_start();
		public signal void parsing_end (TimeSpan duration);
		
		public void load (InputStream stream) throws GLib.Error {
			var dts = new DateTime.now_local();
			parsing_start();
			var reader = new Reader (stream);
			root = new Json.Node (reader.read_object());
			parsing_end (new DateTime.now_local().difference (dts));
		}
		
		public async void load_async (InputStream stream) throws GLib.Error {
			ThreadFunc<void*> run = () => {
				load (stream);
				Idle.add (load_async.callback);
				return null;
			};
			Thread.create<void*>(run, false);
			yield;
		}
		
		public Json.Node root { get; private set; }
	}
}
