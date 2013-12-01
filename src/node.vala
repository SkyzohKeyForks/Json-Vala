namespace Json
{
	public enum NodeType
	{
		Null,
		Array,
		Object,
		Value
	}
	
	public class Node : GLib.Object
	{
		internal string str;
		
		public NodeType node_type { get; private set; }

		public Node(string val){ 
			str = val; 
			node_type = (is_array()) ? NodeType.Array : 
						(is_object()) ? NodeType.Object : 
						(str == "null") ? NodeType.Null : NodeType.Value;
		}

		public Object? as_object() throws GLib.Error
		{
			return new Object(str);
		}
		public Array? as_array() throws GLib.Error
		{
			return new Array(str);
		}
		public int64 as_int(){ return int64.parse(str); }
		public double as_double(){ return double.parse(str); }
		public bool as_bool(){ return (str == "true") ? true : false; }
		public string? as_string(){
			try{ return valid_string(str); }
			catch(GLib.Error e){ return null; }
		}
		public GLib.Value? as_value (){
			GLib.Value? val = null;
			try {
				var obj = as_object ();
				val = GLib.Value (typeof (Json.Object));
				val.set_object (obj);
				return val;
			}
			catch {
				try {
					var array = as_array ();
					val = GLib.Value (typeof (Json.Array));
					val.set_object (array);
					return val;
				}
				catch {
					int64 i;
					if (int64.try_parse (str, out i)){
						val = GLib.Value (typeof (int64));
						val.set_int64 (i);
						return val;
					}else{
						double d;
						if (double.try_parse (str, out d)){
							val = GLib.Value (typeof (double));
							val.set_double (d);
							return val;
						}else{
							if(as_string () != null){
								val = GLib.Value (typeof (string));
								val.set_string (as_string ());
								return val;
							}else{
								if(str == "true" || str == "false"){
									val = GLib.Value (typeof (bool));
									val.set_boolean (bool.parse (str));
									return val;
								}
							}
						}
					}
				}
			}
			return val;
		}

		public bool is_null(){ return (str == "null") ? true : false; }
		public bool is_bool(){ return (str == "true" || str == "false") ? true : false; }
		public bool is_double(){ double d; return double.try_parse (str, out d); }
		public bool is_int(){ int64 i; return int64.try_parse (str, out i); }
		public bool is_array(){
			try { var a = as_array(); return true; }
			catch { return false; }
		}
		public bool is_object(){ 
			try { var o = as_object(); return true; }
			catch { return false; }
		}
		public bool is_string(){ return (as_string () == null) ? false : true; }
		
		public Node? get(string id) throws GLib.Error
		{
			if(is_object ())
				return as_object ().get_member (id);
			if(is_array ())
				return as_array ().get_element (int.parse (id));
			return null;
		}
		
		internal Array get_nodes (string name)
		{
			var array = new Array.empty ();
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
		
		public void set (string id, Node node) throws GLib.Error
		{
			if (is_object ())
			{
				var o = as_object ();
				o.set_member (id, node);
				str = o.to_string ();
			}
			if (is_array ())
			{
				var a = as_array ();
				a[int.parse(id)] = node;
				str = a.to_string ();
			}
		}
		
		public string dump(int indent = 0){ 
			if(is_object())
				return as_object().dump(indent);
			if(is_array())
				return as_array().dump(indent);
			return str; 
		}
		public string to_string(){ return str; }
	}
}
