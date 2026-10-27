import processing.sound.*;

// Song Stuff
String selectedSong = "bad_apple";
float songStartTime = 0;
float songTime = 0;
float songBpm = 0;
float songOffset = 0;   // detik sampai beat ke-0
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
RhythmNote[] charts = new RhythmNote[9999]; // {Line Index, Judgment Time, Hold Duration}
int chartSize = 0;
float[][] guideTimes = new float[9999][2];
int guideTimeSize = 0;
SoundFile guideSound;
String sfxPath = "assets/sfx/";

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
boolean songStarted = false;
boolean[] gameInput = new boolean[4] ;

ChartManager chartManager = new ChartManager();
MenuScreen menuScreen = new MenuScreen();
JudgmentManager judgmentManager = new JudgmentManager();
ResultScreen resultScreen = new ResultScreen();

void setup()
{
  size(800, 600);
  LoadSettings();
  startTime = millis();
  song = new SoundFile(this, songPath + "bad_apple" + "/bgm.mp3");
  guideSound = new SoundFile(this, sfxPath + "clap-lowerdb.mp3");
  background(0);
  resultScreen.loadAssets();

  for (int i=0; i < gameInput.length; i++) {
    gameInput[i] = false;
  }
  
  guideSound.amp(sfxVolume / 100);
  chartManager.SetupChart(selectedSong);
}

void draw()
{
  time = (millis() - startTime) / 1000;

  // MainMenu -> Level -> Score Result -> MainMenu
  if (menuState.compareToIgnoreCase("mainmenu") == 0)
  {
    menuScreen.MainMenu();
  }
  else if (menuState.compareToIgnoreCase("level") == 0)
  {
    LevelManager();
  }
  else if (menuState.compareToIgnoreCase("result") == 0)
  {
    resultScreen.display();
  }

  if (menuState.equalsIgnoreCase("level")) {
  MouseCoordinate();
  }

  totalScore = (currentJudgment[0] * perfectScore) + (currentJudgment[1] * greatScore) + (currentJudgment[2] * goodScore);
  totalCombo = currentJudgment[0] + currentJudgment[1] + currentJudgment[2];
}
