void LoadLevel(String songName) {
  menuState = "level";
  levelStartTime = time;
  selectedSong = songName;

  chartManager.SetupChart(selectedSong);
}

void LevelManager() {
  background(0);

  if (time > (levelStartTime + preparationTime))
  {
    if (time > (mvStartPause + mvPauseDuration))
    {
      PlayMV(selectedSong);
    }

    if (!song.isPlaying())
    {
      song.play();
      song.amp(musicVolume / 100);
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
    String keyText = "";
    if (i == 0) keyText = "D";
    else if (i == 1) keyText = "F";
    else if (i == 2) keyText = "J";
    else if (i == 3) keyText = "K";

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

  // Chart
  float chartSpeed = 10;
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
      // Miss
      //println("Miss");
      currentJudgment[3]++;
      charts[i].state = -1;
      currentCombo = 0;
      judgmentManager.SetJudgmentInfo("Miss");
    }

    //ChartGuide();
  }

  popMatrix();

  // Show Judgment Info
  judgmentManager.ShowJudgmentInfo();
}
