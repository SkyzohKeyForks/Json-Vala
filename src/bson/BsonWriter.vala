namespace Json.Bson {
	public class Writer : GLib.Object {
		Gee.ArrayList<uint8> list;
		
		construct {
			list = new Gee.ArrayList<uint8>();
			notify["object"].connect (() => {
				list.clear();
				if (object != null) {
					write_object (object);
					
				}
			});
		}
		
		void write_int32 (int i) {
			uint8* ptr = (uint8*)(&i);
			list.add (ptr[0]);
			list.add (ptr[1]);
			list.add (ptr[2]);
			list.add (ptr[3]);
		}
		
		void write_integer (int64 i) {
			uint8* ptr = (uint8*)(&i);
			list.add (ptr[0]);
			list.add (ptr[1]);
			list.add (ptr[2]);
			list.add (ptr[3]);
			list.add (ptr[4]);
			list.add (ptr[5]);
			list.add (ptr[6]);
			list.add (ptr[7]);
		}
		
		void write_number (double d) {
			uint8* ptr = (uint8*)(&d);
			list.add (ptr[0]);
			list.add (ptr[1]);
			list.add (ptr[2]);
			list.add (ptr[3]);
			list.add (ptr[4]);
			list.add (ptr[5]);
			list.add (ptr[6]);
			list.add (ptr[7]);
		}
		
		void write_boolean (bool val) {
			list.add (val ? 1 : 0);
		}
		
		void write_id (string id) {
			list.add_all_array (id.data);
			list.add (0);
		}
		
		void write_string (string str) {
			write_int32 (1 + str.length);
			list.add_all_array (str.data);
			list.add (0);
		}
		
		void write_regex (Regex regex) {
			write_id (regex.get_pattern());
			write_id ("x");
		}
		
		void write_datetime (DateTime datetime) {
			TimeVal tv = TimeVal();
			datetime.to_timeval (out tv);
			int64 ms = tv.tv_sec * 1000 + tv.tv_usec / 1000;
			write_integer (ms);
		}
		
		void write_binary (Bytes bytes) {
			write_int32 (bytes.length);
			list.add (0);
			list.add_all_array (bytes.get_data());
		}
		
		void write_array (Json.Array array) {
			int index = 0;
			int pos = list.size;
			array.foreach (node => {
				if (node.node_type == Json.NodeType.OBJECT)
					list.add (3);
				else if (node.node_type == Json.NodeType.ARRAY)
					list.add (4);
				else if (node.node_type == Json.NodeType.BINARY)
					list.add (5);
				else if (node.node_type == Json.NodeType.STRING)
					list.add (2);
				else if (node.node_type == Json.NodeType.NUMBER)
					list.add (1);
				else if (node.node_type == Json.NodeType.BOOLEAN)
					list.add (8);
				else if (node.node_type == Json.NodeType.INTEGER)
					list.add (18);
				else if (node.node_type == Json.NodeType.REGEX)
					list.add (11);
				else if (node.node_type == Json.NodeType.NULL)
					list.add (10);
				else if (node.node_type == Json.NodeType.DATETIME)
					list.add (9);
				write_id (index.to_string());
				if (node.node_type == Json.NodeType.OBJECT)
					write_object (node.as_object());
				else if (node.node_type == Json.NodeType.ARRAY)
					write_array (node.as_array());
				else if (node.node_type == Json.NodeType.BINARY)
					write_binary (node.as_binary());
				else if (node.node_type == Json.NodeType.STRING)
					write_string (node.as_string());
				else if (node.node_type == Json.NodeType.NUMBER)
					write_number (node.as_double());
				else if (node.node_type == Json.NodeType.BOOLEAN)
					write_boolean (node.as_boolean());
				else if (node.node_type == Json.NodeType.INTEGER)
					write_integer (node.as_int());
				else if (node.node_type == Json.NodeType.REGEX)
					write_regex (node.as_regex());
				else if (node.node_type == Json.NodeType.DATETIME)
					write_datetime (node.as_datetime());
				index++;
			});
			list.add (0);
			int size = list.size + 4 - pos;
			uint8* ptr = (uint8*)(&size);
			list.insert (pos, ptr[3]);
			list.insert (pos, ptr[2]);
			list.insert (pos, ptr[1]);
			list.insert (pos, ptr[0]);
		}
		
		void write_object (Json.Object object) {
			int pos = list.size;
			object.foreach ((name, node) => {
				if (node.node_type == Json.NodeType.OBJECT)
					list.add (3);
				else if (node.node_type == Json.NodeType.ARRAY)
					list.add (4);
				else if (node.node_type == Json.NodeType.BINARY)
					list.add (5);
				else if (node.node_type == Json.NodeType.STRING)
					list.add (2);
				else if (node.node_type == Json.NodeType.NUMBER)
					list.add (1);
				else if (node.node_type == Json.NodeType.BOOLEAN)
					list.add (8);
				else if (node.node_type == Json.NodeType.INTEGER)
					list.add (18);
				else if (node.node_type == Json.NodeType.DATETIME)
					list.add (9);
				else if (node.node_type == Json.NodeType.NULL)
					list.add (10);
				else if (node.node_type == Json.NodeType.REGEX)
					list.add (11);
				write_id (name);
				if (node.node_type == Json.NodeType.OBJECT)
					write_object (node.as_object());
				else if (node.node_type == Json.NodeType.ARRAY)
					write_array (node.as_array());
				else if (node.node_type == Json.NodeType.BINARY)
					write_binary (node.as_binary());
				else if (node.node_type == Json.NodeType.STRING)
					write_string (node.as_string());
				else if (node.node_type == Json.NodeType.NUMBER)
					write_number (node.as_double());
				else if (node.node_type == Json.NodeType.BOOLEAN)
					write_boolean (node.as_boolean());
				else if (node.node_type == Json.NodeType.INTEGER)
					write_integer (node.as_int());
				else if (node.node_type == Json.NodeType.REGEX)
					write_regex (node.as_regex());
				else if (node.node_type == Json.NodeType.DATETIME)
					write_datetime (node.as_datetime());
			});
			list.add (0);
			int size = list.size + 4 - pos;
			uint8* ptr = (uint8*)(&size);
			list.insert (pos, ptr[3]);
			list.insert (pos, ptr[2]);
			list.insert (pos, ptr[1]);
			list.insert (pos, ptr[0]);
		}
		
		public void to_path (string path) throws GLib.Error {
			to_file (File.new_for_path (path));
		}
		
		public void to_file (GLib.File file) throws GLib.Error {
			var stream = file.create (FileCreateFlags.NONE);
			to_stream (stream);
		}
		
		public void to_stream (OutputStream stream) throws GLib.Error {
			uint8[] data;
			to_data (out data);
			stream.write (data);
		}
		
		public void to_data (out uint8[] data) {
			data = list.to_array();
		}
		
		public Json.Object object { get; set; }
	}
}
