using Mee.Text;

namespace Json {
	public class Object : GLib.Object
	{
		public delegate void ForeachFunc (string key, Node node);
		
		Gee.HashMap<string, Node> map;

		construct {
			map = new Gee.HashMap<string, Node>();
		}

		public string dump(int indent = 0){
			if(size == 0)
				return "{}";
			string ind = "";
			for(var i = 0; i < indent; i++)
				ind += "\t";
			string s = "{"+ind+"\n";
			for(int i = 0; i < size - 1; i++) {
				s += ind+"\t\""+map.keys.to_array()[i]+"\" : "+map.values.to_array()[i].dump(indent+1)+" ,\n";
			}
			s += ind+"\t\""+map.keys.to_array()[size-1]+"\" : "
			+map.values.to_array()[size - 1].dump(indent+1)+"\n";
			s += ind+"}";
			return s;
		}

		public void foreach (ForeachFunc func)
		{
			map.foreach (e => {
				func (e.key, e.value);
				return false;
			});
		}

		public new Node? get (Value val)
		{
			if (val.type() == typeof(string))
			{
				if (!map.has_key ((string)val))
					return null;
				return map[(string)val];
			}
			int v = -1;
			if (val.type() == typeof(int64))
				v = (int)(int64)val;
			if (val.type() == typeof(uint64))
				v = (int)(uint64)val;
			if (val.type() == typeof(long))
				v = (int)(long)val;
			if (val.type() == typeof(ulong))
				v = (int)(ulong)val;
			if (val.type() == typeof(int))
				v = (int)val;
			if (val.type() == typeof(uint))
				v = (int)(uint)val;
			if (v < 0 || v >= map.size)
				return null;
			return map[map.keys.to_array()[v]];
		}
		
		public Array? get_array_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return null;
			return node.as_array();
		}

