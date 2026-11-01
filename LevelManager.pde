float songEndTime = -1;
float resultDelay = 3;

void LoadLevel(Song selectSong) {
  selectedSong = selectSong;

  if (selectedSong.isValid()) {
    println("PLAY clicked: " + selectedSong.title);
    println("Starting ResetGameplay");
    ResetGameplay();
    println("ResetGameplay completed");

    levelStartTime = time;
    menuState = "level";

    println("Entering gameplay");
    SetupMV();
  }
}

void ResetGameplay() {

  if (selectedSong.sound != null && selectedSong.sound.isPlaying()) {
    selectedSong.sound.stop();
  }

  if (guideSound != null && guideSound.isPlaying()) {
    guideSound.stop();
  }

  songStarted = false;
  songEnded = false;
  songEndTime = -1;

  for (int i = 0; i < currentJudgment.length; i++) {
    currentJudgment[i] = 0;
  }

  currentCombo = 0;
  maxCombo = 0;
  totalCombo = 0;
  totalScore = 0;

  lastJudgmentInfo = "";
  lastJudgmentInfoTime = -10;

  for (int i = 0; i < gameInput.length; i++) {
    gameInput[i] = false;
  }

  songDuration = 0;
  songTime = 0;
  songStartTime = 0;

  mvPauseDuration = 0;
  mvStartPause = 0;
  totalPauseDuration = 0;
  lastPlayedFrame = 0;
  delayedFramesSize = 0;

  guideTimeSize = 0;

  if (guideSound != null) guideSound.amp(sfxVolume / 100);

  chartManager.SetupChart();
}


void ReturnToMainMenu() {

  // Hentikan lagu hanya jika sedang diputar
  if (selectedSong.sound != null && selectedSong.sound.isPlaying()) {
    selectedSong.sound.stop();
  }

  // Hentikan guide sound hanya jika sedang diputar
  if (guideSound != null && guideSound.isPlaying()) {
    guideSound.stop();
  }

  // Reset status permainan
  songStarted = false;
  songEnded = false;

  // Kembali ke Main Menu
  mainMenuState = "root";
  menuState = "mainmenu";

  println("Successfully returned to Main Menu");
}

void LevelManager() {
  background(0);
  if (backgroundMV == null) drawImageFit(selectedSong.coverArt, 0, 0, width, height);

  boolean prepared = time > (levelStartTime + preparationTime);

  if (prepared)
  {
    if (time > (mvStartPause + mvPauseDuration))
    {
      PlayMV();
    }

    if (!songStarted && selectedSong.sound != null)
    {
      selectedSong.sound.play();
      selectedSong.sound.amp(musicVolume / 100);
      songStarted = true;
    }
  }

  // Tampilan 3D: latar, lintasan
  highway.drawBackdrop();
  highway.drawTrack();

  // Logika judgment
  UpdateHoldPerfect();
  UpdateMiss();

  // Tampilan 3D: not, pad tombol, HUD
  highway.drawNotes();
  highway.drawKeyPads();
  gameHUD.display();
  if (prepared) ShowDurationDebug();

  if (songStarted &&
    songDuration > 1 &&
    !selectedSong.sound.isPlaying() &&
    songEndTime < 0) {
    songEndTime = time;
  }

  if (songEndTime >= 0 && !songEnded && time > songEndTime + resultDelay) {

    songEnded = true;

    if (guideSound != null && guideSound.isPlaying()) {
      guideSound.stop();
    }

    println("Song Finished!");
    println("Final Score: " + totalScore);
    println("Max Combo: " + maxCombo);

    resultScreen.startAnimation();

    menuState = "result";
  }
}

// Hold yang masih ditekan sampai ekornya lewat dihitung Perfect
void UpdateHoldPerfect() {
  for (int i = 0; i < gameInput.length; i++) {
    if (!gameInput[i]) continue;

    for (int j = 0; j < chartSize; j++) {
      if (charts[j].lane != i || charts[j].state != 2) continue;
      if (songDuration > charts[j].hitTime + charts[j].holdDuration)
      {
        // Perfect Hold
        charts[j].state = 1;
        judgmentManager.AddCombo();
        currentJudgment[0]++;
        judgmentManager.SetJudgmentInfo("Perfect");
      }
    }
  }
}

// Not yang lewat batas Good tanpa ditekan menjadi Miss
void UpdateMiss() {
  for (int i = 0; i < chartSize; i++) {
    if (charts[i].state == 0 && songDuration > charts[i].hitTime + maxGoodTime) {
      currentJudgment[3]++;
      charts[i].state = -1;
      currentCombo = 0;
      judgmentManager.SetJudgmentInfo("Miss");
    }
  }
}

void ShowDurationDebug() {
  int second = (int)songDuration % 60;
  int minute = (int)songDuration / 60;
  pushStyle();
  fill(255, 150);
  textSize(14);
  textAlign(LEFT, TOP);
  if (minute > 0) text("Duration: " + minute + "m:" + second + "s", 12, 12);
  else text("Duration: " + second + "s", 12, 12);
  popStyle();
}
