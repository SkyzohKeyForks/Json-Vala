namespace Json {
	public class Generator : GLib.Object
	{
		public string? to_data()
		{
			if (root == null)
				return null;
			return pretty ? root.dump ((int)indent) : root.to_string();
		}

		public bool to_file (File file) throws GLib.Error
		{
			var stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
			return to_stream (stream);
		}

		public bool to_stream (OutputStream stream) throws GLib.Error
		{
			var data = to_data();
			if (data == null)
				return false;
			stream.write (data.data);
			return true;
		}
		
		public uint indent { get; set; }
		public bool pretty { get; set; }
		public Node root { get; set; }
	}
}