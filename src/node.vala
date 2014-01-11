namespace Json {
	public enum NodeType
	{
		NULL,
		ARRAY,
		BOOLEAN,
		DATETIME,
		DOUBLE,
		INTEGER,
		OBJECT,
		STRING
	}
	
	public class Node : GLib.Object
	{
		public Node (Value value)
		{
			this.value = value;
			if (as_array() != null)
				node_type = NodeType.ARRAY;
			else if (as_object() != null)
				node_type = NodeType.OBJECT;
			else if (as_datetime() != null)
				node_type = NodeType.DATETIME;
			else if (as_string() != null)
				node_type = NodeType.STRING;
			else if (data == "true" || data == "false")
				node_type = NodeType.BOOLEAN;
			else if (int64.try_parse(data))
				node_type = NodeType.INTEGER;
			else if (double.try_parse(data))
				node_type = NodeType.DOUBLE;
			else
				node_type = NodeType.NULL;
			
		}

		public Array? as_array()
		{
			try {
				return Array.parse (data);
			} catch {
				return null;
			}
		}

		public bool as_boolean()
		{
			return data == "true";
		}

		public DateTime? as_datetime()
		{
			if (as_string() == null)
				return null;
			var tv = TimeVal();
			var res = tv.from_iso8601 (as_string().replace (" ",""));
			if (!res)
				return null;
			return new DateTime.from_timeval_utc (tv);
		}

		public int64 as_int()
		{
			int64 res;
			if (int64.try_parse (data, out res))
				return res;
			return -1;
		}

		public double as_double()
		{
			double res;
			if (double.try_parse (data, out res))
				return res;
			return -1;
		}

		public Object? as_object()
		{
			try {
				return Object.parse (data);
			} catch {
				return null;
			}
		}

		public string? as_string()
		{
			try {
				return get_valid_id (data);
			} catch {
				return null;
			}
		}

		public string dump(int indent = 0){ 
			if (is_object())
				return as_object().dump (indent);
			if (is_array())
				return as_array().dump (indent);
			return data; 
		}

		public new Node? get (Value val)
		{
			if (is_array ()) {
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
				var a = as_array();
				if (v < 0 || v >= a.size)
					return null;
				return a[v];
			}
			if (is_object () && val.type() == typeof(string))
			{
				try {
					string id = get_valid_id ("\""+(string)val+"\"");
					var o = as_object();
					return o[id];
				} catch{
					print (@"$((string)val)\n");
				}
			}
			return null;
		}

		public bool is_array()
		{
			return node_type == NodeType.ARRAY;
		}

		public bool is_datetime()
		{
			return node_type == NodeType.DATETIME;
		}

		public bool is_boolean()
		{
			return node_type == NodeType.BOOLEAN;
		}

		public bool is_double()
		{
			return node_type == NodeType.DOUBLE;
		}

		public bool is_int()
		{
			return node_type == NodeType.INTEGER;
		}

		public bool is_null()
		{
			return node_type == NodeType.NULL;
		}

		public bool is_object()
		{
			return node_type == NodeType.OBJECT;
		}

		public bool is_string()
		{
			return node_type == NodeType.STRING;
		}

		public string to_string ()
		{
			return data;
		}

		public new void set (Value key, Value val)
		{
			if (is_object () && key.type() == typeof(string))
			{
				try {
					string id = get_valid_id ("\""+(string)key+"\"");
					var o = as_object();
					o[id] = val;
					data = o.to_string();
				} catch {
					
				}
			}
			if (is_array ())
			{
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
				var a = as_array();
				if (v < 0 || v > a.size)
					return;
				a[v] = val;
				data = a.to_string();
			}
		}

		internal Array get_nodes (string name)
		{
			var array = new Array ();
			if (is_object ())
			{
				as_object ().foreach ((n, node) => {
					if (n == name || name == "*")
						array.add_element (node);
					foreach (var sub in node.get_nodes (name))
						array.add_element (sub);
				});
			}
			if (is_array ())
			{
				foreach (var node in as_array ())
					foreach (var sub in node.get_nodes (name))
						array.add_element (sub);
						
			}
			return array;
		}

		string data;
		
		public NodeType node_type { get; private set; }
		public Value? value {
			owned get {
				if (is_int ())
					return as_int ();
				if (is_double ())
					return as_double ();
				if (is_object ())
					return as_object ();
				if (is_array ())
					return as_array ();
				if (is_boolean ())
					return as_boolean ();
				if (is_datetime())
					return as_datetime ();
				if (is_null ())
					return true;
				return as_string() == null ? null : as_string();
			}
			set {
				if (value.type().is_a(typeof(Node)))	
					data = ((Node)value).to_string ();
				else if (value.type().is_a(typeof(Object)))
					data = ((Object)value).to_string ();
				else if (value.type().is_a(typeof(Array)))
					data = ((Array)value).to_string ();
				else if (value.type() == typeof(DateTime))
					data = ((DateTime)value).to_string ();
				else if (value.type() == typeof(bool))
					data = ((bool)value).to_string ();
				else if (value.type() == typeof(double))
					data = ((double)value).to_string ();
				else if (value.type() == typeof(int64))
					data = ((int64)value).to_string ();
				else if (value.type() == typeof(uint64))
					data = ((uint64)value).to_string ();
				else if (value.type() == typeof(long))
					data = ((long)value).to_string ();
				else if (value.type() == typeof(ulong))
					data = ((ulong)value).to_string ();
				else if (value.type() == typeof(int))
					data = ((int)value).to_string ();
				else if (value.type() == typeof(uint))
					data = ((uint)value).to_string ();
				else if (value.type() == typeof(string))
					data = (string)value;
				else
					data = "null";
			}
		}
	}
}
