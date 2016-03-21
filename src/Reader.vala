namespace Json {
	public abstract class Reader : GLib.Object {
		public abstract unichar read();
		public abstract unichar peek();
		
		public abstract bool eof { get; }
	}
	
	public class StreamReader : Reader {
		EncodingInputStream stream;
		unichar u;
		
		public StreamReader (InputStream base_stream, Encoding? encoding = null) {
			stream = new EncodingInputStream (base_stream, encoding);
			u = stream.read_char();
		}
		
		public override unichar peek() {
			return u;
		}
		
		public override unichar read() {
			unichar c = u;
			u = stream.read_char();
			return c;
		}
		
		public override bool eof {
			get {
				return u == 0;
			}
		}
	}
	
	public class StringReader : Reader {
		string str;
		int len;
		int pos;
		
		public StringReader (string text) {
			str = text;
			len = text.length;
			pos = 0;
		}
		
		public override unichar peek() {
			int i = pos; unichar u;
			str.get_next_char (ref i, out u);
			return u;
		}
		
		public override unichar read() {
			unichar u;
			str.get_next_char (ref pos, out u);
			return u;
		}
		
		public override bool eof {
			get {
				int i = pos; unichar u;
				str.get_next_char (ref i, out u);
				return u == 0;
			}
		}
	}
}
