namespace Json {
	public class Parser : GLib.Object
	{
		public void load_from_path (string path) throws GLib.Error
		{
			load_from_file (File.new_for_path (path));
		}

		public void load_from_uri (string uri) throws GLib.Error
		{
			load_from_file (File.new_for_uri (uri));
		}

		public void load_from_file (File file) throws GLib.Error
		{
			uint8[] buffer;
			file.load_contents (null, out buffer, null);
			load_from_buffer (buffer);
		}
		
		public void load_from_buffer (uint8[] buffer) throws GLib.Error
		{
			var encoding = Mee.Text.Encoding.correct_encoding (buffer);
			if (encoding == null)
				encoding = Mee.Text.Encoding.utf8;
			load_from_data (encoding.get_string (buffer));
		}
		
		public void load_from_data (string data) throws GLib.Error
		{
			if (data[0] == '[')
				root = new Node (Array.parse (data).to_string ());
			else
				root = new Node (Object.parse (data).to_string ());
		}
		
		public Node root { get; private set; }
	}
}