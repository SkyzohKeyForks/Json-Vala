namespace JsonVala
{
	public class Object : GLib.Object
	{
		Gee.HashMap<string,string> table;
		
		public Object.empty(){
			table = new Gee.HashMap<string,string>();
		}
		
		public Object(string data) throws JsonVala.Error
		{
			var str = data.replace ("\t","").replace ("\r","").replace ("\n","").strip ();
			this.parse(ref str);
		}
		
		internal Object.parse(ref string data) throws JsonVala.Error
		{
			this.empty();
			if(data[0] != '{')
				throw new JsonVala.Error.Start("invalid character (%s)".printf(data));
			data = data.substring (1).chug ();
			if(data[0] == '}')
				data = data.substring (1).chug ();
			else
			while(data.length > 0){
				string str = valid_string(data);
				data = data.substring (str.length+2).chug ();
				if(data[0] != ':')
					throw new JsonVala.Error.NotFound("':' char not found");
				data = data.substring (1).chug ();
				if(data[0] == ',' || data[0] == '}')
					throw new JsonVala.Error.NotFound("value not found");
				if(data[0] == '{'){
					var object = new Object.parse(ref data);
					table[str] = object.to_string();
				}else if(data[0] == '['){
					var array = new Array.parse (ref data);
					table[str] = array.to_string();
				}else if(data[0] == '"' || data[0] == '\''){
					var s = valid_string (data);
					data = data.substring (s.length+2).chug ();
					table[str] = "\"%s\"".printf(s);
				}else{
					int a = data.index_of ("}");
					int b = data.index_of (",");
					int c = (a == -1 && b != -1) ? b : 
							(a != -1 && b == -1) ? a : 
							(a > b) ? b : 
							(b > a) ? a : -1 ;
					if(c == -1)
						throw new JsonVala.Error.NotFound("end of member not found");
					var val = data.substring(0,c).strip();
					if(val != "false" && val != "true" && val != "null"){
						double d = -1;
						if(double.try_parse (val,out d) == false)
							throw new JsonVala.Error.Type("invalid value");
					}
					table[str] = val;
					data = data.substring(val.length).chug();
				}
				if(data[0] != ',' && data[0] != '}')
					throw new JsonVala.Error.Type("invalid end of section");
				bool end = (data[0] == '}') ? true : false;
				data = data.substring(1).chug();
				if(end)break;
			}
		}

		public Node? get_member(string id){
			if(!table.has_key (id))
				return null;
			return new Node(table[id]);
		}
		public Gee.List<Node> get_members(){
			var nlist = new Gee.ArrayList<Node>();
			this.foreach((name,node) => { nlist.add(node); });
			return nlist;
		}
		public Gee.Set<string> get_keys(){ return table.keys; }
		
		public Array? get_array_member(string id){ return get_member(id).as_array(); }
		public double get_double_member(string id){ return get_member(id).as_double(); }
		public Object? get_object_member(string id){ return get_member(id).as_object(); }
		public bool get_boolean_member(string id){ return get_member(id).as_bool(); }
		public double get_int_member(string id){ return get_member(id).as_int(); }
		public bool get_null_member(string id){ return (table[id] == "null") ? true : false; }
		public string get_string_member(string id){ return get_member(id).as_string(); }
		
		public void remove_member(string id){ table.unset(id); }

		public void set_member(string id, Node node){
			table[id] = node.str;
		}
		public void set_null_member(string id){ table[id] = "null"; }
		public void set_array_member(string id, Array array){ table[id] = array.to_string(); }
		public void set_boolean_member(string id, bool value){ table[id] = value.to_string(); }
		public void set_double_member(string id, double value){ table[id] = value.to_string(); }
		public void set_int_member(string id, int64 value){ table[id] = value.to_string(); }
		public void set_object_member(string id, Object value){ table[id] = value.to_string(); }
		public void set_string_member(string id, string value){
			try{
				string s = valid_string("\""+value+"\"");
				table[id] = "\""+value+"\"";
			}catch{}
		}
		
		public bool has_member(string id){
			return table[id] != null;
		}

		public delegate void ObjectForeach(string name, Node node);
		
		public void foreach(ObjectForeach func){
			table.foreach(entry => {
				func((string)entry.key,new Node((string)entry.value));
				return true;
			});
		}

		public string to_string(){
			if(table.keys.size == 0)
				return "{}";
			string s = "{ ";
			for(int i = 0; i < table.size - 1; i++) {
				s += "\""+table.keys.to_array()[i]+"\" : "+get_member(table.keys.to_array()[i]).to_string()+" , ";
			}
			s += "\""+table.keys.to_array()[table.size-1]+"\" : "
			+get_member(table.keys.to_array()[table.size-1]).to_string()+" }";
			return s;
		}
		public string dump(int indent = 0){
			if(table.keys.size == 0)
				return "{}";
			string ind = "";
			for(var i = 0; i < indent; i++)
				ind += "\t";
			string s = "{"+ind+"\n";
			for(int i = 0; i < table.size - 1; i++) {
				s += ind+"\t\""+table.keys.to_array()[i]+"\" : "+get_member(table.keys.to_array()[i]).dump(indent+1)+" ,\n";
			}
			s += ind+"\t\""+table.keys.to_array()[table.size-1]+"\" : "
			+get_member(table.keys.to_array()[table.size-1]).dump(indent+1)+"\n";
			s += ind+"}";
			return s;
		}
		
		public int size { get{ return table.size; } }
	}
}
