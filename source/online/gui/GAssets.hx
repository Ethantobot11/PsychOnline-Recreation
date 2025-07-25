package online.gui;

class GAssets {
	public static function image(path:String) {
		var img = Paths.image(path, null, false);
		if (img == null)
			return null;

		Paths.excludeAsset('assets/images/' + path + ".astc");
		return img.bitmap.clone();
	}
}
