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


	internal static string get_valid_id (string data, int start = 0) throws GLib.Error
	{
		if (data[start] == '"' && data.index_of ("\"", start + 1) == -1 ||
		    data[start] == '\'' && data.index_of ("'", start + 1) == -1 ||
		    data.index_of("'", start) == -1 && data.index_of("\"", start) == -1 ||
		    data[start] != '"' && data[start] != '\'')
			throw new JsonError.INVALID (@"invalid id string : $data");

		int index = data.index_of (data[start].to_string(), start + 1);
		return data.substring (start + 1, index - start - 1);
	}

	internal static bool is_valid_id(string id){
		double d;
		if(double.try_parse(id, out d))
			return false;
		return true;
	}
}
