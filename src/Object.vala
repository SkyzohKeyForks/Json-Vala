namespace Json {
	public class Object : GLib.Object {
		public static Object parse (string json) {
			var parser = new Json.Parser();
			try {
				parser.load_from_data (json);
				if (parser.root.node_type == NodeType.OBJECT)
					return parser.root.object;
			} catch {
				return new Json.Object();
			}
			return new Json.Object();
		}
		
		Gee.HashMap<string, Json.Node> map;
		Gee.ArrayList<string> list;
		
		construct {
			list = new Gee.ArrayList<string>();
			map = new Gee.HashMap<string, Json.Node>(key => { return str_hash (key); }, (a, b) => { return str_equal (a, b); }, (a, b) => { return a.equal (b); });
		}
		
		public new Json.Node get (GLib.Value index) {
			if (index.type() == typeof (string)) {
				string key = (string)index;
				if (map.has_key (key))
					return map[key];
				return new Json.Node();
			}
			int64 integer = -1;
			if (index.type() == typeof (int))
				integer = (int64)(int)index;
			else if (index.type() == typeof (uint))
				integer = (int64)(uint)index;
			else if (index.type() == typeof (int64))
				integer = (int64)index;
			else if (index.type() == typeof (uint64))
				integer = (int64)(uint64)index;
			else if (index.type() == typeof (long))
				integer = (int64)(long)index;
			else if (index.type() == typeof (ulong))
				integer = (int64)(ulong)index;
			else return new Json.Node();
			if (integer < 0 || integer >= map.size)
				return new Json.Node();
			return map[list[(int)integer]];
		}
		
		public Json.Object get_object_member (string key) {
			return this[key].as_object();
		}
		
		public Json.Array get_array_member (string key) {
			return this[key].as_array();
		}
		
		public bool get_boolean_member (string key) {
			return this[key].as_boolean();
		}
		
		public string get_string_member (string key) {
			return this[key].as_string();
		}
		
		public double get_double_member (string key) {
			return this[key].as_double();
		}
		
		public int64 get_int_member (string key) {
			return this[key].as_int();
		}
		
		public bool get_null_member (string key) {
			return this[key].is_null();
		}
		
		public DateTime get_datetime_member (string key) {
			return this[key].as_datetime();
		}
		
		public Regex get_regex_member (string key) {
			return this[key].as_regex();
		}
		
		public Bytes get_binary_member (string key) {
			return this[key].as_binary();
		}
		
		public new void set (GLib.Value index, GLib.Value? value) {
			if (index.type() == typeof (string)) {
				string key = (string)index;
				if (list.index_of (key) < 0)
					list.add (key);
				map[key] = new Json.Node (value);
				return;
			}
			int64 integer = -1;
			if (index.type() == typeof (int))
				integer = (int64)(int)index;
			else if (index.type() == typeof (uint))
				integer = (int64)(uint)index;
			else if (index.type() == typeof (int64))
				integer = (int64)index;
			else if (index.type() == typeof (uint64))
				integer = (int64)(uint64)index;
			else if (index.type() == typeof (long))
				integer = (int64)(long)index;
			else if (index.type() == typeof (ulong))
				integer = (int64)(ulong)index;
			else return;
			if (integer < 0 || integer >= map.size)
				return;
			var key = list[(int)integer];
			map[key] = new Json.Node (value);
		}
		
		public void set_object_member (string key, Json.Object object) {
			this[key] = object;
		}
		
		public void set_array_member (string key, Json.Array array) {
			this[key] = array;
		}
		
		public void set_string_member (string key, string str) {
			this[key] = str;
		}
		
		public void set_boolean_member (string key, bool boolean) {
			this[key] = boolean;
		}
		
		public void set_int_member (string key, int64 val) {
			this[key] = val;
		}
		
		public void set_double_member (string key, double number) {
			this[key] = number;
		}
		
		public void set_null_member (string key) {
			this[key] = new Json.Node (null);
		}
		
		public void set_datetime_member (string key, DateTime dt) {
			this[key] = dt;
		}
		
		public void set_regex_member (string key, Regex regex) {
			this[key] = regex;
		}
		
		public void set_binary_member (string key, Bytes bytes) {
			this[key] = bytes;
		}
		
		public bool equal (Json.Object object) {
			if (object.size != map.size)
				return false;
			for (var i = 0; i < map.size; i++)
				if (!this[i].equal (object[i]))
					return false;
			return true;
		}
		
		public bool has_key (string key) {
			return map.has_key (key);
		}
		
		public bool has (string key, GLib.Value val) {
			var node = new Json.Node (val);
			return map.has (key, node);
		}
		
		public bool unset (string key, out GLib.Value val = null) {
			Json.Node node;
			var res = map.unset (key, out node);
			if (!res)
				return false;
			else
				list.remove (key);
			val = node.value;
			return res;
		}
		
		public void clear() {
			list.clear();
			map.clear();
		}
		
		public void foreach (HFunc<string, Json.Node> func) {
			list.foreach (key => {
				var node = map[key];
				func (key, node);
				return true;
			});
		}
		
		public string to_string() {
			var gen = new Generator();
			gen.root = new Json.Node (this);
			return gen.to_string();
		}
		
		public string[] keys {
			owned get {
				return list.to_array();
			}
		}
		
		public Json.Node[] values {
			owned get {
				var array = new Gee.ArrayList<Json.Node>();
				list.foreach (key => {
					array.add (map[key]);
					return true;
				});
				return array.to_array();
			}
		}
		
		public int size {
			get {
				return map.size;
			}
		}
	}
}
