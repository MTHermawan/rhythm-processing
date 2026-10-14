import processing.sound.*;

// Song Stuff
String selectedSong = "bad_apple";
float songStartTime = 0;
float songTime = 0;
float songBpm = 0;
float musicVolume = 60;
SoundFile song;
String songPath = "assets/songs/";

// Application Timing
float startTime;
float time;

// Level Timing
float levelStartTime = 0;
float preparationTime = 3;
float songDuration = 0;
float[][] charts = new float[9999][4]; // {Line Index, Judgment Time, Hold Duration}
int chartSize = 0;
float[][] guideTimes = new float[9999][2];
int guideTimeSize = 0;
SoundFile guideSound;
String sfxPath = "assets/sfx";

// Judgment
int[] currentJudgment = new int[4];
int currentCombo = 0;
int maxCombo = 0;
int totalCombo = 0;
int fullCombo = 0;
String lastJudgmentInfo = "";
float lastJudgmentInfoTime = -10;

float maxPerfectTime = 0.064;
float maxGreatTime = 0.127;
float maxGoodTime = 0.188;

// score 0 - 1
float perfectScore = 1;
float greatScore = 0.67;
float goodScore = 0.34;
float[] scores = new float[9999];
float totalScore = 0;

// <= 0.016 Crit. Perfect
// <= 0.064 Perfect
// <= 0.127 Great
// <= 0.202 Good

float mvPauseDuration = 0;
float mvStartPause = 0;
float totalPauseDuration = 0;
String[] delayedFrames = new String[10];
int delayedFramesSize = 0;
int lastPlayedFrame = 0;


// Game Manager
String menuState = "mainmenu";
String mainMenuState = "root";
boolean songEnded = false;
boolean[] gameInput = new boolean[4] ;


void setup()
{
  size(800, 600);
  startTime = millis();
  song = new SoundFile(this, songPath + "bad_apple" + "/bgm.mp3");
  guideSound = new SoundFile(this, sfxPath + "clap-lowerdb.mp3");
  background(0);

  for (int i=0; i < gameInput.length; i++) {
    gameInput[i] = false;
  }
  
  //guideSound.amp(20 / 100);
  SetupChart(selectedSong);
}

void draw()
{
  time = (millis() - startTime) / 1000;

  // MainMenu -> Level -> Score Result -> MainMenu
  if (menuState.compareToIgnoreCase("mainmenu") == 0)
  {
    MainMenu();
  } else if (menuState.compareToIgnoreCase("level") == 0)
  {
    LevelManager();
  }

  MouseCoordinate();

  totalScore = (currentJudgment[0] * perfectScore) + (currentJudgment[1] * greatScore) + (currentJudgment[2] * goodScore);
  totalCombo = currentJudgment[0] + currentJudgment[1] + currentJudgment[2];
}

