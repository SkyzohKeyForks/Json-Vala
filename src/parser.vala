using Mee;

namespace Json {
	static bool is_valid_string (string str) {
		if (str[0] == '"')
			return false;
		var pos = 1;
		while (pos < str.length) {
			if (str[pos] == '"' && str[pos - 1] != '\\')
				return false;
			pos++;
		}
		return true;
	}
	
	public class Parser {
		public signal void parsing_start();
		public signal void parsing_end (Mee.TimeSpan duration);
		
		public void load_from_uri (string uri, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			var file = File.new_for_uri (uri);
			if (encoding is Utf8Encoding) {
				uint8[] data;
				file.load_contents (null, out data, null);
				load (new StringReader ((string)data));
			}
			else
				load (new StreamReader (file.read(), encoding));
		}
		
		public void load_from_path (string path, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			if (encoding is Utf8Encoding) {
				uint8[] data;
				File.new_for_path (path).load_contents (null, out data, null);
				load (new StringReader ((string)data));
			}
			else
				load (new StreamReader.from_path (path, encoding));
		}
		
		public void load_from_stream (InputStream stream, Encoding encoding = Mee.Encoding.utf8) throws GLib.Error {
			load (new StreamReader (stream, encoding));
		}
		
		public void load_from_string (string json) throws GLib.Error {
			load (new StringReader (json));
		}

		void load (TextReader scanner) throws GLib.Error {
			DateTime dts = new DateTime.now_local();
			parsing_start();
			while (scanner.peek().isspace())
				scanner.read();
			if (scanner.peek() == '[')
				root = new Node (parse_array (scanner));
			else if (scanner.peek() == '{')
				root = new Node (parse_object (scanner));
			else
				throw new Json.Error.INVALID ("can't found start of json data.\n");
			parsing_end (Mee.TimeSpan.from_gtimespan (new DateTime.now_local().difference (dts)));
		}
		
		public Json.Node root { get; private set; }

		Json.Array parse_array (TextReader scanner) throws Json.Error {
			if (scanner.peek() != '[')
				throw new Json.Error.TYPE ("current character isn't start of array.\n");
			scanner.read();
			while (scanner.peek().isspace())
				scanner.read();
			var array = new Json.Array();
			while (scanner.peek() != ']' && scanner.peek() != 0) {
				if (scanner.peek() == '[')
					array.add_array_element (parse_array (scanner));
				else if (scanner.peek() == '{')
					array.add_object_element (parse_object (scanner));
				else if (scanner.peek() == '"')
					array.add_string_element (parse_string (scanner));
				else if (scanner.peek() == ',')
					throw new Json.Error.INVALID ("untimely end of array element.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (scanner.peek() != ',' && scanner.peek() != ']' && !scanner.peek().isspace())
						sb.append_unichar (scanner.read());
					double res = 0; int64 i;
					if (int64.try_parse (sb.str, out i))
						array.add_integer_element (i);
					else if (double.try_parse (sb.str, out res))
						array.add_double_element (res);
					else if (sb.str == "false" || sb.str == "true")
						array.add_boolean_element (bool.parse (sb.str));
					else if (sb.str == "null")
						array.add_null_element();
					else
						throw new Json.Error.INVALID ("invalid array element : %s\n", sb.str);
				}
				while (scanner.peek().isspace())
					scanner.read();
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

		Json.Object parse_object (TextReader scanner) throws Json.Error {
			if (scanner.read() != '{')
				throw new Json.Error.TYPE ("current character isn't start of object.\n");
			while (scanner.peek().isspace())
				scanner.read();
			var object = new Json.Object();
			while (scanner.peek() != '}' && scanner.peek() != 0) {
				string id = parse_string (scanner);
				while (scanner.peek().isspace())
					scanner.read();
				if (scanner.read() != ':')
					throw new Json.Error.INVALID ("cannot find colon separator.\n");
				while (scanner.peek().isspace())
					scanner.read();
				if (scanner.peek() == '[')
					object.set_array_member (id, parse_array (scanner));
				else if (scanner.peek() == '{')
					object.set_object_member (id, parse_object (scanner));
				else if (scanner.peek() == '"')
					object.set_string_member (id, parse_string (scanner));
				else if (scanner.peek() == ',')
					throw new Json.Error.INVALID ("untimely end of object member.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (scanner.peek() != ',' && scanner.peek() != '}' && !scanner.peek().isspace())
						sb.append_unichar (scanner.read());
					double res = 0; int64 i = 0;
					if (int64.try_parse (sb.str, out i))
						object.set_integer_member (id, i);
					else if (double.try_parse (sb.str, out res))
						object.set_double_member (id, res);
					else if (sb.str == "false" || sb.str == "true")
						object.set_boolean_member (id, bool.parse (sb.str));
					else if (sb.str == "null")
						object.set_null_member (id);
					else
						throw new Json.Error.INVALID ("invalid object member : %s\n", sb.str);
				}
				while (scanner.peek().isspace())
					scanner.read();
				if (scanner.peek() != ',' && scanner.peek() != '}')
					throw new Json.Error.INVALID ("invalid end of object member. (%c)\n".printf ((char)scanner.peek()));
				if (scanner.peek() == ',')
					scanner.read();
				while (scanner.peek().isspace())
					scanner.read();
			}
			if (scanner.read() != '}')
				throw new Json.Error.NOT_FOUND ("can't found end of object.\n");
			return object;
		}

		string parse_string (TextReader scanner) throws GLib.Error {
			if (scanner.peek() != '"')
				throw new Json.Error.INVALID ("current character isn't valid.\n");
			StringBuilder sb = new StringBuilder();
			scanner.read();
			while (scanner.peek() != '"' && scanner.peek() != 0) {
				if (scanner.peek() == '\\') {
					sb.append_unichar (scanner.read());
					if (scanner.peek() == '"')
						sb.append_unichar (scanner.read());
					continue;
				}
				sb.append_unichar (scanner.read());
			}
			if (scanner.peek() == 0)
				throw new Json.Error.NOT_FOUND ("can't found end of string.\n");
			scanner.read();
			return sb.str;
		}
	}
}
