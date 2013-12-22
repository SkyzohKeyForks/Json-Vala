namespace Json {
	public class Generator : GLib.Object
	{
		construct {
			indent = 0;
			pretty = true;
		}
		
		public string to_data() throws GLib.Error
		{
			if (root == null)
				throw new JsonError.NULL ("no json node provided.");
			return pretty ? root.dump(indent) : root.to_string();
		}
		
		public bool to_stream (GLib.OutputStream stream)
		{
			try {
				stream.write (to_data().data);
				return true;
			} catch {
				return false;
			}
		}
		
		public bool to_file (string path) throws GLib.Error
		{
			var file = File.new_for_path (path);
			return to_stream (file.create (FileCreateFlags.REPLACE_DESTINATION));
		}
		
		public Node root { get; set; }
		public int indent { get; set; }
		public bool pretty { get; set; }
	}
}
