// ============================================================
// Pause Menu
// ESC saat bermain -> layar pause dengan 3 pilihan:
//   CONTINUE : hitung mundur 3 detik, lalu game lanjut dari posisi yang sama
//   RESTART  : ulang lagu dari awal
//   QUIT     : kembali ke Main Menu
//
// menuState yang dipakai:
//   "pause"      layar pilihan
//   "pausecount" hitung mundur sebelum game lanjut
// ============================================================

PauseSystem pauseSystem = new PauseSystem();

class PauseSystem {

  float countdownSeconds = 3;

  // Data saat pause
  PImage snapshot = null;           // tangkapan layar gameplay
  float pauseTime = 0;              // nilai `time` saat pause
  float pausedSongDuration = 0;     // songDuration saat pause
  boolean musicWasPlaying = false;
  float countdownStart = 0;
  float resumeGraceUntil = -1;      // jeda singkat agar cek "lagu selesai" tidak salah baca

  // Status tombol lane
  boolean[] heldAtPause = new boolean[4];   // ditekan saat pause dimulai
  boolean[] physHeld = new boolean[4];      // keadaan tombol sebenarnya selama pause
  boolean escHeld = false;                  // cegah auto-repeat ESC

  // Tombol
  float btnW = 260, btnH = 54, btnX = 270;
  float[] btnY = {250, 320, 390};
  String[] btnLabel = {"CONTINUE", "RESTART", "QUIT"};

  // ---------- Status ----------

  boolean isPaused() {
    return menuState.equalsIgnoreCase("pause") || menuState.equalsIgnoreCase("pausecount");
  }

  // Dipakai LevelManager: true sesaat setelah game dilanjutkan
  boolean recentlyResumed() {
    return time < resumeGraceUntil;
  }

  // ---------- Pause / Resume ----------

  void pause() {
    println("Game Paused");
    snapshot = get();
    pauseTime = time;
    pausedSongDuration = songDuration;

    musicWasPlaying = songStarted && selectedSong.sound != null && selectedSong.sound.isPlaying();
    // Pakai stop() (bukan pause()). Posisi pause dipulihkan lewat cue() saat Continue;
    // awal lagu selalu di-cue(0) di LevelManager.
    if (musicWasPlaying) selectedSong.sound.stop();
    if (guideSound != null && guideSound.isPlaying()) guideSound.stop();
    if (backgroundMV != null && backgroundMV.isPlaying()) backgroundMV.pause();

    for (int i = 0; i < gameInput.length; i++) {
      heldAtPause[i] = gameInput[i];
      physHeld[i] = gameInput[i];
    }

    menuState = "pause";
  }

  void startCountdown() {
    countdownStart = time;
    menuState = "pausecount";
  }

  void resume() {
    println("Game Resumed");
    float pausedFor = time - pauseTime;

    // Geser waktu agar songDuration lanjut dari titik pause
    levelStartTime += pausedFor;
    if (songEndTime >= 0) songEndTime += pausedFor;
    if (songStarted) songDuration = pausedSongDuration;
    gameOverSystem.lastSeenLevelStart = levelStartTime;   // jangan reset hitungan Miss

    resumeGraceUntil = time + 0.5;
    menuState = "level";

    if (musicWasPlaying && songEndTime < 0 && selectedSong.sound != null) {
      selectedSong.sound.cue(max(0, pausedSongDuration));   // lanjut dari posisi pause
      selectedSong.sound.play();
      selectedSong.sound.amp(musicVolume / 100);
    }
    // Video dilanjutkan otomatis oleh PlayMV() di frame berikutnya

    // Pulihkan tombol. Tombol yang sudah dilepas selama pause diproses
    // sebagai pelepasan agar hold tidak menggantung.
    for (int i = 0; i < gameInput.length; i++) {
      gameInput[i] = false;
      if (!heldAtPause[i]) continue;

      if (physHeld[i]) {
        gameInput[i] = true;
      } else {
        gameInput[i] = true;
        key = laneKeys[i];
        keyReleased();
      }
    }

    snapshot = null;
  }

  // Lagu yang di-pause tidak lagi "isPlaying", sehingga stop() di ResetGameplay()
  // dan ReturnToMainMenu() dilewati dan posisinya tertinggal. Paksa stop() di sini
  // agar lagu berikutnya mulai dari awal.
  void stopMusic() {
    if (selectedSong != null && selectedSong.sound != null) {
      selectedSong.sound.stop();
      selectedSong.sound.cue(0);
    }
    if (guideSound != null) guideSound.stop();
    musicWasPlaying = false;
  }

