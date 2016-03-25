namespace Json {
	static int[] n_to_bin (uint8 u)
	{
		var i = 128;
		uint8 tmp = u;
		int[] bin = new int[0];
		while (i >= 1)
		{
			bin += tmp / i;
			tmp -= i * (tmp / i);
			if (i == 1)
				break;
			i /= 2;
		}
		return bin;
	}

	static uint8 bin_to_n (int[] bin) {
		int res = 128 * bin[0]
				+  64 * bin[1]
				+  32 * bin[2]
				+  16 * bin[3]
				+   8 * bin[4]
				+   4 * bin[5]
				+   2 * bin[6]
				+       bin[7];
		return (uint8)res;
	}
	
	static string? guess_content_type (string? filename, uint8[]? data = null) {
		if (filename == null && data == null)
			return null;
		string output, err;
		File file = null;
		FileIOStream stream = null;
		if (filename == null) {
			file = File.new_tmp (null, out stream);
			stream.output_stream.write (data);
		}
		Process.spawn_command_line_sync ("file --mime-encoding %s".printf (filename == null ? file.get_path() : filename), out output, out err);
		if (stream != null)
			stream.close();
		return output.split ("\n")[0].split (": ")[1];
	}
	
	public abstract class Encoding : GLib.Object {
		public abstract uint8[] get_bytes (string str);
		public abstract string get_string (uint8[] bytes);
		public abstract unichar read_char (InputStream stream);
		
		public abstract string name { owned get; }
		
		public bool write_char (OutputStream stream, unichar u) {
			var bytes = get_bytes (u.to_string());
			return 0 < stream.write (bytes);
		}
		
		public static Encoding? guess (string? filename, uint8[]? data = null) {
			string mime = guess_content_type (filename, data);
			if (mime == null)
				return null;
			if (mime == "us-ascii")
				return new AsciiEncoding();
			if (mime == "iso-8859-1")
				return new Latin1Encoding();
			if (mime == "utf-16le")
				return new UnicodeEncoding (true, false);
			if (mime == "utf-16be")
				return new UnicodeEncoding (true);
			uint8[] buffer;
			if (data != null)
				buffer = data;
			else
				FileUtils.get_data (filename, out buffer);
			if (buffer.length >= 3 && buffer[0] == 239 && buffer[1] == 187 && buffer[2] == 191)
				return new Utf8Encoding (true);
			if (buffer.length >= 2 && buffer[0] == 255 && buffer[1] == 254) 
				return new UnicodeEncoding (true, false);
			if (buffer.length >= 2 && buffer[0] == 254 && buffer[1] == 255) 
				return new UnicodeEncoding();
			if (buffer.length >= 2 && buffer[0] > 0 && buffer[1] == 0)
				return new UnicodeEncoding (false, false);
			if (buffer.length >= 2 && buffer[0] == 0 && buffer[1] > 0)
				return new UnicodeEncoding (false);
			if (buffer.length >= 4) {
				if (buffer[0] >= 216 && buffer[0] <= 219 && buffer[2] >= 220 && buffer[2] <= 223)
					return new UnicodeEncoding (false);
				if (buffer[1] >= 216 && buffer[1] <= 219 && buffer[3] >= 220 && buffer[3] <= 223)
					return new UnicodeEncoding (false, false);
			}
			return new Utf8Encoding();
		}
	}
	
	public class AsciiEncoding : Encoding {
		public override uint8[] get_bytes (string str)
		{
			uint8[] data = new uint8[0];
			foreach (uint8 u in str.data)
				data += u >= 128 ? (uint8)'?' : u;
			return data;
		}
		
		public override string get_string (uint8[] bytes)
		{
			string s = "";
			foreach (uint8 u in bytes)
				s += u >= 128 ? "?" : ((char)u).to_string();
			return s;
		}
		
		public override unichar read_char (InputStream stream) {
			var buffer = new uint8[1];
			stream.read (buffer);
			return (buffer[0] > 127) ? '?' : (unichar)buffer[0];
		}
		
		public override string name {
			owned get {
				return "us-ascii";
			}
		}
	}
	
	public class Latin1Encoding : Encoding {
		public override uint8[] get_bytes (string str)
		{
			string s = (string)convert (str, str.length, "ISO_8859-1", "UTF-8");
			return s.data;
		}

		public override string get_string (uint8[] bytes)
		{
			return (string)convert ((string)bytes, bytes.length, "UTF-8", "ISO_8859-1");
		}
		
		public override unichar read_char (InputStream stream) {
			var buffer = new uint8[1];
			stream.read (buffer);
			return (unichar)buffer[0];
		}

		public override string name {
			owned get {
				return "iso-8859-1";
			}
		}
	}
	
	public class UnicodeEncoding : Encoding {
		public UnicodeEncoding (bool bom = true, bool big_endian = true) {
			GLib.Object (bom: bom, big_endian: big_endian);
		}
		
		public override uint8[] get_bytes (string str) {
			var data = new Gee.ArrayList<uint8>();
			if (bom)
				if (!big_endian)
					data.add_all_array ({ 255, 254 });
				else
					data.add_all_array ({ 254, 255 });
			string s = (string)convert (str, str.length, big_endian ? "UTF16BE" : "UTF16LE", "UTF-8");
			data.add_all_array (s.data);
			return data.to_array();
		}
		
		public override string get_string (uint8[] bytes) {
			var array = bytes;
			int bp = array.length;
			if(bom  && bytes.length > 2 && 
			(big_endian && bytes[0] == 254 && bytes[1] == 255 ||
			!big_endian && bytes[1] == 254 && bytes[0] == 255)){
				array.move (2, 0, bp - 2);
				bp -= 2;
			}
			return (string)convert ((string)array, bp, "UTF-8", big_endian ? "UTF16BE" : "UTF16LE");
		}
		
		public override unichar read_char (InputStream stream) {
			var buffer = new uint8[2];
			stream.read (buffer);
			if (bom && (buffer[0] == 254 && buffer[1] == 255 && big_endian ||
				buffer[1] == 254 && buffer[0] == 255 && !big_endian))
				stream.read (buffer);
			if (big_endian) {
				var bin = n_to_bin (buffer[0]);
				if (bin[0] == 1 && bin[1] == 1 && bin[2] == 0 && bin[3] == 1 && bin[4] == 1 && bin[5] == 0) {
					var buffer2 = new uint8[2];
					stream.read (buffer2);
					return get_string (new uint8[]{buffer[0], buffer[1], buffer2[0], buffer2[1]}).get_char();
				} else return get_string (buffer).get_char(); 
			} else {
				var bin = n_to_bin (buffer[1]);
				if (bin[0] == 1 && bin[1] == 1 && bin[2] == 0 && bin[3] == 1 && bin[4] == 1 && bin[5] == 0) {
					var buffer2 = new uint8[2];
					stream.read (buffer2);
					return get_string (new uint8[]{buffer[0], buffer[1], buffer2[0], buffer2[1]}).get_char();
				} else return get_string (buffer).get_char(); 
			}
		}
		
		public bool bom { get; construct; }
		public bool big_endian { get; construct; }
		
		public override string name {
			owned get {
				return "utf-16" + (big_endian ? "be" : "le") + (bom ? " (with BOM)" : "");
			}
		}
	}
	
	public class Utf8Encoding : Encoding {
		public Utf8Encoding (bool bom = false) {
			GLib.Object (bom : bom);
		}
		
		public override uint8[] get_bytes (string str) {
			var buffer = new Gee.ArrayList<uint8>();
			if (bom)
				buffer.add_all_array ({ 239, 187, 191 });
			buffer.add_all_array (str.data);
			return buffer.to_array();
		}
		
		public override string get_string (uint8[] bytes) {
			var array = bytes;
			if (bom && bytes.length >= 3 && bytes[0] == 239 && bytes[1] == 187 && bytes[2] == 191)
				array.move (3, 0, bytes.length - 3);
			return (string)array;
		}
		
		public override unichar read_char (InputStream stream) {
			var byte = new uint8[1];
			stream.read (byte);
			if (byte[0] < 128)
				return (unichar)byte[0];
			if (byte[0] >= 0xC2 && byte[0] < 0xE0) {
				var byte1 = new uint8[1];
				stream.read (byte1);
				return ((string)new uint8[]{byte[0], byte1[0]}).get_char();
			}
			if (byte[0] >= 0xE0 && byte[0] < 0xEF) {
				var byte1 = new uint8[2];
				stream.read (byte1);
				return ((string)new uint8[]{byte[0], byte1[0], byte1[1]}).get_char();
			}
			if (byte[0] >= 0xEF) {
				var byte1 = new uint8[2];
				stream.read (byte1);
				if (bom && byte[0] == 239 && byte1[0] == 187 && byte1[1] == 191)
					return read_char (stream);
				var byte2 = new uint8[1];
				stream.read (byte2);
				return ((string)new uint8[]{byte[0], byte1[0], byte1[1], byte2[0]}).get_char();
			}
			return 0;
		}
		
		public bool bom { get; construct; }
		
		public override string name {
			owned get {
				return "utf-8" + (bom ? " (with BOM)" : "");
			}
		}
	}
}