void MainMenu()
{
  background(10);

  if (mainMenuState.compareToIgnoreCase("root") == 0)
  {
    pushMatrix();
    translate(width/2, 0);

    // Title
    fill(#6ba0cc);
    textSize(64);
    textAlign(CENTER, TOP);
    text("PROCESSYTHM", 0, 100);

    fill(255);
    textSize(26);

    // Select Song
    if (mouseX >= 326 && mouseX <= 474 && mouseY >= 260 && mouseY <= 278) {
      fill(255, 255, 0);
      text("> SELECT SONG <", 0, 260);
    } else {
      fill(255);
      text("SELECT SONG", 0, 260);
    }

    if (mouseX >= 348 && mouseX <= 454 && mouseY >= 300 && mouseY <= 318) {
      fill(255, 255, 0);
      text("> SETTINGS <", 0, 300);
    } else {
      fill(255);
      text("SETTINGS", 0, 300);
    }
    popMatrix();
  } else if (mainMenuState.compareToIgnoreCase("selectsong") == 0) {
    pushMatrix();

    // Top Bar
    fill(#6ba0cc);
    rectMode(CORNER);
    rect(0, 0, width, 60);

    // Back
    textSize(36);
    noStroke();
    if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) {
      fill(255, 255, 0);
    } else {
      fill(255);
    }
    triangle(40, 12, 40, 48, 20, 30);
    text("Back", 54, 16);

    // Menu Name
    fill(255);
    textAlign(CENTER, TOP);
    text("Select Song", width/2, 16);

    // Song Card
    fill(#6ba0cc);
    translate(width/2, height/2);
    rectMode(CENTER);
    rect(0, 0, 225, 320, 15);

    // Song Card Cover
    fill(0, 255 * 0.50);
    rect(0, -44, 190, 190, 4);
    PImage songCover = loadImage(songPath + "bad_apple" + "/cover.jpg");
    image(songCover, -90, -134, 180, 180);

    // Song Card Detail
    fill(0);
    textAlign(LEFT, TOP);
    textSize(24);
    text("Bad Apple!!", -96, 60);
    textSize(16);
    text("138 BPM", -96, 88);

    // Play Button
    fill(255);
    rect(0, 128, 190, 34, 4);
    textSize(22);
    textAlign(CENTER, CENTER);
    fill(#53a7ff);
    text("PLAY", 0, 126);

    popMatrix();
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    if (mainMenuState.compareToIgnoreCase("root") == 0)
    {
      // Select Song
      if (mouseX >= 326 && mouseX <= 474 && mouseY >= 260 && mouseY <= 278) {
        mainMenuState = "selectsong";
        println("Selecting Song");
      }

      // Settings
      if (mouseX >= 348 && mouseX <= 454 && mouseY >= 300 && mouseY <= 318) {
        //
      }
    } else if (mainMenuState.compareToIgnoreCase("selectsong") == 0) {
      // Back
      if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) {
        mainMenuState = "root";
      }

      if (mouseX >= 304 && mouseX <= 494 && mouseY >= 412 && mouseY <= 446) {
        LoadLevel("bad_apple");
      }
    }
  }
}

void keyPressed() {
  if (menuState.compareToIgnoreCase("level") == 0) {
    // Judgment Handler / Hit
    int lineIndex = -1;
    if (key == 'd' || key == 'D') {
      lineIndex = 0;
    }
    if (key == 'f' || key == 'F') {
      lineIndex = 1;
    }
    if (key == 'j' || key == 'J') {
      lineIndex = 2;
    }
    if (key == 'k' || key == 'K') {
      lineIndex = 3;
    }

    if (lineIndex >= 0) {
      if (gameInput[lineIndex]) return;
      gameInput[lineIndex] = true;
      println("Pressed " + key + " at " + songDuration);

      // Checking note to judge
      for (int i=0; i < chartSize; i++) {
        if (charts[i][0] != lineIndex || charts[i][3] != 0) continue;

        // 0.8 < 1 < 1.2
        // 1 < 0.5 +
        if (charts[i][1] >= songDuration - maxGoodTime && charts[i][1] <= songDuration + maxGoodTime) {
          if (charts[i][1] >= songDuration - maxPerfectTime && charts[i][1] <= songDuration + maxPerfectTime)
          {
            // Perfect
            //println("Perfect");
            currentJudgment[0]++;
            SetJudgmentInfo("Perfect");
          } else if (charts[i][1] >= songDuration - maxGreatTime && charts[i][1] <= songDuration + maxGreatTime)
          {
            // Great
            //println("Great");
            currentJudgment[1]++;
            SetJudgmentInfo("Great");
          } else
          {
            // Good
            //println("Good");
            currentJudgment[2]++;
            SetJudgmentInfo("Good");
          }
          AddCombo();

          if (charts[i][3] == 0)
          {
            if (charts[i][2] > 0) charts[i][3] = 2;
            else charts[i][3] = 1;
          }
          break;
        }
      }
    }
  }
}

void keyReleased() {
  if (menuState.compareToIgnoreCase("level") == 0) {
    // Judgment Handler
    int lineIndex = -1;
    if (key == 'd' || key == 'D') {
      lineIndex = 0;
    }
    if (key == 'f' || key == 'F') {
      lineIndex = 1;
    }
    if (key == 'j' || key == 'J') {
      lineIndex = 2;
    }
    if (key == 'k' || key == 'K') {
      lineIndex = 3;
    }

    if (lineIndex >= 0) {
      if (!gameInput[lineIndex]) return;
      gameInput[lineIndex] = false;

      for (int i = 0; i < chartSize; i++) {
        if (charts[i][0] != lineIndex || charts[i][3] != 2) continue;
        // Held Duration
        charts[i][4] = songDuration - charts[i][1];
        float holdJudgment = charts[i][4] / charts[i][2];
        print(holdJudgment);
        if (holdJudgment >= 0.35) {
          if (holdJudgment >= 0.90) {
            // Perfect Hold
            currentJudgment[0]++;
            charts[i][3] = 1;
            SetJudgmentInfo("Perfect");
          } else if (holdJudgment >= 0.65) {
            // Great Hold
            currentJudgment[1]++;
            charts[i][3] = 3;
            SetJudgmentInfo("Great");
          } else {
            // Good Hold
            currentJudgment[2]++;
            charts[i][3] = 3;
            SetJudgmentInfo("Good");
          }
          AddCombo();
        } else {
          // Miss Hold
          currentJudgment[3]++;
          currentCombo = 0;
          charts[i][3] = 3;
          SetJudgmentInfo("Miss");
        }
        break;
      }
    }
  }
}

void LoadLevel(String songName) {
  menuState = "level";
  levelStartTime = time;
  selectedSong = songName;

  SetupChart(selectedSong);
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
        if (charts[j][0] != i || charts[j][3] != 2) continue;
        if (songDuration > charts[j][1] + charts[j][2])
        {
          // Perfect Hold
          charts[j][3] = 1;
          AddCombo();
          currentJudgment[0]++;
          SetJudgmentInfo("Perfect");
        }
      }
    }
  }
  noStroke();

  // Chart
  float chartSpeed = 10;
  for (int i=0; i < chartSize; i++) {
    if (charts[i][3] == 1) continue;
    float linePos = -150 + (gap * charts[i][0]);
    float judgmentTime = judgmentMargin - (chartSpeed * 100 * (charts[i][1] - songDuration));
    float judgmentTimeHold = judgmentMargin - (chartSpeed * 100 * ((charts[i][1] + charts[i][2]) - songDuration));
    float stopHoldingY = judgmentMargin - (chartSpeed * 100 * ((charts[i][1] + charts[i][4]) - songDuration));

    stroke(0);
    strokeWeight(1);
    if (charts[i][2] > 0) {
      if (charts[i][3] == 0 || charts[i][3] == 2) fill(255, 255 * 0.65);
      else fill(120, 255 * 0.8);

      rectMode(CORNERS);
      if (charts[i][3] == 2) {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), judgmentMargin);
      } else if (charts[i][3] == 3) {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), stopHoldingY);
      } else {
        rect(linePos - (judgmentWidth / 2), judgmentTimeHold, linePos + (judgmentWidth / 2), judgmentTime);
      }

      if (charts[i][3] == 0 || charts[i][3] == 2) fill(255);
      else fill(150);
      ellipse(linePos, judgmentTimeHold, judgmentWidth, judgmentWidth);
    }
    rectMode(CORNER);

    if (charts[i][3] == 0 || charts[i][3] == 2) fill(255);
    else fill(150);
    if (charts[i][3] == 2) {
      ellipse(linePos, judgmentMargin, judgmentWidth, judgmentWidth);
    } else if (charts[i][3] == 3) {
      ellipse(linePos, stopHoldingY, judgmentWidth, judgmentWidth);
    } else {
      ellipse(linePos, judgmentTime, judgmentWidth, judgmentWidth);
    }

    if (charts[i][3] == 0 && songDuration > charts[i][1] + maxGoodTime) {
      // Miss
      //println("Miss");
      currentJudgment[3]++;
      charts[i][3] = -1;
      currentCombo = 0;
      SetJudgmentInfo("Miss");
    }

    //ChartGuide();
  }

  popMatrix();

  // Show Judgment Info
  ShowJudgmentInfo();
}

