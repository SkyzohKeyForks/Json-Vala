namespace Json {
	public class Parser {
		public signal void parsing_start();
		public signal void parsing_end (TimeSpan duration);
		
		public void load_from_uri (string uri) throws GLib.Error {
			uint8[] data;
			File.new_for_uri (uri).load_contents (null, out data, null);
			load_from_string ((string)data);
		}
		
		public void load_from_path (string path) throws GLib.Error {
			string json;
			FileUtils.get_contents (path, out json);
			load_from_string (json);
		}
		
		public void load_from_string (string json) throws GLib.Error {
			DateTime dts = new DateTime.now_local();
			parsing_start();
			var scanner = new Json.Scanner (json);
			while (scanner.peek().isspace())
				scanner.read();
			root = new Json.Node();
			if (scanner.peek() == '[')
				root.array = parse_array (scanner);
			else if (scanner.peek() == '{')
				root.object = parse_object (scanner);
			else
				throw new Json.Error.INVALID ("can't found start of json data.\n");
			parsing_end (new DateTime.now_local().difference (dts));
		}

		public Json.Node root { get; private set; }

		Json.Array parse_array (Json.Scanner scanner) throws Json.Error {
			if (scanner.peek() != '[')
				throw new Json.Error.TYPE ("current character isn't start of array.\n");
			scanner.read();
			while (scanner.peek().isspace())
				scanner.read();
			var array = new Json.Array();
			while (scanner.peek() != ']' && scanner.peek() != 0) {
				var val = new Json.Node();
				if (scanner.peek() == '[')
					val.array = parse_array (scanner);
				else if (scanner.peek() == '{')
					val.object = parse_object (scanner);
				else if (scanner.peek() == '"')
					val.str = parse_string (scanner);
				else if (scanner.peek() == ',')
					throw new Json.Error.INVALID ("untimely end of array element.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (scanner.peek() != ',' && scanner.peek() != ']' && !scanner.peek().isspace())
						sb.append_c (scanner.read());
					double res = 0; int64 i;
					if (int64.try_parse (sb.str, out i))
						val.integer = i;
					else if (double.try_parse (sb.str, out res))
						val.number = res;
					else if (sb.str == "false" || sb.str == "true")
						val.boolean = bool.parse (sb.str);
					else if (sb.str == "null")
						val.isnull = true;
					else
						throw new Json.Error.INVALID ("invalid array element : %s\n", sb.str);
				}
				while (scanner.peek().isspace())
					scanner.read();
				array.add_element (val);
				if (scanner.peek() != ',' && scanner.peek() != ']')
					throw new Json.Error.INVALID ("invalid en of array element\n");
				if (scanner.peek() == ',')
					scanner.read();
				while (scanner.peek().isspace())
					scanner.read();
			}
			if (scanner.read() != ']')
				throw new Json.Error.NOT_FOUND ("can't found end of array.\n");
			return array;
		}

		Json.Object parse_object (Json.Scanner scanner) throws Json.Error {
			if (scanner.read() != '{')
				throw new Json.Error.TYPE ("current character isn't start of object.\n");
			while (scanner.peek().isspace())
				scanner.read();
			var object = new Json.Object();
			while (scanner.peek() != '}' && scanner.peek() != 0) {
				string id = parse_string (scanner);
				id = id.substring (1, id.length - 2);
				while (scanner.peek().isspace())
					scanner.read();
				if (scanner.read() != ':')
					throw new Json.Error.INVALID ("cannot find colon separator.\n");
				while (scanner.peek().isspace())
					scanner.read();
				var val = new Json.Node();
				if (scanner.peek() == '[')
					val.array = parse_array (scanner);
				else if (scanner.peek() == '{')
					val.object = parse_object (scanner);
				else if (scanner.peek() == '"')
					val.str = parse_string (scanner);
				else if (scanner.peek() == ',')
					throw new Json.Error.INVALID ("untimely end of object member.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (scanner.peek() != ',' && scanner.peek() != '}' && !scanner.peek().isspace())
						sb.append_c (scanner.read());
					double res = 0; int64 i = 0;
					if (int64.try_parse (sb.str, out i))
						val.integer = i;
					else if (double.try_parse (sb.str, out res))
						val.number = res;
					else if (sb.str == "false" || sb.str == "true")
						val.boolean = bool.parse (sb.str);
					else if (sb.str == "null")
						val.isnull = true;
					else
						throw new Json.Error.INVALID ("invalid object member : %s\n", sb.str);
				}
				while (scanner.peek().isspace())
					scanner.read();
				object.set_member (id, val);
				if (scanner.peek() != ',' && scanner.peek() != '}')
					throw new Json.Error.INVALID ("invalid en of object member.\n");
				if (scanner.peek() == ',')
					scanner.read();
				while (scanner.peek().isspace())
					scanner.read();
			}
			if (scanner.read() != '}')
				throw new Json.Error.NOT_FOUND ("can't found end of object.\n");
			return object;
		}

		double parse_number (Json.Scanner scanner) throws GLib.Error {
			if (!scanner.peek().isdigit())
				throw new Json.Error.INVALID ("current character isn't a number.\n");
			StringBuilder sb = new StringBuilder();
			bool dot_passed = false;
			while (scanner.peek().isdigit() || scanner.peek() == '.') {
				if (scanner.peek() == '.') {
					if (dot_passed == true)
						throw new Json.Error.INVALID ("invalid format of number.\n");
					dot_passed = true;
					sb.append_c (scanner.read());
				}
				sb.append_c (scanner.read());
			}
			return double.parse (sb.str);
		}

		string parse_string (Json.Scanner scanner) throws GLib.Error {
			if (scanner.peek() != '"')
				throw new Json.Error.INVALID ("current character isn't valid.\n");
			StringBuilder sb = new StringBuilder();
			scanner.read();
			while (scanner.peek() != '"' && scanner.peek() != 0) {
				if (scanner.peek() == '\\') {
					sb.append_c (scanner.read());
					if (scanner.peek() == '"')
						sb.append_c (scanner.read());
					continue;
				}
				sb.append_c (scanner.read());
			}
			if (scanner.peek() == 0)
				throw new Json.Error.NOT_FOUND ("can't found end of string.\n");
			scanner.read();
			return "\"" + sb.str + "\"";
		}
	}
}