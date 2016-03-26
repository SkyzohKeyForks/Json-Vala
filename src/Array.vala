namespace Json {
	public static string normalize (string str) {
		StringBuilder sb = new StringBuilder();
		int i = 0;
		unichar u;
		while (str.get_next_char (ref i, out u)) {
			
		}
		return sb.str;
	}
	
	public class Array : GLib.Object {
		public static Array from (GLib.Value[] values) {
			var array = new Array();
			foreach (GLib.Value val in values)
				array.add (val);
			return array;
		}
		
		public static Array parse (string json) {
			var parser = new Json.Parser();
			try {
				parser.load_from_data (json);
				if (parser.root.node_type == NodeType.ARRAY)
					return parser.root.array;
			} catch {
				return new Json.Array();
			}
			return new Json.Array();
		}
		
		Gee.ArrayList<Json.Node> nodes;
		
		construct {
			nodes = new Gee.ArrayList<Json.Node>((a, b) => {
				return a.equal (b);
			});
		}
		
		public void add (GLib.Value val) {
			nodes.add (new Json.Node (val));
		}
		
		public void add_array_element (Json.Array array) {
			nodes.add (new Json.Node (array));
		}
		
		public void add_object_element (Json.Object object) {
			nodes.add (new Json.Node (object));
		}
		
		public void add_string_element (string str) {
			nodes.add (new Json.Node (str));
		}
		
		public void add_double_element (double number) {
			nodes.add (new Json.Node (number));
		}
		
		public void add_boolean_element (bool val) {
			nodes.add (new Json.Node (val));
		}
		
		public void add_int_element (int64 integer) {
			nodes.add (new Json.Node (integer));
		}
		
		public void add_null_element() {
			nodes.add (new Json.Node (null));
		}
		
		public void add_datetime_element (DateTime dt) {
			nodes.add (new Json.Node (dt));
		}
		
		public void add_regex_element (Regex regex) {
			nodes.add (new Json.Node (regex));
		}
		
		public void add_binary_element (Bytes bytes) {
			nodes.add (new Json.Node (bytes));
		}
		
		public new Json.Node get (int index) {
			if (index < 0 || index >= nodes.size)
				return new Json.Node();
			return nodes[index];
		}
		
		public Json.Object get_object_element (int index) {
			return this[index].as_object();
		}
		
		public Json.Array get_array_element (int index) {
			return this[index].as_array();
		}
		
		public string get_string_element (int index) {
			return this[index].as_string();
		}
		
		public int64 get_int_element (int index) {
			return this[index].as_int();
		}
		
		public bool get_boolean_element (int index) {
			return this[index].as_boolean();
		}
		
		public double get_double_element (int index) {
			return this[index].as_double();
		}
		
		public bool get_null_element (int index) {
			return this[index].is_null();
		}
		
		public DateTime get_datetime_element (int index) {
			return this[index].as_datetime();
		}
		
		public Regex get_regex_element (int index) {
			return this[index].as_regex();
		}
		
		public Bytes get_binary_element (int index) {
			return this[index].as_binary();
		}
		
		public new void set (int index, GLib.Value? value) {
			if (index < 0 || index >= nodes.size)
				return;
			nodes[index] = new Json.Node (value);
		}
		
		public void set_object_element (int index, Json.Object val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_array_element (int index, Json.Array val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_string_element (int index, string val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_boolean_element (int index, bool val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_int_element (int index, int64 val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_double_element (int index, double val) {
			this[index] = new Json.Node (val);
		}
		
		public void set_null_element (int index) {
			this[index] = new Json.Node (null);
		}
		
		public void set_datetime_element (int index, DateTime dt) {
			this[index] = dt;
		}
		
		public void set_regex_element (int index, Regex regex) {
			this[index] = regex;
		}
		
		public void set_binary_element (int index, Bytes bytes) {
			this[index] = bytes;
		}
		
		public bool equal (Json.Array array) {
			if (nodes.size != array.size)
				return false;
			for (var i = 0; i < nodes.size; i++)
				if (!nodes[i].equal (array[i]))
					return false;
			return true;
		}
		
		public void clear() {
			nodes.clear();
		}
		
		public bool remove (Json.Node node) {
			return nodes.remove (node);
		}
		
		public Json.Node remove_at (int index) {
			if (index < 0 || index >= nodes.size)
				return new Json.Node();
			return nodes.remove_at (index);
		}
		
		public Json.Array slice (int start, int stop) {
			var array = new Json.Array();
			nodes.slice (start, stop).foreach (node => {
				array.add (node);
				return true;
			});
			return array;
		}
		
		public void insert (int index, Json.Node node) {
			if (index < 0)
				return;
			if (index >= nodes.size)
				nodes.add (node);
			else
				nodes.insert (index, node);
		}
		
		public int index_of (GLib.Value val) {
			var node = new Json.Node (val);
			return nodes.index_of (node);
		}
		
		public bool contains (GLib.Value val) {
			return index_of (val) >= 0;
		}
		
		public void foreach (Func<Json.Node> func) {
			nodes.foreach (node => {
				func (node);
				return true;
			});
		}
		
		public string to_string() {
			var gen = new Generator();
			gen.root = new Json.Node (this);
			return gen.to_string();
		}
		
		public NodeType is_unique {
			get {
				if (nodes.size == 0)
					return NodeType.NULL;
				for (var i = 1; i < nodes.size; i++)
					if (nodes[i].node_type != nodes[0].node_type)
						return NodeType.NULL;
				return nodes[0].node_type;
			}
		}
		
		public int size {
			get {
				return nodes.size;
			}
		}
	}
}
