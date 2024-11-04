package refactor.discover;

class FileList {
	public final files:Map<String, File> = [];

	public function new() {}

	public function addFile(file:File) {
		files.set(file.name, file);
	}

	public function getFile(fileName:String):Null<File> {
		return files.get(fileName);
	}

	public function removeFile(fileName:String) {
		files.remove(fileName);
	}
}
