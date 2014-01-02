namespace Json {
	public errordomain JsonError
	{
		NULL,
		INVALID,
		LENGTH,
		NOT_FOUND,
		TYPE
	}

	public static DateTime datetime_from_string (string str)
	{
		var tv = TimeVal();
		tv.from_iso8601 (str);
		return new DateTime.from_timeval_utc (tv);
	}

	public static string datetime_to_iso_string (DateTime dt)
	{
		var str = @"$dt";
		return str.substring(0, str.length-2)+":"+str.substring(str.length-2);
	}


	internal static string get_valid_id (Mee.Text.String data) throws GLib.Error
	{
		if (data[0] == '"' && data.str.index_of ("\"", 1) == -1 ||
		    data[0] == '\'' && data.str.index_of ("'", 1) == -1 ||
		    data.str.index_of("'") == -1 && data.str.index_of("\"") == -1 ||
		    data[0] != '"' && data[0] != '\'')
			throw new JsonError.INVALID ("invalid id string. %s".printf (data[0].to_string()));

		int index = data.str.index_of (data[0].to_string(), 1);
		if (!is_valid_id (data.substring (1, index - 1).str))
			throw new JsonError.INVALID ("invalid id string.");
		return data.substring (1, index - 1).str;
	}

	internal static bool is_valid_id(string id){
		double d;
		if(double.try_parse(id, out d))
			return false;
		return true;
	}
}
