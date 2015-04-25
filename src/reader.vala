namespace MeeJson {
	public abstract class Reader : GLib.Object {
		public abstract Object read_object() throws GLib.Error;
		public abstract Array read_array() throws GLib.Error;
		public abstract string read_string() throws GLib.Error;
		public abstract DateTime read_date_time() throws GLib.Error;
	}
	
	public class TextReader : Reader {
		Mee.TextReader text_reader;
		
		public TextReader (Mee.TextReader reader) {
			text_reader = reader;
		}
		
		public enum TokenType {
			NULL,
			OBJECT,
			END_OBJECT,
			ARRAY,
			END_ARRAY,
			STRING,
			SEMI_COLON,
			COMMA
		}
		
		public TokenType next_token() {
			while (text_reader.peek().isspace())
				text_reader.read();
			if (text_reader.peek() == '[')
				return TokenType.ARRAY;
			if (text_reader.peek() == ']')
				return TokenType.END_ARRAY;
			if (text_reader.peek() == '{')
				return TokenType.OBJECT;
			if (text_reader.peek() == '}')
				return TokenType.END_OBJECT;
			if (text_reader.peek() == '"')
				return TokenType.STRING;
			if (text_reader.peek() == ':')
				return TokenType.SEMI_COLON;
			if (text_reader.peek() == ',')
				return TokenType.COMMA;
			return TokenType.NULL;
		}
		
		public override DateTime read_date_time() throws GLib.Error {
			string date_str = read_string();
			TimeVal tv = TimeVal();
			if (date_str == null || date_str.length == 0 || !tv.from_iso8601 (date_str))
				return new DateTime.now_local();
			return new DateTime.from_timeval_utc (tv);
		}
		
		public override Object read_object() throws GLib.Error {
			var token = next_token();
			if (token != TokenType.OBJECT)
				throw new MeeJson.Error.TYPE ("current character isn't start of object.\n");
			text_reader.read();
			token = next_token();
			var object = new MeeJson.Object();
			while (token != TokenType.END_OBJECT && text_reader.peek() != 0) {
				if (token != TokenType.STRING)
					throw new MeeJson.Error.TYPE ("can't find start of identifier.\n");
				string id = read_string();
				token = next_token();
				if (token != TokenType.SEMI_COLON)
					throw new MeeJson.Error.INVALID ("cannot find colon separator.\n");
				text_reader.read();
				token = next_token();
				if (token == TokenType.ARRAY)
					object.set_array_member (id, read_array());
				else if (token == TokenType.OBJECT)
					object.set_object_member (id, read_object());
				else if (token == TokenType.STRING)
					object.set_string_member (id, read_string());
				else if (token == TokenType.COMMA)
					throw new MeeJson.Error.INVALID ("untimely end of object member.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (text_reader.peek() != ',' && text_reader.peek() != '}' && !text_reader.peek().isspace())
						sb.append_unichar (text_reader.read());
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
						throw new MeeJson.Error.INVALID ("invalid object member : %s\n", sb.str);
				}
				token = next_token();
				if (token != TokenType.COMMA && token != TokenType.END_OBJECT)
					throw new MeeJson.Error.INVALID ("invalid end of object member. (%c)\n".printf ((char)text_reader.peek()));
				if (token == TokenType.END_OBJECT)
					break;
				text_reader.read();
				token = next_token();
			}
			if (token != TokenType.END_OBJECT)
				throw new MeeJson.Error.NOT_FOUND ("can't found end of object.\n");
			text_reader.read();
			return object;
		}
	
		public override Array read_array() throws GLib.Error {
			var token = next_token();
			if (token != TokenType.ARRAY)
				throw new MeeJson.Error.TYPE ("current character isn't start of array.\n");
			var array = new MeeJson.Array();
			text_reader.read();
			token = next_token();
			while (token != TokenType.END_ARRAY && text_reader.peek() != 0) {
				if (token == TokenType.ARRAY)
					array.add_array_element (read_array());
				else if (token == TokenType.OBJECT)
					array.add_object_element (read_object());
				else if (token == TokenType.STRING)
					array.add_string_element (read_string());
				else if (token == TokenType.COMMA)
					throw new MeeJson.Error.INVALID ("untimely end of array element.\n");
				else {
					StringBuilder sb = new StringBuilder();
					while (text_reader.peek() != ',' && text_reader.peek() != ']' && !text_reader.peek().isspace())
						sb.append_unichar (text_reader.read());
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
						throw new MeeJson.Error.INVALID ("invalid array element : %s\n", sb.str);
				}
				token = next_token();
				if (token != TokenType.COMMA && token != TokenType.END_ARRAY) {
					StringBuilder sb = new StringBuilder();
					while (text_reader.peek() != 0) {
						sb.append_unichar (text_reader.read());
					}
					throw new MeeJson.Error.INVALID ("invalid end of array element: %s\n".printf (sb.str));
				}
				if (token == TokenType.END_ARRAY)
					break;
				text_reader.read();
				token = next_token();
			}
			if (token != TokenType.END_ARRAY)
				throw new MeeJson.Error.NOT_FOUND ("can't found end of array.\n");
			text_reader.read();
			return array;
		}
	
		public override string read_string() throws GLib.Error {
			if (text_reader.peek() != '"')
				throw new MeeJson.Error.INVALID ("current character isn't valid.\n");
			StringBuilder sb = new StringBuilder();
			text_reader.read();
			while (text_reader.peek() != '"' && text_reader.peek() != 0) {
				if (text_reader.peek() == '\\') {
					sb.append_unichar (text_reader.read());
					if (text_reader.peek() == '"')
						sb.append_unichar (text_reader.read());
					continue;
				}
				sb.append_unichar (text_reader.read());
			}
			if (text_reader.peek() == 0)
				throw new MeeJson.Error.NOT_FOUND ("can't found end of string.\n");
			text_reader.read();
			return sb.str;
		}
	
	}
}