void PlayMV(String songName)
{
  //println(frameNumber);
  PImage mvFrameImg = null;
  float fps = 30.0;
  String imgFolder = "";
  float offset = 0;
  float backgroundDim = 0.65;
  String frameNumber = "0000";
  int maxFrame = 0;

  if (songName.compareToIgnoreCase("bad_apple") == 0) {
    fps = 24.0;
    imgFolder = songPath + "bad_apple" + "/frames";
    maxFrame = 5258;
    //offset = -1.9; // (-) MV Too Fast, (+) MV Too Late

    songDuration = time - (levelStartTime + preparationTime);
    lastPlayedFrame = (int)((songDuration - totalPauseDuration + offset) / (1 / fps));
    frameNumber = IntToString(lastPlayedFrame, 4);
    //println(frameNumber);

    if (lastPlayedFrame > 0 && lastPlayedFrame <= maxFrame) {
      mvFrameImg = loadImage(imgFolder + "/frame_" + frameNumber + ".jpg");
    }
  }

  if (mvFrameImg != null)
  {
    image(mvFrameImg, 0, 0, width, height);
    fill(0, 255 * backgroundDim);
    rect(0, 0, width, height);

    fill(255, 255, 0);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Frame: " + frameNumber + "/" + maxFrame, 8, 8);

    int second = (int)songDuration % 60;
    int minute = (int)songDuration / 60;
    if (minute > 0) text("Duration: " + minute + "m:" + second + "s", 8, 28);
    else text("Duration: " + second + "s", 8, 28);

    text("Perfect: " + currentJudgment[0], 8, 68);
    text("Great: " + currentJudgment[1], 8, 88);
    text("Good: " + currentJudgment[2], 8, 108);
    text("Miss: " + currentJudgment[3], 8, 128);

    text("Combo: " + currentCombo, 8, 168);
    text("Max Combo: " + maxCombo + "/" + fullCombo, 8, 188);

    float decrementScore = 0;
    for (int i = 0; i < currentJudgment.length; i++) {
      float score = 0;
      if (i == 0) {
        score = perfectScore;
      } else if (i == 1) {
        score = greatScore;
      } else if (i == 2) {
        score = goodScore;
      }
      decrementScore += (currentJudgment[i] - (currentJudgment[i] * score));
    }

    String decrementAccuracy = FloatToString((fullCombo - decrementScore) / fullCombo * 100, 3) + "%";
    text("Accuracy: " + decrementAccuracy, 8, 228);

    noStroke();
    float songProgress = (float)lastPlayedFrame / (float)maxFrame;
    fill(255, 255 * 0.65);
    rect(0, 0, width * songProgress, 5);
  } else background(0);
}

