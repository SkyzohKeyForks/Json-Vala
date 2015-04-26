namespace MeeJson {
	public abstract class Writer : GLib.Object {
		public abstract void write_array (MeeJson.Array array);
		public abstract void write_object (MeeJson.Object object);
	}
	
	public class TextWriter : Writer {
		Mee.TextWriter text_writer;
		
		public TextWriter (Mee.TextWriter writer) {
			text_writer = writer;
		}
		
		public override void write_object (MeeJson.Object object) {
			text_writer.write (object.to_string());
		}
		
		public override void write_array (MeeJson.Array array) {
			text_writer.write (array.to_string());
		}
		
	}
}
