package refactor.discover;

class FileList {
	public final files:Array<File> = [];

	public function new() {}

	public function addFile(file:File) {
		files.push(file);
	}

	public function getFile(fileName:String):Null<File> {
		for (file in files) {
			if (file.name == fileName) {
				return file;
			}
		}
		return null;
	}
}
