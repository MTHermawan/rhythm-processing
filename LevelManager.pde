

void LoadLevel(String songName) {

  println("PLAY clicked: " + songName);

  selectedSong = songName;

  println("Starting ResetGameplay");
  ResetGameplay();
  println("ResetGameplay completed");

  levelStartTime = time;
  menuState = "level";

  println("Entering gameplay");
}

void ResetGameplay() {

  if (song != null && song.isPlaying()) {
    song.stop();
  }

  if (guideSound != null && guideSound.isPlaying()) {
    guideSound.stop();
  }

  songStarted = false;
  songEnded = false;

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
  
  chartManager.SetupChart(selectedSong);
}


void ReturnToMainMenu() {

  // Hentikan lagu hanya jika sedang diputar
  if (song != null && song.isPlaying()) {
    song.stop();
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

void DrawBeatLines(float gap, float judgmentMargin, float chartSpeed) {
  if (songBpm <= 0) return;

  float pxPerSec  = chartSpeed * 100;           // sama dengan rumus posisi not
  float beatTime  = 60.0 / songBpm;
  float firstTime = songOffset + chartManager.TotalOffset();  // beat ke-0 (sudah termasuk offset not)

  float leftX  = -150 - (gap / 2);
  float rightX = -150 + (gap * (gameInput.length - 1)) + (gap / 2);

  // Rentang waktu yang terlihat di layar (y = 0 sampai y = -height)
  float tMin = songDuration + (judgmentMargin / pxPerSec);
  float tMax = songDuration + ((judgmentMargin + height) / pxPerSec);

  int firstBeat = max(0, floor((tMin - firstTime) / beatTime));
  int lastBeat  = ceil((tMax - firstTime) / beatTime);

  for (int b = firstBeat; b <= lastBeat; b++) {
    float t = firstTime + (b * beatTime);
    float y = judgmentMargin - (pxPerSec * (t - songDuration));

    if (b % 4 == 0) {          // awal birama: lebih tebal dan terang
      stroke(255, 255 * 0.45);
      strokeWeight(2);
    } else {                   // beat biasa
      stroke(255, 255 * 0.15);
      strokeWeight(1);
    }
    line(leftX, y, rightX, y);
  }
  noStroke();
}

void LevelManager() {
  background(0);

  if (time > (levelStartTime + preparationTime))
  {
    if (time > (mvStartPause + mvPauseDuration))
    {
      PlayMV(selectedSong);
    }

    if (!songStarted)
    {
      song.play();
      song.amp(musicVolume / 100);
      songStarted = true;
    }
  }

  // Judgment Area
  float gap = 100;
  float judgmentWidth = 80;
  float judgmentMargin = 80;

  if (judgmentMargin > 0) judgmentMargin = -judgmentMargin;

  pushMatrix();
  translate(width/2, height);

  for (int i = 0; i < gameInput.length; i++) {
    String keyText = KeyLabel(laneKeys[i]);

    // Play Area
    rectMode(CENTER);
    fill(10, 255 * 0.65);
    noStroke();
    rect(-150 + (gap * i), -height/2, judgmentWidth - (judgmentWidth - gap), height);

    rectMode(CORNERS);
    if (i == 0) {
      fill(255);
      rect(-150 + (gap * i) - (gap / 2), 0, -150 + (gap * i) + 1 - (gap / 2), -height);
    } else {
      fill(100);
      rect(-150 + (gap * i) - (gap / 2), 0, -150 + (gap * i) + 1 - (gap / 2), -height);
    }

    if (i == gameInput.length - 1) {
      fill(255);
      rect(-150 + (gap * (i + 1)) - (gap / 2), 0, -150 + (gap * (i + 1)) + 1 - (gap / 2), -height);
    }

    // Judgment Outline
    noFill();
    stroke(255);
    strokeWeight(1);
    ellipse(-150 + (gap * i), judgmentMargin, judgmentWidth, judgmentWidth);

    // Key hint
    fill(255, 255 * 0.35);
    textAlign(CENTER, CENTER);
    textSize(30);
    text(keyText, -150 + (gap * i), judgmentMargin - 1);

    // Pressed Indicator / Hold
    if (gameInput[i]) {
      fill(255, 255 * 0.5);
      ellipse(-150 + (gap * i), -80, 80, 80);

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
  noStroke();

  float chartSpeed = scrollSpeed;
  DrawBeatLines(gap, judgmentMargin, chartSpeed);

  // Chart
  for (int i=0; i < chartSize; i++) {
    if (charts[i].state == 1) continue;
    float linePos = -150 + (gap * charts[i].lane);
    float judgmentTime = judgmentMargin - (chartSpeed * 100 * (charts[i].hitTime - songDuration));
    float judgmentTimeHold = judgmentMargin - (chartSpeed * 100 * ((charts[i].hitTime + charts[i].holdDuration) - songDuration));
    float stopHoldingY = judgmentMargin - (chartSpeed * 100 * ((charts[i].hitTime + charts[i].heldTime) - songDuration));

    stroke(0);
    strokeWeight(1);
    if (charts[i].holdDuration > 0) {
      if (charts[i].state == 0 || charts[i].state == 2) fill(255, 255 * 0.65);
      else fill(120, 255 * 0.8);

      rectMode(CORNERS);
      if (charts[i].state == 2) {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), judgmentMargin);
      } else if (charts[i].state == 3) {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), stopHoldingY);
      } else {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), judgmentTime);
      }

      if (charts[i].state == 0 || charts[i].state == 2) fill(255);
      else fill(150);
      ellipse(linePos, judgmentTimeHold, judgmentWidth, judgmentWidth);
    }
    rectMode(CORNER);

    if (charts[i].state == 0 || charts[i].state == 2) fill(255);
    else fill(150);
    if (charts[i].state == 2) {
      ellipse(linePos, judgmentMargin, judgmentWidth, judgmentWidth);
    } else if (charts[i].state == 3) {
      ellipse(linePos, stopHoldingY, judgmentWidth, judgmentWidth);
    } else {
      ellipse(linePos, judgmentTime, judgmentWidth, judgmentWidth);
    }

    if (charts[i].state == 0 && songDuration > charts[i].hitTime + maxGoodTime) {
      currentJudgment[3]++;
      charts[i].state = -1;
      currentCombo = 0;
      judgmentManager.SetJudgmentInfo("Miss");
    }
  }

  popMatrix();

  judgmentManager.ShowJudgmentInfo();

  if (songStarted &&
      songDuration > 1 &&
      !song.isPlaying() &&
      !songEnded) {

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
