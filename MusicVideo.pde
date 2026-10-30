boolean SetupMV() {
  File movieFile = GetDataFile("songs/" + selectedSong.id + "/background_mv.mp4");
  if (movieFile.exists()) {
    backgroundMV = new Movie(this, movieFile.getAbsolutePath());
    return true;
  } else {
    backgroundMV = null;
    return false;
  }
}

boolean PlayMV()
{
  if (backgroundMV == null) return false;
  if (!backgroundMV.isPlaying()) {
    backgroundMV.play();
  }

  drawImageFit(backgroundMV, 0, 0, width, height);
  return true;

  //PImage mvFrameImg = null;
  //float fps = 30.0;
  //String imgFolder = "";
  //float offset = 0;
  //String frameNumber = "0000";
  //int maxFrame = 0;

  //if (songName.compareToIgnoreCase("bad_apple") == 0) {
  //  fps = 24.0;
  //  imgFolder = songPath + "bad_apple" + "/frames";
  //  maxFrame = 5258;
  //  //offset = -1.9; // (-) MV Too Fast, (+) MV Too Late

  //  lastPlayedFrame = (int)((songDuration - totalPauseDuration + offset) / (1 / fps));
  //  frameNumber = IntToString(lastPlayedFrame, 4);
  //  //println(frameNumber);

  //  if (lastPlayedFrame > 0 && lastPlayedFrame <= maxFrame) {
  //    mvFrameImg = loadImage(imgFolder + "/frame_" + frameNumber + ".jpg");
  //  }
  //}

  //if (mvFrameImg != null)
  //{
  //  image(mvFrameImg, 0, 0, width, height);
  //  fill(0, 255 * (bgDim / 100.0));
  //  rect(0, 0, width, height);

  //  fill(255, 255, 0);
  //  textSize(18);
  //  textAlign(LEFT, TOP);
  //  text("Frame: " + frameNumber + "/" + maxFrame, 8, 8);

  //  int second = (int)songDuration % 60;
  //  int minute = (int)songDuration / 60;
  //  if (minute > 0) text("Duration: " + minute + "m:" + second + "s", 8, 28);
  //  else text("Duration: " + second + "s", 8, 28);

  //  text("Perfect: " + currentJudgment[0], 8, 68);
  //  text("Great: " + currentJudgment[1], 8, 88);
  //  text("Good: " + currentJudgment[2], 8, 108);
  //  text("Miss: " + currentJudgment[3], 8, 128);

  //  text("Combo: " + currentCombo, 8, 168);
  //  text("Max Combo: " + maxCombo + "/" + fullCombo, 8, 188);

  //  float decrementScore = 0;
  //  for (int i = 0; i < currentJudgment.length; i++) {
  //    float score = 0;
  //    if (i == 0) {
  //      score = perfectScore;
  //    } else if (i == 1) {
  //      score = greatScore;
  //    } else if (i == 2) {
  //      score = goodScore;
  //    }
  //    decrementScore += (currentJudgment[i] - (currentJudgment[i] * score));
  //  }

  //  String decrementAccuracy = FloatToString((fullCombo - decrementScore) / fullCombo * 100, 3) + "%";
  //  text("Accuracy: " + decrementAccuracy, 8, 228);

  //  noStroke();
  //  float songProgress = (float)lastPlayedFrame / (float)maxFrame;
  //  fill(255, 255 * 0.65);
  //  rect(0, 0, width * songProgress, 5);
  //} else background(0);
}
