package refactor.discover;

class FileList {
	public static final files:Array<File> = [];

	public static function addFile(file:File) {
		files.push(file);
	}

	public static function getFile(fileName:String):Null<File> {
		for (file in files) {
			if (file.name == fileName) {
				return file;
			}
		}
		return null;
	}
}
