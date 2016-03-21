namespace Json {
	public class EncodingInputStream : FilterInputStream {
		public EncodingInputStream (InputStream base_stream, Encoding? enc = null) {
			GLib.Object (base_stream: base_stream, encoding: (enc == null ? new Utf8Encoding() : enc));
		}
		
		public unichar read_char() {
			return encoding.read_char (base_stream);
		}
		
		public string read_string() {
			StringBuilder builder = new StringBuilder();
			unichar u = read_char();
			while (u != 0) {
				builder.append_unichar (u);
				u = read_char();
			}
			return builder.str;
		}
		
		public override bool close (Cancellable? cancel = null) throws IOError {
			return base_stream.close (cancel);
		}
		
		public override ssize_t read (uint8[] buffer, Cancellable? cancel = null) throws IOError {
			return base_stream.read (buffer, cancel);
		}
		
		public Encoding encoding { get; construct; }
	}
	
	public class EncodingOutputStream : FilterOutputStream {
		public EncodingOutputStream (OutputStream base_stream, Encoding? enc = null) {
			GLib.Object (base_stream: base_stream, encoding: (enc == null ? new Utf8Encoding() : enc));
		}
		
		public bool write_char (unichar u) {
			return encoding.write_char (base_stream, u);
		}
		
		public bool write_string (string str) {
			var bytes = encoding.get_bytes (str);
			var count = base_stream.write (bytes);
			return count > 0;
		}
		
		public override bool close (Cancellable? cancel = null) throws IOError {
			return base_stream.close (cancel);
		}
		
		public override ssize_t write (uint8[] buffer, Cancellable? cancel = null) throws IOError {
			return base_stream.write (buffer, cancel);
		}
		
		public Encoding encoding { get; construct; }
	}
	
	public class EncodingFileStream : IOStream, Seekable {
		public static EncodingFileStream new_for_path (string path, Encoding? file_encoding = null) throws GLib.Error {
			Encoding? encoding = file_encoding;
			if (encoding == null)
				encoding = Encoding.guess (path);
			var stream = File.new_for_path (path).open_readwrite();
			return new EncodingFileStream (stream, encoding);
		}
		
		public static EncodingFileStream new_for_uri (string uri, Encoding? file_encoding = null) throws GLib.Error {
			Encoding? encoding = file_encoding;
			var file = File.new_for_uri (uri);
			if (encoding == null) {
				uint8[] data;
				file.load_contents (null, out data, null);
				encoding = Encoding.guess (null, data);
			}
			var stream = file.open_readwrite();
			return new EncodingFileStream (stream, encoding);
		}
		
		EncodingInputStream input;
		EncodingOutputStream output;
		FileIOStream iostream;
		
		internal EncodingFileStream (FileIOStream stream, Encoding? file_encoding = null) {
			this.iostream = stream;
			encoding = (file_encoding == null ? new Utf8Encoding() : file_encoding);
			this.input = new EncodingInputStream (iostream.input_stream, encoding);
			this.output = new EncodingOutputStream (iostream.output_stream, encoding);
		}
		
		public bool can_seek() {
			return iostream.can_seek();
		}
		
		public bool can_truncate() {
			return iostream.can_truncate();
		}
		
		public int64 tell() {
			return iostream.tell();
		}
		
		public bool seek (int64 offset, SeekType type, Cancellable? cancellable = null) throws Error {
			return iostream.seek (offset, type, cancellable);
		}
		
		public bool truncate (int64 offset, Cancellable? cancellable = null) throws Error {
			return iostream.truncate (offset, cancellable);
		}
		
		public Encoding encoding { get; private set; }
		
		public override InputStream input_stream {
			get {
				return input;
			}
		}
		
		public override OutputStream output_stream {
			get {
				return output;
			}
		}
	}
}