  void restart() {
    println("Pause -> Restart");
    snapshot = null;
    stopMusic();
    LoadLevel(selectedSong);
  }

  void quit() {
    println("Pause -> Main Menu");
    snapshot = null;
    stopMusic();
    if (backgroundMV != null) backgroundMV.stop();
    ReturnToMainMenu();
  }

  // ---------- Input ----------

  // Panggil dari keyPressed(). true = tombol sudah ditangani.
  boolean handleKey() {
    boolean inLevel = menuState.equalsIgnoreCase("level");
    boolean inPause = isPaused();

    if (key == ESC) {
      if (!inLevel && !inPause) return false;
      key = 0;                       // cegah ESC menutup sketch
      if (escHeld) return true;
      escHeld = true;

      if (inLevel) pause();
      else if (menuState.equalsIgnoreCase("pause")) startCountdown();
      return true;
    }

    if (inPause) {
      int lane = LaneFromKey(key);
      if (lane >= 0) physHeld[lane] = true;
      return true;                   // tombol lain diabaikan saat pause
    }
    return false;
  }

  // Panggil dari keyReleased(). true = tombol sudah ditangani.
  boolean handleKeyRelease() {
    if (key == ESC) {
      escHeld = false;
      return false;
    }
    if (isPaused()) {
      int lane = LaneFromKey(key);
      if (lane >= 0) physHeld[lane] = false;
      return true;
    }
    return false;
  }

  void handleClick() {
    if (!menuState.equalsIgnoreCase("pause")) return;

    for (int i = 0; i < 3; i++) {
      if (!isOver(btnX, btnY[i], btnW, btnH)) continue;
      if (i == 0) startCountdown();
      else if (i == 1) restart();
      else quit();
      return;
    }
  }

  // ---------- Screen ----------

  void display() {
    pushStyle();
    background(0);
    imageMode(CORNER);
    if (snapshot != null) image(snapshot, 0, 0, width, height);

    rectMode(CORNER);
    noStroke();

    if (menuState.equalsIgnoreCase("pause")) {
      fill(8, 10, 20, 205);
      rect(0, 0, width, height);
      drawMenu();
    } else {
      fill(8, 10, 20, 150);
      rect(0, 0, width, height);
      drawCountdown();
    }
    popStyle();
  }

  void drawMenu() {
    textAlign(CENTER, CENTER);
    fill(110, 190, 245);
    textSize(14);
    text("PROCESSYTHM", width / 2, 96);

    fill(255);
    textSize(56);
    text("PAUSED", width / 2, 140);

    if (selectedSong != null) {
      fill(160, 175, 195);
      textSize(16);
      text(selectedSong.title, width / 2, 190);
    }

    for (int i = 0; i < 3; i++) {
      drawButton(btnX, btnY[i], btnW, btnH, btnLabel[i], i == 0);
    }

    fill(110, 135, 165);
    textSize(12);
    text("ESC : CONTINUE", width / 2, 480);
  }

  void drawCountdown() {
    float elapsed = time - countdownStart;
    float remaining = countdownSeconds - elapsed;

    if (remaining <= 0) {
      resume();
      return;
    }

    int number = ceil(remaining);
    float frac = remaining - floor(remaining);       // 1 -> 0 tiap detik
    if (frac == 0) frac = 1;

    float cx = width / 2.0, cy = height / 2.0;

    fill(110, 190, 245);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("GET READY", cx, cy - 130);

    // Cincin hitung mundur untuk detik yang sedang berjalan
    noFill();
    stroke(110, 185, 250, 70);
    strokeWeight(6);
    ellipse(cx, cy, 190, 190);
    stroke(110, 185, 250);
    strokeWeight(6);
    arc(cx, cy, 190, 190, -HALF_PI, -HALF_PI + TWO_PI * frac);
    noStroke();

    float pop = 1 + 0.25 * max(0, (frac - 0.8) / 0.2);
    pushMatrix();
    translate(cx, cy - 6);
    scale(pop);
    fill(255);
    textSize(110);
    text(number, 0, 0);
    popMatrix();
  }

  boolean isOver(float x, float y, float w, float h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void drawButton(float x, float y, float w, float h, String label, boolean primary) {
    boolean hovered = isOver(x, y, w, h);

    noStroke();
    if (primary) {
      if (hovered) fill(85, 165, 225);
      else fill(55, 120, 175);
    } else {
      if (hovered) fill(60, 85, 120);
      else fill(36, 53, 78);
    }
    rectMode(CORNER);
    rect(x, y, w, h, 12);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(19);
    text(label, x + w / 2, y + h / 2);
  }
}
