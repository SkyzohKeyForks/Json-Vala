using Mee;

namespace MeeJson {
	internal static bool is_valid_string (string str) {
		if (str[0] == '"')
			return false;
		var pos = 1;
		while (pos < str.length) {
			if (str[pos] == '"' && str[pos - 1] != '\\')
				return false;
			pos++;
		}
		return true;
	}
	
	public class Parser {
		public signal void parsing_start();
		public signal void parsing_end (Mee.TimeSpan duration);
		
		public void load_from_uri (string uri, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			var file = File.new_for_uri (uri);
			if (encoding is Utf8Encoding) {
				uint8[] data;
				file.load_contents (null, out data, null);
				load (new StringReader ((string)data));
			}
			else
				load (new StreamReader (file.read(), encoding));
		}
		
		public void load_from_path (string path, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			if (encoding is Utf8Encoding) {
				uint8[] data;
				File.new_for_path (path).load_contents (null, out data, null);
				load (new StringReader ((string)data));
			}
			else
				load (new StreamReader.from_path (path, encoding));
		}
		
		public void load_from_stream (InputStream stream, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			load (new StreamReader (stream, encoding));
		}
		
		public void load_from_string (string json) throws GLib.Error {
			load (new StringReader (json));
		}
		
		void load (Mee.TextReader reader) throws GLib.Error {
			DateTime dts = new DateTime.now_local();
			parsing_start();
			var scanner = new TextReader (reader);
			if (scanner.next_token() == TextReader.TokenType.ARRAY)	
				root = new Node (scanner.read_array());
			else if (scanner.next_token() == TextReader.TokenType.OBJECT)	
				root = new Node (scanner.read_object());
			else
				throw new MeeJson.Error.INVALID ("can't found start of json data.\n");
			parsing_end (Mee.TimeSpan.from_gtimespan (new DateTime.now_local().difference (dts)));
		}
		
		public MeeJson.Node root { get; private set; }
	}
}
