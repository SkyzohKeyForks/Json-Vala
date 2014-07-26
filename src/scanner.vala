namespace Json {
	public static bool is_valid_string (string str) {
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
	
	internal class Scanner {
		string text;
		int len; int position;

		public Scanner (string json) {
			text = json;
			len = json.length;
			position = 0;
		}

		public char peek() {
			return text[position];
		}

		public char read() {
			if (position == len)
				return 0;
			return text[position++];
		}
	}
}