void SetupChart(String songName) {
  ResetChart();
  if (songName.compareToIgnoreCase("bad_apple") == 0) {
    songBpm = 138;
    float beatTime = 60/songBpm;

    // 1
    AddChart(0, 1.35, 0.9); // 2A
    AddChart(3, 1.35, 0);// 2B
    AddChart(2, 1.8, 0); // 1

    // 2
    AddChart(1, 2.25, 0); // 1
    AddChart(2, 2.65, 0); // 2A
    AddChart(3, 2.65, 0); // 2B
    AddChart(0, 2.76, 0); // 2A
    AddChart(1, 2.76, 0); // 2B
    AddChart(2, 2.87, 0); // 2A
    AddChart(3, 2.87, 0); // 2B
    AddChart(0, 2.98, 0); // 2A
    AddChart(1, 2.98, 0); // 2B

    // 3
    AddChart(2, 3.09, 0); // 2A
    AddChart(3, 3.09, 0.21); // 2B

    //float time = 4;
    //int line = 4;
    //for (int i=0; i < 500; i++)
    //{
    //  time += 0.025;
    //  if (i % 4 == 0) time += 0.1;

    //  line = (line + 4 - 1) % 4;
    //  AddChart(line, time, 0);
    //}

    AddChart(0, 3.55, 0.2);
    AddChart(1, 3.55, 0);
    AddChart(2, 3.96, 0);
    AddChart(3, 3.96, 0.24);

    // 4
    AddChart(3, 4.4, 0.2);
    AddChart(2, 4.6, 0.2);
    AddChart(1, 4.8, 0.2);

    // 5
    AddChart(0, 5, 0.25);
    AddChart(2, 5.25, 0);
    AddChart(3, 5.35, 0.35);
    AddChart(2, 5.7, 0);
    AddChart(1, 5.8, 0);
    AddChart(0, 5.8, 0.2);

    // 6
    AddChart(2, 6.15, 0);
    AddChart(3, 6.15, 0);
    AddChart(0, 6.25, 0);
    AddChart(1, 6.25, 0);
    AddChart(2, 6.35, 0);
    AddChart(3, 6.35, 0);
    AddChart(0, 6.45, 0);
    AddChart(1, 6.45, 0);
    AddChart(2, 6.55, 0);
    AddChart(3, 6.55, 0);


    for (int i=0; i < 470; i++)
    {
      if (i % 2 == 0) {
        if (((i + 4) / 2) % 4 == 2) {
          AddChart(0, 7 + (beatTime * i), beatTime);
          AddChart(2, 7 + (beatTime * i), 0);
          AddChart(2, 7 + (beatTime * (i+1)), 0);
        } else if (((i + 4) / 2) % 4 == 3) {
          AddChart(1, 7 + (beatTime * i), beatTime);
          AddChart(3, 7 + (beatTime * i), 0);
          AddChart(3, 7 + (beatTime * (i+1)), 0);
        } else if (((i + 4) / 2) % 4 == 0) {
          AddChart(2, 7 + (beatTime * i), beatTime);
          AddChart(0, 7 + (beatTime * i), 0);
          AddChart(0, 7 + (beatTime * (i+1)), 0);
        } else {
          AddChart(3, 7 + (beatTime * i), beatTime);
          AddChart(1, 7 + (beatTime * i), 0);
          AddChart(1, 7 + (beatTime * (i+1)), 0);
        }
      }
    }
  }

  fullCombo = 0;
  for (int i=0; i < chartSize; i++) {
    if (charts[i][2] > 0) fullCombo += 2;
    else fullCombo += 1;

    // Hit Guide
    boolean guideSoundExist = false;
    for (int j = 0; j < guideTimeSize; j++) {
      if (charts[i][1] == guideTimes[j][0])
      {
        guideSoundExist = true;
      }
    }
    if (!guideSoundExist)
    {
      guideTimes[guideTimeSize][0] = charts[i][1];
      guideTimes[guideTimeSize][1] = 0;
      guideTimeSize++;
    }

    // Release Guide
    //if (charts[i][2] > 0) {
    //  guideSoundExist = false;
    //  for (int j = 0; j < guideTimeSize; j++) {
    //    if (charts[i][1] + charts[i][2] == guideTimes[j][0])
    //    {
    //      guideSoundExist = true;
    //    }
    //  }
    //  if (!guideSoundExist)
    //  {
    //    guideTimes[guideTimeSize][0] = charts[i][1] + charts[i][2];
    //    guideTimes[guideTimeSize][1] = 0;
    //    guideTimeSize++;
    //  }
    //}
  }
}

