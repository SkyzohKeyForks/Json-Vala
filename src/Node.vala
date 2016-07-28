namespace Json {
	public enum NodeType {
		NULL,
		INTEGER,
		BOOLEAN,
		NUMBER,
		STRING,
		ARRAY,
		OBJECT,
		REGEX,
		DATETIME,
		BINARY
	}
	
	public class Node : GLib.Object {
		internal Bytes binary;
		internal Regex regex;
		internal DateTime datetime;
		internal Json.Object object;
		internal Json.Array array;
		internal string str;
		internal string number_str;
		internal bool boolean;
		internal int64 integer;
		internal bool isn;
		
		public Node (GLib.Value? value = null) {
			node_type = NodeType.NULL;
			if (value == null)
				isn = true;
			else
				set_value_internal (value);
		}
		
		public void write_to (Writer writer) {
			writer.write_node (this);
		}
		
		public bool equal (Json.Node node) {
			bool b = binary == null ? node.binary == null : binary.compare (node.binary) == 0;
			bool o = object == null ? node.object == null : object.equal (node.object);
			bool d = datetime == null ? node.datetime == null : datetime.compare (node.datetime) == 0;
			bool r = regex == null ? node.regex == null : regex.get_pattern() == node.regex.get_pattern();
			bool a = array == null ? node.array == null : array.equal (node.array);
			return (b && r && o && d && a && str == node.str && number_str == node.number_str && boolean == node.boolean && 
				integer == node.integer && isn == node.isn);
		}
		
		public void foreach (Func<Json.Node> func) {
			if (array != null)
				array.foreach (func);
			else if (object != null)
				object.foreach ((key, val) => {
					func (val);
				});
		}
		
		public string to_string() {
			var gen = new Generator();
			gen.root = this;
			return gen.to_string();
		}
		
		public Json.Object as_object() {
			if (object != null)
				return object;
			return new Json.Object();
		}
		
		public Json.Array as_array() {
			if (array != null)
				return array;
			return new Json.Array();
		}
		
		public string as_string() {
			if (str != null)
				return str;
			return "";
		}
		
		public bool as_boolean() {
			return boolean == true;
		}
		
		public DateTime as_datetime() {
			if (datetime != null)
				return datetime;
			TimeVal tv = TimeVal();
			if (!tv.from_iso8601 (as_string()))
				return new DateTime.now_local();
			return new DateTime.from_timeval_local (tv);
		}
		
		public double as_double() {
			if (number_str != null)
				return double.parse (number_str);
			return 0;
		}
		
		public int64 as_int() {
			return integer;
		}
		
		public Regex as_regex() {
			if (regex == null) {
				try {
					return new Regex (as_string());
				}
				catch {
					return new Regex ("");
				}
			}
			return regex;
		}
		
		public Bytes as_binary() {
			if (binary != null)
				return binary;
			return new Bytes (Base64.decode (as_string()));
		}
		
		public bool is_null() {
			return isn;
		}
		
		public new Json.Node get (GLib.Value index) {
			if (object != null)
				return object[index];
			if (array == null)
				return new Json.Node();
			int64 i = -1;
			if (index.type() == typeof (int))
				i = (int64)(int)index;
			else if (index.type() == typeof (uint))
				i = (int64)(uint)index;
			else if (index.type() == typeof (int64))
				i = (int64)index;
			else if (index.type() == typeof (uint64))
				i = (int64)(uint64)index;
			else if (index.type() == typeof (long))
				i = (int64)(long)index;
			else if (index.type() == typeof (ulong))
				i = (int64)(ulong)index;
			else return new Json.Node();
			if (i < 0 || i >= array.length)
				return new Json.Node();
			return array[(int)i];
		}
		
		public NodeType node_type { get; private set; }
		
		/*
		public NodeType _node_type_ {
			get {
				if (isn)
					return NodeType.NULL;
				if (integer != null)
					return NodeType.INTEGER;
				if (number_str != null)
					return NodeType.NUMBER;
				if (boolean != null)
					return NodeType.BOOLEAN;
				if (str != null)
					return NodeType.STRING;
				if (array != null)
					return NodeType.ARRAY;
				if (object != null)
					return NodeType.OBJECT;
				if (regex != null)
					return NodeType.REGEX;
				if (datetime != null)
					return NodeType.DATETIME;
				if (binary != null)
					return NodeType.BINARY;
				return NodeType.NULL;
			}
		}
		*/
		
		void set_value_internal (GLib.Value val) {
			if (val.type().is_a (typeof (Json.Node))) {
				var node = (Json.Node)val;
				node_type = node.node_type;
				datetime = node.datetime;
				regex = node.regex;
				binary = node.binary;
				object = node.object;
				array = node.array;
				boolean = node.boolean;
				str = node.str;
				number_str = node.number_str;
				integer = node.integer;
				isn = node.isn;
			}
			else if (val.type().is_a (typeof (Json.Object))) {
				object = (Json.Object)val;
				node_type = NodeType.OBJECT;
			}
			else if (val.type().is_a (typeof (Json.Array))) {
				array = (Json.Array)val;
				node_type = NodeType.ARRAY;
			}
			else if (val.type() == typeof (bool)) {
				boolean = (bool)val;
				node_type = NodeType.BOOLEAN;
			}
			else if (val.type() == typeof (string)) {
				str = (string)val;
				node_type = NodeType.STRING;
			}
			else if (val.type() == typeof (double)) {
				number_str = "%g".printf ((double)val);
				node_type = NodeType.NUMBER;
			}
			else if (val.type() == typeof (float)) {
				number_str = "%g".printf ((float)val);
				node_type = NodeType.NUMBER;
			}
			else if (val.type() == typeof (int)) {
				integer = (int64)(int)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (uint)) {
				integer = (int64)(uint)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (int64)) {
				integer = (int64)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (uint64)) {
				integer = (int64)(uint64)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (long)) {
				integer = (int64)(long)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (ulong)) {
				integer = (int64)(ulong)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (uchar)) {
				integer = (int64)(uchar)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (char)) {
				integer = (int64)(char)val;
				node_type = NodeType.INTEGER;
			}
			else if (val.type() == typeof (DateTime)) {
				datetime = (DateTime)val;
				node_type = NodeType.DATETIME;
			}
			else if (val.type() == typeof (Regex)) {
				regex = (Regex)val;
				node_type = NodeType.REGEX;
			}
			else if (val.type() == typeof (Bytes)) {
				Bytes bin = (Bytes)val;
				binary = new Bytes (bin.get_data());
				node_type = NodeType.BINARY;
			}
			else if (val.type() == typeof (ByteArray)) {
				ByteArray bin = (ByteArray)val;
				binary = new Bytes (bin.data);
				node_type = NodeType.BINARY;
			}
			else {
				isn = true;
			}
		}
		
		Value val;
		
		public GLib.Value value {
			owned get {
				if (node_type == NodeType.INTEGER) {
					return integer;
				}
				if (node_type == NodeType.BINARY)
					return binary;
				if (node_type == NodeType.DATETIME)
					return datetime;
				if (node_type == NodeType.REGEX)
					return regex;
				if (node_type == NodeType.OBJECT)
					return object;
				if (node_type == NodeType.ARRAY)
					return array;
				if (node_type == NodeType.STRING)
					return str;
				if (node_type == NodeType.BOOLEAN) {
					return boolean;
				}
				if (node_type == NodeType.NUMBER) {
					return double.parse (number_str);
				}
				val = 0;
				return val;
			}
			set {
				set_value_internal (value);
			}
		}
	}
}
