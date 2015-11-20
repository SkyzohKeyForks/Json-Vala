namespace Json {
	public class Generator : GLib.Object {
		public uint indent { get; set; default = 1; }
		public unichar indent_char { get; set; default = '\t'; }
		public bool pretty { get; set; }
		public Json.Node root { get; set; }
		
		public string to_data() {
			if (root == null)
				return null;
			return node_to_data (root);
		}
		
		public void to_file (string filename) {
			FileUtils.set_contents (filename, to_data());
		}
		
		string node_to_data (Json.Node node, int depth = 0) {
			if (node.array != null)
				return array_to_data (node.array, depth);
			if (node.object != null)
				return object_to_data (node.object, depth);
			return node.to_string();
		}
		
		string array_to_data (Json.Array array, int depth = 0) {
			if (array.size == 0)
				return "[]";
			string result = "[ ";
			if (pretty)
				result += "\n";
			for (var i = 0; i < array.size - 1; i++) {
				if (pretty)
					for (var j = 0; j < depth + 1; j++)
						for (var k = 0; k < indent; k++)
							result += indent_char.to_string();
				result += node_to_data (array.get_element (i), depth + 1) + ", ";
				if (pretty)
					result += "\n";
			}
			if (pretty)
				for (var j = 0; j < depth + 1; j++)
					for (var k = 0; k < indent; k++)
						result += indent_char.to_string();
			result += node_to_data (array.get_element (array.size - 1), depth + 1);
			if (pretty)
				result += "\n";
			if (pretty)
				for (var i = 0; i < depth; i++)
					for (var j = 0; j < indent; j++)
						result += indent_char.to_string();
			result += " ]";
			return result;
		}
		
		string object_to_data (Json.Object object, int depth = 0) {
			if (object.size == 0)
				return "{}";
			string result = "{ ";
			if (pretty)
				result += "\n";
			for (var i = 0; i < object.size - 1; i++) {
				if (pretty)
					for (var j = 0; j < depth + 1; j++)
						for (var k = 0; k < indent; k++)
							result += indent_char.to_string();
				string key = object.keys[i];
				result += "\"" + key + "\" : " + node_to_data (object.get_member (key), depth + 1) + ", ";
				if (pretty)
					result += "\n";
			}
			if (pretty)
				for (var j = 0; j < depth + 1; j++)
					for (var k = 0; k < indent; k++)
						result += indent_char.to_string();
			string key = object.keys[object.size - 1];
			result += "\"" + key + "\" : " + node_to_data (object.get_member (key), depth + 1);
			if (pretty)
				result += "\n";
			if (pretty)
				for (var i = 0; i < depth; i++)
					for (var j = 0; j < indent; j++)
						result += indent_char.to_string();
			result += " }";
			return result;
		}
	}
}
