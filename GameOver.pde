// ============================================================
// Game Over System
// Game over terjadi bila player Miss 10x berturut-turut.
// Satu Hit (Perfect / Great / Good) memutus rangkaian Miss.
// Layar game over punya dua pilihan: RESTART dan MAIN MENU.
//
// Alur: Level -> (10 Miss berturut-turut) -> Game Over -> Restart / Main Menu
// ============================================================

int gameOverMissLimit = 10;   // jumlah Miss berturut-turut yang memicu game over

GameOverSystem gameOverSystem = new GameOverSystem();

class GameOverSystem {

  // Tracking
  int missStreak = 0;
  int lastMissCount = 0;
  int lastHitCount = 0;
  float lastSeenLevelStart = -1;

  // Data layar
  PImage snapshot = null;       // tangkapan layar gameplay saat game over
  int animationStartMillis = -1;
  float reachedTime = 0;        // posisi lagu saat game over
  int reachedMaxCombo = 0;

  // Tombol
  float btnW = 225, btnH = 56, btnY = 420;
  float restartX = 155, menuX = 420;

  // ---------- Tracking ----------

  int hitCount() {
    return currentJudgment[0] + currentJudgment[1] + currentJudgment[2];
  }

  void resetTracking() {
    missStreak = 0;
    lastMissCount = currentJudgment[3];
    lastHitCount = hitCount();
    lastSeenLevelStart = levelStartTime;
  }

  // Panggil setiap frame saat menuState == "level", setelah LevelManager().
  // Miss dan hit dihitung dari perubahan currentJudgment, jadi tidak perlu
  // mengubah kode judgment yang sudah ada.
  void update() {
    if (!menuState.equalsIgnoreCase("level")) return;

    // Level baru / restart / counter di-reset -> mulai tracking dari awal
    if (levelStartTime != lastSeenLevelStart ||
        currentJudgment[3] < lastMissCount ||
        hitCount() < lastHitCount) {
      resetTracking();
      return;
    }

    int newHits = hitCount() - lastHitCount;
    int newMisses = currentJudgment[3] - lastMissCount;
    lastHitCount = hitCount();
    lastMissCount = currentJudgment[3];

    // Input player (hit) diproses sebelum draw(), sedangkan Miss otomatis
    // dihitung di dalam draw(). Jadi hit di-frame yang sama dihitung lebih dulu.
    if (newHits > 0) missStreak = 0;
    missStreak += newMisses;

    if (missStreak >= gameOverMissLimit) {
      trigger();
    }
  }

  void trigger() {
    println("Game Over: " + missStreak + " consecutive misses");

    // Ambil tampilan gameplay terakhir untuk latar layar game over
    snapshot = get();

    reachedTime = max(0, songDuration);
    reachedMaxCombo = maxCombo;

    // Hentikan audio dan video
    if (selectedSong != null && selectedSong.sound != null && selectedSong.sound.isPlaying()) {
      selectedSong.sound.stop();
    }
    if (guideSound != null && guideSound.isPlaying()) {
      guideSound.stop();
    }
    if (backgroundMV != null) {
      backgroundMV.stop();
    }

    for (int i = 0; i < gameInput.length; i++) {
      gameInput[i] = false;
    }

    animationStartMillis = millis();
    menuState = "gameover";
  }

  // ---------- Screen ----------

  void display() {
    pushStyle();

    float elapsed = (millis() - animationStartMillis) / 1000.0;
    float fade = constrain(elapsed / 0.6, 0, 1);

    // Latar: frame gameplay terakhir yang digelapkan
    background(0);
    imageMode(CORNER);
    if (snapshot != null) image(snapshot, 0, 0, width, height);
    rectMode(CORNER);
    noStroke();
    fill(8, 4, 8, 215 * fade);
    rect(0, 0, width, height);

    // Garis merah tipis atas dan bawah
    fill(247, 29, 5, 160 * fade);
    rect(0, 0, width, 4);
    rect(0, height - 4, width, 4);

    // Judul
    textAlign(CENTER, CENTER);
    float titleSlide = (1 - fade) * -20;
    fill(247, 29, 5, 255 * fade);
    textSize(72);
    text("GAME OVER", width / 2, 140 + titleSlide);

    fill(200, 205, 215, 255 * fade);
    textSize(18);
    text(gameOverMissLimit + " consecutive misses", width / 2, 200 + titleSlide);

    // Panel info
    float panelW = 460, panelH = 120;
    float panelX = (width - panelW) / 2, panelY = 250;
    fill(20, 31, 49, 230 * fade);
    rect(panelX, panelY, panelW, panelH, 14);

    String songTitle = (selectedSong != null) ? selectedSong.title : "-";
    fill(255, 255 * fade);
    textSize(22);
    text(songTitle, width / 2, panelY + 28);

    drawStat(panelX + panelW * 0.25, panelY + 78, "REACHED", formatTime(reachedTime), fade);
    drawStat(panelX + panelW * 0.75, panelY + 78, "MAX COMBO", str(reachedMaxCombo), fade);

    // Tombol
    drawButton(restartX, btnY, btnW, btnH, "RESTART", true, fade);
    drawButton(menuX, btnY, btnW, btnH, "MAIN MENU", false, fade);

    popStyle();
  }

  void drawStat(float cx, float cy, String label, String value, float fade) {
    textAlign(CENTER, CENTER);
    fill(165, 180, 200, 255 * fade);
    textSize(12);
    text(label, cx, cy - 16);
    fill(255, 255 * fade);
    textSize(24);
    text(value, cx, cy + 6);
  }

  void drawButton(float x, float y, float w, float h, String label, boolean primary, float fade) {
    boolean hovered = isOver(x, y, w, h);

    noStroke();
    if (primary) {
      if (hovered) fill(85, 165, 225, 255 * fade);
      else fill(55, 120, 175, 255 * fade);
    } else {
      if (hovered) fill(60, 85, 120, 255 * fade);
      else fill(36, 53, 78, 255 * fade);
    }
    rectMode(CORNER);
    rect(x, y, w, h, 12);

    fill(255, 255 * fade);
    textAlign(CENTER, CENTER);
    textSize(19);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isOver(float x, float y, float w, float h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  String formatTime(float seconds) {
    int s = (int) seconds;
    return (s / 60) + ":" + nf(s % 60, 2);
  }

  // ---------- Input ----------

  void handleClick() {
    // Abaikan klik selama animasi fade-in agar tombol tidak terpilih tanpa sengaja
    if ((millis() - animationStartMillis) < 400) return;

    if (isOver(restartX, btnY, btnW, btnH)) {
      println("Game Over -> Restart");
      LoadLevel(selectedSong);
      return;
    }

    if (isOver(menuX, btnY, btnW, btnH)) {
      println("Game Over -> Main Menu");
      snapshot = null;
      ReturnToMainMenu();
      return;
    }
  }
}
