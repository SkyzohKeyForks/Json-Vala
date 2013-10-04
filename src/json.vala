namespace JsonVala
{
	public errordomain Error
	{
		Null,
		NotFound,
		Start,
		Type
	}

	internal static string valid_string(string data) throws JsonVala.Error
	{
		if(data[0] == '"' && data.index_of("\"",1) == -1 ||
		   data[0] == '\'' && data.index_of("'",1) == -1 ||
		   data.index_of("'") == -1 && data.index_of("\"") == -1 ||
		   data[0] != '"' && data[0] != '\'')
			throw new JsonVala.Error.Type("invalid string : "+data);
			
		int ind = data.index_of(data[0].to_string(),1);
		string str = data.substring(1,ind-1);
		while(str[str.length-1] == '\\'){
			ind = data.index_of(data[0].to_string(),1+ind);
			if(ind == -1)
				throw new JsonVala.Error.NotFound("end not found");
			str = data.substring(1,ind-1);
		}
		return str;
	}
	
	public class Generator : GLib.Object
	{
		public Generator(){
			indent = 0;
		}
		
		public string to_data(){
			return root.dump(indent);
		}
		public bool to_stream(Mee.IO.Stream file){
			file.seek(0);
			try{
				file.write(to_data().data);
				return true;
			}catch{
				return false;
			}
		}
		public void to_file(string path){
			var file = new Mee.IO.FileStream(path,Mee.IO.FileMode.Write);
			to_stream(file);
		}
		
		public Node root { get; set; }
		public int indent { get; set; }
	}

	public class Parser : GLib.Object
	{
		public signal void parse_start();
		public signal void parse_end();

		public Parser(){}

		public Node parse_stream(Mee.IO.Stream file) throws JsonVala.Error
		{
			file.seek(0);
			uint8[] data = file.read((int)file.size);
			return parse_data((string)data);
		}

		public Node parse_file(string path) throws JsonVala.Error
		{
			string data;
			try{
				FileUtils.get_contents(path,out data);
			}catch{
				return null;
			}
				return parse_data (data);
		}

		public Node parse_data(string data) throws JsonVala.Error
		{
			parse_start();
			var n = new Node(new Object(data).to_string());
			parse_end();
			return n;
		}
		
	}
	
	public static string gobject_to_data(GLib.Object o){
		var klass = (ObjectClass)o.get_type().class_ref();
		var obj = new JsonVala.Object.empty();
		foreach(ParamSpec spec in klass.list_properties()){
			GLib.Value val = GLib.Value(spec.value_type);
			o.get_property(spec.name, ref val);
			if(spec.value_type.is_object())
				obj.set_member(spec.name,new JsonVala.Node(gobject_to_data(val.get_object())));
			else if(spec.value_type == typeof(string))
				obj.set_string_member(spec.name,val.get_string());
			else {
				Mee.Value mval = new Mee.Value.from_gval(val);
				obj.set_member(spec.name,new JsonVala.Node(mval.val));
			}
		}
		return obj.dump(0);
	}
}
