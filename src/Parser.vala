namespace Json {
	internal static bool is_valid_string (string str) {
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
	
	public errordomain ReadError {
		NULL,
		INVALID
	}
	
	public class Parser : GLib.Object {
		Scanner scanner;
		FileStream stream;

		public Parser (string text) {
			scanner = new Scanner (null);
			scanner.input_text (text, text.length);
		}
		
		public Parser.file (string path) throws GLib.Error {
			scanner = new Scanner (null);
			stream = FileStream.open (path, "r");
			if (stream == null)
				throw new ReadError.NULL ("file doesn't exist.");
			scanner.input_file (stream.fileno());
		}
		
		public signal void parsing_start();
		public signal void parsing_end (TimeSpan duration);
		
		public void parse() throws GLib.Error {
			var dt = new DateTime.now_local();
			parsing_start();
			var token = scanner.get_next_token();
			if (token == TokenType.LEFT_BRACE)
				root = new Json.Node (read_array());
			else if (token == TokenType.LEFT_CURLY)
				root = new Json.Node (read_object());
			else
				throw new ReadError.INVALID ("invalid JSON document.");
			parsing_end (new DateTime.now_local().difference (dt));
		}
		
		public Json.Node root { get; private set; }
		
		Json.Array read_array() throws GLib.Error {
			var token = scanner.cur_token();
			if (token == TokenType.NONE)
				token = scanner.get_next_token();
			if (token != TokenType.LEFT_BRACE)
				throw new ReadError.INVALID ("invalid character. expected '[', found '%c'.".printf (scanner.cur_token()));
			var array = new Json.Array();
			while (true) {
				token = scanner.get_next_token();
				if (token == TokenType.LEFT_BRACE)
					array.add_array_element (read_array());
				else if (token == TokenType.LEFT_CURLY)
					array.add_object_element (read_object());
				else if (token == TokenType.STRING)
					array.add_string_element (scanner.cur_value().string);
				else if (token == '-') {
					token = scanner.get_next_token();
					if (token == TokenType.INT)
						array.add_integer_element ((-1) * (int64)scanner.cur_value().int64);
					else if (token == TokenType.FLOAT)
						array.add_double_element ((-1) * scanner.cur_value().float);
					else
						throw new ReadError.INVALID ("current value is not a number.");
				}
				else if (token == TokenType.INT)
					array.add_integer_element ((int64)scanner.cur_value().int64);
				else if (token == TokenType.FLOAT)
					array.add_double_element (scanner.cur_value().float);
				else if (token == TokenType.IDENTIFIER) {
					string id = scanner.cur_value().identifier;
					if (id == "null")
						array.add_null_element();
					else if (id == "true" || id == "false")
						array.add_boolean_element (id == "true");
					else
						throw new ReadError.INVALID ("invalid identifier: %s.".printf (id));
				}
				else
					throw new ReadError.INVALID ("invalid element for array.");
				token = scanner.get_next_token();
				if (token == TokenType.RIGHT_BRACE)
					return array;
				if (token != TokenType.COMMA)
					throw new ReadError.INVALID ("invalid end of element.");
			}
			assert_not_reached();
		}
	
		Json.Object read_object() throws GLib.Error {
			var token = scanner.cur_token();
			if (token == TokenType.NONE)
				token = scanner.get_next_token();
			if (token != TokenType.LEFT_CURLY)
				throw new ReadError.INVALID ("invalid character. expected '{', found '%c'.".printf (scanner.cur_token()));
			var object = new Json.Object();
			while (true) {
				token = scanner.get_next_token();
				if (token != TokenType.STRING)
					throw new ReadError.INVALID ("can't find member key.");
				string id = scanner.cur_value().string;
				token = scanner.get_next_token();
				if (token != ':')
					throw new ReadError.INVALID ("can't find semicolon separator");
				token = scanner.get_next_token();
				if (token == TokenType.LEFT_BRACE)
					object.set_array_member (id, read_array());
				else if (token == TokenType.LEFT_CURLY)
					object.set_object_member (id, read_object());
				else if (token == TokenType.STRING)
					object.set_string_member (id, scanner.cur_value().string);
				else if (token == '-') {
					token = scanner.get_next_token();
					if (token == TokenType.INT)
						object.set_integer_member (id, (-1) * (int64)scanner.cur_value().int64);
					else if (token == TokenType.FLOAT)
						object.set_double_member (id, (-1) * scanner.cur_value().float);
					else
						throw new ReadError.INVALID ("current value is not a number.");
				}
				else if (token == TokenType.INT)
					object.set_integer_member (id, (int64)scanner.cur_value().int64);
				else if (token == TokenType.FLOAT)
					object.set_double_member (id, scanner.cur_value().float);
				else if (token == TokenType.IDENTIFIER) {
					string val = scanner.cur_value().identifier;
					if (val == "null")
						object.set_null_member (id);
					else if (val == "true" || val == "false")
						object.set_boolean_member (id, val == "true");
					else
						throw new ReadError.INVALID ("invalid identifier: %s.".printf (val));
				}
				else
					throw new ReadError.INVALID ("invalid member for object.");
				token = scanner.get_next_token();
				if (token == TokenType.RIGHT_CURLY)
					return object;
				if (token != TokenType.COMMA)
					throw new ReadError.INVALID ("invalid end of member.");
			}
			assert_not_reached();
		}
	}
}
