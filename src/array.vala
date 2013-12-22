namespace Json
{
	public class Array : GLib.Object
	{
		Gee.ArrayList<Json.Node> list;

		public Array(string data) throws GLib.Error
		{
			var str = data.strip ();
			this.parse (ref str);
		}
		
		public Array.empty(){ list = new Gee.ArrayList<Json.Node>(); }
		
		internal Array.parse(ref string data) throws GLib.Error
		{
			this.empty();
			if(data[0] != '[')
				throw new JsonError.START ("invalid character");
			data = data.substring (1).chug ();
			if(data[0] == ']')
				data = data.substring (1).chug ();
			else
			while(data.length > 0){
				
				if(data[0] == '['){
					var array = new Array.parse (ref data);
					list.add(new Node (array.to_string ()));
				}else if(data[0] == '{'){
					var object = new Object.parse (ref data);
					list.add(new Node (object.to_string()));
				}else if(data[0] == '"' || data[0] == '\''){
					var str = valid_string (data);
					data = data.substring (str.length+2).chug ();
					list.add (new Node ("\"%s\"".printf(str)));
				}else{
					int a = data.index_of ("]");
					int b = data.index_of (",");
					int c = (a == -1 && b != -1) ? b : 
							(a != -1 && b == -1) ? a : 
							(a > b) ? b : 
							(b > a) ? a : -1 ;
					if(c == -1)
						throw new JsonError.NOT_FOUND ("end of element not found");
					var val = data.substring(0,c).strip();
					if(val != "false" && val != "true" && val != "null"){
						double d = -1;
						if(double.try_parse (val,out d) == false)
							throw new JsonError.TYPE ("invalid value");
					}
					list.add(new Node (val));
					data = data.substring(val.length).chug();
				}
				if(data[0] != ',' && data[0] != ']')
						throw new JsonError.TYPE ("invalid end of element");
					bool end = (data[0] == ']') ? true : false;
					data = data.substring(1).chug();
					if(end)break;
			}
		}

		public Node? get_element(int index){
			if(index < 0 || index >= list.size)
				return null;
			return list[index];
		}
		public new Node? get (int index){ return get_element (index); }
		
		public Array? get_array_element(int index){ return get_element(index).as_array(); }
		public Object? get_object_element(int index){ return get_element(index).as_object(); }
		public double get_double_element(int index){ return get_element(index).as_double(); }
		public bool get_boolean_element(int index){ return get_element(index).as_bool(); }
		public int64 get_int_element(int index){ return get_element(index).as_int(); }
		public bool get_null_element(int index){ return list[index] == null || list[index].to_string() == "null"; }
		public string get_string_element(int index){ return get_element(index).as_string(); }
		
		public void set (int index, Node node){
			if(index < 0 || index >= list.size)
				return;
			list[index] = node;
		}
		public void set_array_element (int index, Array array) {
			if (index >= 0 && index < list.size)
				list[index] = array.as_node ();
		}
		public void set_object_element (int index, Object object) {
			if (index >= 0 && index < list.size)
				list[index] = object.as_node ();
		}
		public void set_double_element (int index, double val) {
			if (index >= 0 && index < list.size)
				list[index] = new Node (val.to_string ());
		}
		public void set_boolean_element (int index, bool val) {
			if (index >= 0 && index < list.size)
				list[index] = new Node (val.to_string ());
		}
		public void set_int_element (int index, int64 val) {
			if (index >= 0 && index < list.size)
				list[index] = new Node (val.to_string ());
		}
		public void set_null_element (int index) {
			if (index >= 0 && index < list.size)
				list[index] = new Node ("null");
		}
		public void set_string_element (int index, string str) {
			if (index >= 0 && index < list.size)
				try {
					string s = valid_string("\""+str+"\"");
					list[index] = new Node ("\""+str+"\"");
				}catch{}
		}
		
		public Json.Array slice (int start, int stop)
		{
			var array = new Json.Array.empty ();
			foreach (var elem in list.slice (start, stop))
				array.add_element (elem);
			return array;
		}
		
		public void add_element(Node node){ list.add(node); }
		public void add_array_element(Array array){ list.add(array.as_node()); }
		public void add_object_element(Object object){ list.add(object.as_node()); }
		public void add_double_element(double val){ list.add(new Node (val.to_string())); }
		public void add_boolean_element(bool val){ list.add(new Node (val.to_string())); }
		public void add_int_element(int64 i){ list.add(new Node (i.to_string())); }
		public void add_null_element(){ list.add(new Node ("null")); }
		public void add_string_element(string str){
			try{
				string s = valid_string("\""+str+"\"");
				list.add(new Node ("\""+str+"\""));
			}catch{}
		}
		public void remove_element(int index){
			if(index < 0 || index >= size)
				return;
			list.remove_at(index);
		}
		
		public Json.Node[] get_elements(){
			var nlist = new Gee.ArrayList<Node>();
			foreach (Json.Node node in this)
				nlist.add (node);
			return nlist.to_array ();
		}
		
		public Json.Node as_node () {
			return new Node (to_string ());
		}

		public string to_string(){
			if(list.size == 0)return "[]";
			string s = "[ ";
			for(int i = 0; i < list.size - 1; i++)
				s += list[i].to_string() + " , ";
			s += list[list.size - 1].to_string()+" ]";
			return s;
		}
		public string dump(int indent = 0){
			if(list.size == 0)return "[]";
			string ind = "";
			for(var i = 0; i < indent; i++)
				ind += "\t";
			string s = "[\n";
			for(int i = 0; i < list.size - 1; i++)
				s += ind+"\t"+list[i].dump(indent+1) + " ,\n";
			s += ind+"\t"+list[list.size - 1].dump(indent+1)+"\n";
			s += ind+"]";
			return s;
		}
		
		public int size {
			get {
				return list.size;
			}
		}
	}
}
