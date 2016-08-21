namespace Json {
	public class Generator : GLib.Object {
		public uint indent { get; set; }
		public bool tab { get; set; }
		public bool pretty { get; set; }
		public Json.Node root { get; set; }
		
		construct {
			indent = 1;
		}
		
		public string to_string() {
			StringBuilder sb = new StringBuilder();
			node_to_string (sb, root);
			return sb.str;
		}
		
		void node_to_string (StringBuilder sb, Json.Node node, uint depth = 0) {
			if (node.str != null) 
				string_to_string (sb, node.str);
			else if (node.binary != null) {
				string b64 = Base64.encode (node.binary.get_data());
				string_to_string (sb, b64);
			}
			else if (node.datetime != null)
				string_to_string (sb, node.datetime.to_string());
			else if (node.regex != null)
				string_to_string (sb, node.regex.get_pattern());
			else if (node.number_str != null)
				sb.append (node.number_str);
			else if (node.node_type == NodeType.INTEGER)
				sb.append (node.integer.to_string());
			else if (node.node_type == NodeType.BOOLEAN)
				sb.append (node.boolean.to_string());
			else if (node.array != null)
				array_to_string (sb, node.array, depth);
			else if (node.object != null)
				object_to_string (sb, node.object, depth);
			else
				sb.append ("null");
		}
		
		void string_to_string (StringBuilder sb, string str) {
			int i = 0;
			unichar u;
			sb.append_unichar ('"');
			while (str.get_next_char (ref i, out u)) {
				if (u == '"') {
					sb.append_unichar ('\\');
					sb.append_unichar ('"');
				} else
					sb.append_unichar (u);
			}
			sb.append_unichar ('"');
		}
		
		void object_to_string (StringBuilder sb, Json.Object object, uint depth) {
			if (object.length == 0) {
				sb.append ("{}");
				return;
			}
			sb.append ("{ ");
			if (pretty)
				sb.append_c ('\n');
			for (var i = 0; i < object.length - 1; i++) {
				if (pretty)
					for (var j = 0; j < depth + 1; j++)
						for (var k = 0; k < indent; k++)
							sb.append_c (tab ? '\t' : ' ');
				string key = object.keys[i];
				string_to_string (sb, key);
				sb.append (" : ");
				node_to_string (sb, object[key], depth + 1);
				sb.append (", ");
				if (pretty)
					sb.append_c ('\n');
			}
			if (pretty)
				for (var j = 0; j < depth + 1; j++)
					for (var k = 0; k < indent; k++)
						sb.append_c (tab ? '\t' : ' ');
			string key = object.keys[object.length - 1];
			string_to_string (sb, key);
			sb.append (" : ");
			node_to_string (sb, object[key], depth + 1);
			if (pretty) {
				sb.append_c ('\n');
				for (var j = 0; j < depth; j++)
					for (var k = 0; k < indent; k++)
						sb.append_c (tab ? '\t' : ' ');
				sb.append ("}");
			}
			else
				sb.append (" }");
		}
		
		void array_to_string (StringBuilder sb, Json.Array array, uint depth) {
			if (array.length == 0) {
				sb.append ("[]");
				return;
			}
			sb.append ("[ ");
			if (pretty)
				sb.append_c ('\n');
			for (var i = 0; i < array.length - 1; i++) {
				if (pretty)
					for (var j = 0; j < depth + 1; j++)
						for (var k = 0; k < indent; k++)
							sb.append_c (tab ? '\t' : ' ');
				node_to_string (sb, array[i], depth + 1);
				sb.append (", ");
				if (pretty)
					sb.append_c ('\n');
			}
			if (pretty)
				for (var j = 0; j < depth + 1; j++)
					for (var k = 0; k < indent; k++)
						sb.append_c (tab ? '\t' : ' ');
			node_to_string (sb, array[array.length - 1], depth + 1);
			if (pretty) {
				sb.append_c ('\n');
				for (var j = 0; j < depth; j++)
					for (var k = 0; k < indent; k++)
						sb.append_c (tab ? '\t' : ' ');
				sb.append ("]");
			}
			else
				sb.append (" ]");
		}
	}
}
