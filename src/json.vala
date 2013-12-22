namespace Json
{
	internal static string valid_string(string data) throws GLib.Error
	{
		if(data[0] == '"' && data.index_of("\"",1) == -1 ||
		   data[0] == '\'' && data.index_of("'",1) == -1 ||
		   data.index_of("'") == -1 && data.index_of("\"") == -1 ||
		   data[0] != '"' && data[0] != '\'')
			throw new JsonError.INVALID ("invalid string : "+data);
			
		int ind = data.index_of(data[0].to_string(),1);
		string str = data.substring(1,ind-1);
		while(str[str.length-1] == '\\'){
			ind = data.index_of(data[0].to_string(),1+ind);
			if(ind == -1)
				throw new JsonError.NOT_FOUND ("end not found");
			str = data.substring(1,ind-1);
		}
		return str;
	}
	
	internal static bool is_valid_id(string id){
		double d;
		if(double.try_parse(id, out d))
			return false;
		if(id.contains("/") || id.contains("\\") ||
		   id.contains("[") || id.contains("]") ||
		   id.contains("{") || id.contains("}") ||
		   id.contains("(") || id.contains(")") ||
		   id.contains("'") || id.contains("\"") ||
		   id.contains("&") || id.contains("~") ||
		   id.contains("#") || id.contains("|") ||
		   id.contains("`") || id.contains("^") ||
		   id.contains("@") || id.contains("°") ||
		   id.contains("+") || id.contains(";") ||
		   id.contains("=") || id.contains("*") ||
		   id.contains("%") || id.contains("<") || 
		   id.contains(">"))
			return false;
		return true;
	}
	
	public class Parser : GLib.Object
	{
		public signal void parse_start();
		public signal void parse_end();
		
		public Node root { get; private set; }

		public void load_from_uri (string uri) throws GLib.Error
		{
			uint8[] buffer;
			File.new_for_uri (uri).load_contents (null, out buffer, null);
			load_from_buffer (buffer);
		}
		
		public void load_from_file (GLib.File file) throws GLib.Error
		{
			load_from_stream (file.read());
		}

		public void load_from_stream (GLib.InputStream stream) throws GLib.Error
		{	
			size_t br;
			uint8[] buffer = new uint8[1024];
			var list = new Gee.ArrayList<uint8>();
			stream.read_all (buffer, out br);
			while (br == 1024)
			{
				list.add_all_array (buffer);
				stream.read_all (buffer, out br);
			}
			if (br > 0)
			{
				buffer.resize ((int)br);
				list.add_all_array (buffer);
			}
			load_from_buffer (buffer);
		}
		
		public async void load_from_stream_async (GLib.InputStream stream, GLib.Cancellable? cancellable = null) throws GLib.Error
		{
			SourceFunc cb = load_from_stream_async.callback;
			ThreadFunc<void*> run = () => {
				size_t br;
				uint8[] buffer = new uint8[1024];
				var list = new Gee.ArrayList<uint8>();
				stream.read_all (buffer, out br);
				while (br == 1024)
				{
					list.add_all_array (buffer);
					stream.read_all (buffer, out br);
				}
				if (br > 0)
				{
					buffer.resize ((int)br);
					list.add_all_array (buffer);
				}
				load_from_buffer (buffer);
				Idle.add ((owned)cb);
				return null;
			};
			Thread.create<void*>(run, false);
			yield;
		}

		public void load_from_path(string path) throws GLib.Error
		{
			uint8[] buffer;
			File.new_for_path (path).load_contents (null, out buffer, null);
			load_from_buffer (buffer);
		}
		
		public void load_from_buffer (uint8[] data) throws GLib.Error
		{
			var encoding = Mee.Text.Encoding.correct_encoding (data);
			if (encoding == null)
				encoding = Mee.Text.Encoding.utf8;
			load_from_data (encoding.get_string (data));
		}

		public void load_from_data (string data) throws GLib.Error
		{
			parse_start();
			if(data[0] == '[')
				root = new Node (new Array (data).to_string ());
			else
				root = new Node (new Object (data).to_string ());
			parse_end();
		}
		
	}
	
	public errordomain JsonError
	{
		NULL,
		START,
		END,
		NOT_FOUND,
		LENGTH,
		TYPE,
		INVALID
	}
	
	public static string gobject_to_data(GLib.Object o){
		var klass = (ObjectClass)o.get_type().class_ref();
		var obj = new Json.Object.empty();
		foreach(ParamSpec spec in klass.list_properties()){
			GLib.Value val = GLib.Value(spec.value_type);
			o.get_property(spec.name, ref val);
			if(spec.value_type.is_object())
				obj.set_member(spec.name,new Json.Node(gobject_to_data(val.get_object())));
			else if(spec.value_type == typeof(string))
				obj.set_string_member(spec.name,val.get_string());
			else {
				Mee.Value mval = new Mee.Value.from_gval(val);
				obj.set_member(spec.name,new Json.Node(mval.val));
			}
		}
		return obj.dump(0);
	}
}