void ResetChart() {
  charts = new float[9999][5];
  chartSize = 0;
}

float soundOffset = 0.165;
void AddChart(int lineIndex, float judgmentTime, float holdDuration) {
  charts[chartSize][0] = (float)lineIndex;
  charts[chartSize][1] = judgmentTime + soundOffset;
  charts[chartSize][2] = holdDuration;
  charts[chartSize][3] = 0; // -1 miss, 0 Not hit, 1 hit, 2 holding, 3 unsuccessful hold
  charts[chartSize][4] = 0; // Hold Time (if already hit)
  chartSize++;
}

String IntToString(int value, int targetLength)
{
  String result = Integer.toString(value);
  while (result.length() < targetLength)
  {
    result = "0" + result;
  }
  return result;
}

String FloatToString(float value, int decimalLength) {
  String result = "";
  String floatedString = Float.toString(value);
  boolean foundDecimal = false;

  for (int i=0; i < floatedString.length(); i++)
  {
    if (decimalLength <= 0) break;
    if (floatedString.charAt(i) == '.' && !foundDecimal)
    {
      foundDecimal = true;
      if (decimalLength == 0) break;
      else
      {
        result += floatedString.charAt(i);
        continue;
      }
    }
    result += floatedString.charAt(i);
    if (foundDecimal) decimalLength--;
  }
  return result;
}

void MouseCoordinate()
{
  fill(0);
  rectMode(CORNER);
  rect(mouseX + 8, mouseY + 6, 100, 24);
  textSize(16);
  textAlign(LEFT, TOP);
  fill(255);
  text("x : " + mouseX + ", y : " + mouseY, mouseX + 10, mouseY + 10);
}

void AddCombo()
{
  currentCombo++;
  if (currentCombo > maxCombo) maxCombo = currentCombo;
}

void SetJudgmentInfo(String judgmentInfo) {
  lastJudgmentInfo = judgmentInfo;
  lastJudgmentInfoTime = songDuration;
}

void ShowJudgmentInfo() {
  pushMatrix();
  translate(width/2, height/2);
  textSize(72);
  textAlign(CENTER);

  float lastJudgmentInfoDur = 1;
  if (songDuration < lastJudgmentInfoTime + lastJudgmentInfoDur) {
    if (lastJudgmentInfo.compareToIgnoreCase("perfect") == 0) {
      fill(255, 255, 0);
    } else if (lastJudgmentInfo.compareToIgnoreCase("great") == 0) {
      fill(#F240BD);
    } else if (lastJudgmentInfo.compareToIgnoreCase("good") == 0) {
      fill(#79DE91);
    } else {
      fill(#F71D05);
    }

    text(lastJudgmentInfo, 0, -150);

    if (currentCombo > 0) {
      fill(255);
      textSize(60);
      text(currentCombo, 0, -80);
    }
  }

  popMatrix();
}

void ChartGuide() {
  for (int i = 0; i < guideTimeSize; i++) {
    if (guideTimes[i][1] > 0 || songDuration < guideTimes[i][0] - 0.23) continue;
    println(guideTimes[i][0]);
    if (!guideSound.isPlaying()) {
      guideSound.play();
    }
    guideSound.loop();
    guideTimes[i][1] = 1;
  }
}