		public bool get_boolean_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return false;
			return node.as_boolean();
		}

		public DateTime? get_datetime_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return null;
			return node.as_datetime();
		}

		public double get_double_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return -1;
			return node.as_double();
		}

		public int64 get_int_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return -1;
			return node.as_int();
		}

		public Node? get_member (Value key)
		{
			return this[key];
		}

		public bool get_null_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return true;
			return node.to_string () == "null";
		}

		public Object? get_object_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return null;
			return node.as_object();
		}

		public string? get_string_member (Value key)
		{
			var node = get_member (key);
			if (node == null)
				return null;
			return node.as_string();
		}

		public new void set (Value key, Value val)
		{
			if (val.type().is_a(typeof(Node)))	
				set_member (key, (Node)val.get_object());
			else if (val.type().is_a(typeof(Object)))
				set_object_member (key, (Object)val.get_object());
			else if (val.type().is_a(typeof(Array)))
				set_array_member (key, (Array)val.get_object());
			else if (val.type() == typeof(DateTime))
				set_datetime_member (key, (DateTime)val.get_boxed());
			else if (val.type() == typeof(bool))
				set_boolean_member (key, val.get_boolean());
			else if (val.type() == typeof(double))
				set_double_member (key, val.get_double());
			else if (val.type() == typeof(int64))
				set_int_member (key, val.get_int64());
			else if (val.type() == typeof(uint64))
				set_int_member (key, (int64)val.get_uint64());
			else if (val.type() == typeof(long))
				set_int_member (key, (int64)val.get_long());
			else if (val.type() == typeof(ulong))
				set_int_member (key, (int64)val.get_ulong());
			else if (val.type() == typeof(int))
				set_int_member (key, (int64)val.get_int());
			else if (val.type() == typeof(uint))
				set_int_member (key, (int64)val.get_uint());
			else if (val.type() == typeof(string))
				set_string_member (key, val.get_string());
			else
				set_null_member (key);
		}

		public void set_array_member (Value key, Array array)
		{
			set_member (key, new Node (array.to_string()));
		}

		public void set_boolean_member (Value key, bool val)
		{
			set_member (key, new Node (val.to_string()));
		}

		public void set_datetime_member (Value key, DateTime val)
		{
			TimeVal tv;
			val.to_timeval (out tv);
			set_string_member (key, tv.to_iso8601());
		}
		
		public void set_double_member (Value key, double val)
		{
			set_member (key, new Node (val.to_string()));
		}

		public void set_int_member (Value key, int64 val)
		{
			set_member (key, new Node (val.to_string()));
		}

		public void set_member (Value key, Node node)
		{
			int v = -1;
			if (key.type() == typeof(string))
				{
				try {
					var str = new Mee.Text.String ("'"+(string)key+"'");
					get_valid_id (str);
					map[(string)key] = node;
				} catch {
					
				}
			}
			else if (key.type() == typeof(int64))
					v = (int)(int64)key;
			else if (key.type() == typeof(uint64))
					v = (int)(uint64)key;
			else if (key.type() == typeof(long))
					v = (int)(long)key;
			else if (key.type() == typeof(ulong))
					v = (int)(ulong)key;
			else if (key.type() == typeof(int))
					v = (int)key;
			else if (key.type() == typeof(uint))
					v = (int)(uint)key;
			else
				return;
			if (v < 0 || v >= map.size)
				return;
			map[map.keys.to_array()[v]] = node;
		}

		public void set_null_member (Value key)
		{
			set_member (key, new Node ("null"));
		}

		public void set_object_member (Value key, Object object)
		{
			set_member (key, new Node (object.to_string()));
		}

		public void set_string_member (Value key, string val)
		{
			try {
				get_valid_id (new String (val));
				set_member (key, new Node (val));
			} catch {
				try {
					get_valid_id (new String ("\""+val+"\""));
					set_member (key, new Node ("\""+val+"\""));
				} catch {
					set_null_member (key);
				}
			}	
		}

		public string to_string()
		{
			if (map.keys.size == 0)
				return "{}";
			string s = "{ ";
			for (var i = 0; i < map.size - 1; i++)
				s += "\""+map.keys.to_array ()[i]+"\" : "+map.values.to_array ()[i].to_string ()+", ";
			s += "\""+map.keys.to_array ()[map.size - 1]+"\" : "+map.values.to_array ()[map.size - 1].to_string ()+" }";
			return s;
		}

		public string[] keys {
			owned get {
				return map.keys.to_array ();
			}
		}

		public Node[] values {
			owned get {
				return map.values.to_array ();
			}
		}
		
		public int size {
			get {
				return map.size;
			}
		}

		public static Object parse (string data) throws GLib.Error
		{
			var str = new String (data);
			return parse_internal (ref str);
		}

		internal static Object parse_internal (ref String str) throws GLib.Error
		{
			var o = new Object();
			str = str.strip ({'\t','\r','\n',' '});
			if (str[0] != '{')
				throw new JsonError.NOT_FOUND ("'{' character can't be found.");
			str = str.substring (1).chug ({'\t','\r','\n',' '});
			if (str[0] == '}'){
				str = str.substring (1).chug ({'\t','\r','\n',' '});
				return o;
			}
			while (str.size > 0)
			{
				string id = get_valid_id (str);
				str = str.substring (id.length+2).chug ({'\t','\r','\n',' '});
				if (str[0] != ':')
					throw new JsonError.NOT_FOUND ("':' char not found");
				str = str.substring (1).chug ({'\t','\r','\n',' '});
				if (str[0] == ',' || str[0] == '}')
					throw new JsonError.NOT_FOUND ("value not found");
				if (str[0] == '{')
					o[id] = new Node (Object.parse_internal (ref str).to_string ());
				else if (str[0] == '[')
					o[id] = new Node (Array.parse_internal (ref str).to_string ());
				else if (str[0] == '"' || str[0] == '\'')
				{
					var vid = get_valid_id (str);
					str = str.substring (vid.length+2).chug ({'\t','\r','\n',' '});
					o[id] = new Node ("\"%s\"".printf(vid));
				}
				else
				{
					int a = str.index_of ("}");
					int b = str.index_of (",");
					int c = b < a && b != -1 ? b : a;
					if(c == -1)
						throw new JsonError.NOT_FOUND ("end of member not found");
					var val = str.substring (0,c).strip ({'\t','\r','\n',' '}).str;
					if(val != "false" && val != "true" && val != "null"){
						double d = -1;
						if(double.try_parse (val,out d) == false)
							throw new JsonError.TYPE ("invalid value");
					}
					o[id] = new Node (val);
					str = str.substring (val.length).chug ({'\t','\r','\n',' '});
				}
				if(str[0] != ',' && str[0] != '}')
					throw new JsonError.TYPE ("invalid end of section");
				bool end = str[0] == '}' ? true : false;
				str = str.substring (1).chug ({'\t','\r','\n',' '});
				if(end)
					break;
			}
			return o;
		}
	}
}
