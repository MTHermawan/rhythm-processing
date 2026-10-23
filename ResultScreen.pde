
class ResultScreen {

  PImage songCover;

  int animationStartMillis = -1;

  void startAnimation() {
    animationStartMillis = millis();
  }


  void loadAssets() {
    songCover = loadImage(songPath + "bad_apple/cover.jpg");
  }

  void display() {
    pushStyle();

    if (animationStartMillis < 0) {
      startAnimation();
    }

    float elapsed = (millis() - animationStartMillis) / 1000.0;

    float scoreProgress = constrain(
      (elapsed - 0.2) / 1.2,
      0,
      1
    );

    float scoreEase = 1 - pow(1 - scoreProgress, 3);
    
    background(12, 16, 27);

    pushMatrix();

    translate(720, 84);

    stroke(100, 180, 235, 190);
    strokeWeight(4);

    line(0, -19, 0, 15);

    noFill();
    bezier(0, -19, 10, -20, 15, -25, 18, -20);

    noStroke();
    fill(100, 180, 235);
    ellipse(-8, 15, 16, 10);

    popMatrix();

    rectMode(CORNER);
    imageMode(CORNER);
    textAlign(LEFT, TOP);
    noStroke();

    for (int i = 0; i < 22; i++) {
      float barHeight = 10 + abs(sin(i * 0.7 + frameCount * 0.035)) * 45;

      fill(50, 110, 160, 35);
      rect(12 + i * 36, height - barHeight - 10, 15, barHeight, 3);
    }

    noFill();
    stroke(65, 145, 212, 80);
    strokeWeight(2);

    float waveOffset =
      sin(frameCount * 0.04) * 7;

    bezier(
      48, 486,
      260, 479 + waveOffset,
      535, 493 - waveOffset,
      752, 486
    );

    noStroke();
    
    fill(110, 190, 245);
    textSize(14);
    text("PROCESSYTHM / RESULTS", 48, 26);

    fill(255);
    textSize(46);
    text("STAGE CLEAR!", 48, 54);

    fill(160, 175, 195);
    textSize(16);
    text("Bad Apple!!  |  138 BPM", 48, 116);

    stroke(45, 62, 85);
    line(48, 150, 752, 150);
    noStroke();

    fill(22, 35, 53);
    rect(48, 168, 200, 200, 14);

    if (songCover != null) {
      image(songCover, 58, 178, 180, 180);
    }

    fill(20, 31, 49);
    rect(265, 168, 487, 200, 15);

    int resultPerfect = currentJudgment[0];
    int resultGreat = currentJudgment[1];
    int resultGood = currentJudgment[2];
    int resultMiss = currentJudgment[3];

    float resultScore =
      (resultPerfect * perfectScore) +
      (resultGreat * greatScore) +
      (resultGood * goodScore);

    float resultAccuracy = 0;

    if (fullCombo > 0) {
      resultAccuracy = constrain(
        (resultScore / fullCombo) * 100,
        0,
        100
      );
    }

    int displayScore = round(resultAccuracy * 10000);

    String resultRank = "-";

    if (fullCombo > 0) {
      if (resultAccuracy >= 95) {
        resultRank = "S";
      } else if (resultAccuracy >= 90) {
        resultRank = "A";
      } else if (resultAccuracy >= 80) {
        resultRank = "B";
      } else if (resultAccuracy >= 70) {
        resultRank = "C";
      } else {
        resultRank = "D";
      }
    }

    fill(160, 180, 205);
    textSize(14);
    text("TOTAL SCORE", 290, 193);

    fill(255);
    textSize(40);
    text(nf(round(displayScore * scoreEase), 7), 290, 225);

    stroke(52, 70, 95);
    line(290, 302, 596, 302);
    noStroke();

    fill(165, 180, 200);
    textSize(12);
    text("ACCURACY", 290, 319);

    fill(255);
    textSize(22);
    text(nf(resultAccuracy * scoreEase, 0, 2) + "%", 290, 337);

    fill(165, 180, 200);
    textSize(12);
    text("MAX COMBO", 475, 319);

    fill(255);
    textSize(22);
    text(round(maxCombo * scoreEase), 475, 337);

    fill(28, 53, 79);
    rect(615, 184, 116, 164, 13);

    textAlign(CENTER, CENTER);

    fill(145, 190, 225);
    textSize(12);
    text("RANK", 673, 210);

    fill(115, 210, 255);
    textSize(88);
    text(resultRank, 673, 275);

    textAlign(LEFT, TOP);
    
    statCard(48, "PERFECT", str(round(resultPerfect * scoreEase)), color(255, 220, 95));
    statCard(228, "GREAT", str(round(resultGreat * scoreEase)), color(240, 115, 210));
    statCard(408, "GOOD", str(round(resultGood * scoreEase)), color(120, 220, 155));
    statCard(588, "MISS", str(round(resultMiss * scoreEase)), color(250, 110, 100));

    drawButton(155, 501, 225, 56, "RESTART", true);
    drawButton(420, 501, 225, 56, "MAIN MENU", false);

    // Footer
    fill(110, 135, 165);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("RESULT SUMMARY", width / 2, 580);

    popStyle();
  }
  
  void statCard(float x, String label, String value, color accent) {
    noStroke();
    fill(20, 31, 49);
    rect(x, 390, 164, 83, 12);

    fill(accent);
    textAlign(LEFT, TOP);
    textSize(13);
    text(label, x + 15, 403);

    fill(255);
    textSize(29);
    text(value, x + 15, 428);
  }

  void drawButton(float x, float y, float w, float h,
                  String label, boolean primary) {

    boolean hovered =
      mouseX >= x && mouseX <= x + w &&
      mouseY >= y && mouseY <= y + h;

    noStroke();

    if (primary) {
      if (hovered) fill(85, 165, 225);
      else fill(55, 120, 175);
    } else {
      if (hovered) fill(60, 85, 120);
      else fill(36, 53, 78);
    }

    rect(x, y, w, h, 12);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(19);
    text(label, x + w / 2, y + h / 2);
  }

  void handleClick() {

    if (mouseX >= 155 && mouseX <= 380 &&
        mouseY >= 501 && mouseY <= 557) {

      println("Restarting Game");

      LoadLevel(selectedSong);
      return;
    }

    if (mouseX >= 420 && mouseX <= 645 &&
        mouseY >= 501 && mouseY <= 557) {

      println("Returning to Main Menu");

      ReturnToMainMenu();
      return;
    }
  }
}
