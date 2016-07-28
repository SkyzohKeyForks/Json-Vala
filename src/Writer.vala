namespace Json {
	public abstract class Writer : GLib.Object {
		public abstract void write_start_array();
		public abstract void write_end_array();
		public abstract void write_start_object();
		public abstract void write_end_object();
		public abstract void write_node_delimiter();
		public abstract void write_property_name (string key);
		public abstract void write_boolean (bool val);
		public abstract void write_number (double val);
		public abstract void write_integer (int64 val);
		public abstract void write_null();
		public abstract void write_string (string val);
		
		public void write_node (Json.Node node) {
			if (node.node_type == NodeType.OBJECT)
				node.as_object().write_to (this);
			else if (node.node_type == NodeType.ARRAY)
				node.as_array().write_to (this);
			else if (node.node_type == NodeType.BOOLEAN)
				write_boolean ((bool)node.value);
			else if (node.node_type == NodeType.NUMBER)
				write_number ((double)node.value);
			else if (node.node_type == NodeType.STRING)
				write_string ((string)node.value);
			else if (node.node_type == NodeType.INTEGER)
				write_integer ((int64)node.value);
			else
				write_null();
		}
		
		public void write_value (GLib.Value? val) {
			write_node (new Json.Node (val));
		}
	}
	
	public class TextWriter : Writer {
		StringBuilder sb;
		
		construct {
			sb = new StringBuilder();
		}
		
		public string text {
			owned get {
				return sb.str;
			}
		}
		
		public override void write_start_array() {
			sb.append_c ('[');
		}
		
		public override void write_end_array() {
			sb.append_c (']');
		}
		
		public override void write_start_object() {
			sb.append_c ('{');
		}
		
		public override void write_end_object() {
			sb.append_c ('}');
		}
		
		public override void write_node_delimiter() {
			sb.append_c (',');
		}
		
		public override void write_property_name (string name) {
			sb.append_c ('"');
			sb.append (name);
			sb.append_c ('"');
			sb.append_c (':');
		}
		
		public override void write_boolean (bool val) {
			sb.append (val ? "true" : "false");
		}
		
		public override void write_number (double val) {
			sb.append ("%g".printf (val));
		}
		
		public override void write_integer (int64 val) {
			sb.append (val.to_string());
		}
		
		public override void write_string (string val) {
			int i = 0;
			unichar u;
			while (val.get_next_char (ref i, out u)) {
				if (u == '"')
					sb.append_c ('\\');
				sb.append_unichar (u);
			}
		}
		
		public override void write_null() {
			sb.append ("null");
		}
	}
}
