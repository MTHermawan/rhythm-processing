class Song {
  String id;
  String title;
  float bpm;
  String composer;
  
  SoundFile sound = null;
  PImage coverArt = null;

  Song(String id, String title, float bpm, String composer) {
    this.id = id;
    this.title = title;
    this.bpm = bpm;
    this.composer = composer;
    
    println(id);
    coverArt = loadImage(songPath + id + "/cover.jpg");
  }

  public boolean isValid() {
    if (id.isBlank() || title.isBlank() || bpm <= 0) return false;
    return true;
  };
}

Song SetupSongData(String songId) {
  JSONObject infoJson = loadJSONObject(songPath + songId + "/info.json");

  String songTitle = infoJson.getString("title");
  Float songBpm = infoJson.getFloat("bpm");
  String songComposer = infoJson.getString("composer");

  Song newSong = new Song(songId, songTitle, songBpm, songComposer);
  newSong.sound = new SoundFile(this, songPath + newSong.id + "/bgm.mp3");
  println(songPath + newSong.id + "/bgm.mp3");
    
  return newSong;
}

Song[] GetAllSongData() {
  int songSize = 0;
  
  String[] songIdList = GetDataDirList("songs");
  songSize = songIdList.length;
  Song[] allSongs = new Song[songSize];
  
  for (int i = 0; i < songSize; i++) {
    allSongs[i] = SetupSongData(songIdList[i]);
  }
  
  return allSongs;
}

Song GetSong(String songId) {
  for (int i = 0; i < songList.length; i++) {
    if (songId.compareToIgnoreCase(songList[i].id) == 0) 
    {
      return songList[i];
    }
  }
  return null;
}
