// ============================================================
// Highway3D - tampilan gameplay dengan perspektif 3D
//
// Renderer tetap 2D (size(800, 600)), perspektif dihitung sendiri:
//   - z  : jarak not di depan garis judgment, dalam satuan
//          (detik * scrollSpeed * 100), sama seperti tampilan lama
//   - s  : skala perspektif = focal / (focal + z); s = 1 di garis judgment
//   - layar x = tengah + (x lane * s)
//   - layar y = horizonY + (judgeY - horizonY) * s
// Hanya menggambar. Logika judgment ada di GameInput dan LevelManager.
// ============================================================

Highway highway = new Highway();
GameHUD gameHUD = new GameHUD();

class Highway {

  // ---- Kamera ----
  float focal = 600;        // makin kecil, lintasan makin miring / menyempit
  float horizonY = -165;    // y layar titik hilang (di atas layar)
  float judgeY = 500;       // y layar garis judgment
  float zFar = 1100;        // jarak terjauh yang digambar (makin besar, note terlihat lebih awal)

  // ---- Bentuk ----
  float laneGap = 110;      // lebar satu lane
  float noteW = 88;         // diameter not
  float discSquash = 0.42;   // gepeng not di garis judgment (tinggi / lebar)
  float discThick = 9;      // tebal not

  // ---------- Proyeksi ----------

  float scaleAt(float z) { return focal / (focal + z); }
  float yAt(float s) { return horizonY + (judgeY - horizonY) * s; }
  float xAt(float lx, float s) { return width / 2.0 + lx * s; }
  float laneX(int lane) { return (lane - (gameInput.length - 1) / 2.0) * laneGap; }
  float halfTrack() { return gameInput.length * laneGap / 2.0; }
  float pxPerSec() { return scrollSpeed * 100; }
  float zOf(float t) { return (t - songDuration) * pxPerSec(); }
  float squash(float s) { return discSquash * s; }

  // z yang tepat berada di tepi bawah layar
  float zNear() {
    float sN = (height - horizonY) / (judgeY - horizonY);
    return focal / sN - focal;
  }

  // 1 = terlihat penuh, 0 = hilang (memudar di 30% terjauh)
  float fog(float z) { return constrain((zFar - z) / (zFar * 0.3), 0, 1); }

  color laneColor(int lane) {
    if (lane == 0 || lane == gameInput.length - 1) return color(110, 185, 250);
    return color(250, 215, 100);
  }

  // Persegi panjang di lantai: x0..x1 (satuan lane), z za..zb
  void strip(float x0, float x1, float za, float zb) {
    float sa = scaleAt(za);
    float sb = scaleAt(zb);
    quad(xAt(x0, sa), yAt(sa), xAt(x1, sa), yAt(sa),
         xAt(x1, sb), yAt(sb), xAt(x0, sb), yAt(sb));
  }

  // ---------- Latar ----------

  // Redupkan video / cover sesuai pengaturan Background Dim
  void drawBackdrop() {
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(0, 255 * (bgDim / 100.0));
    rect(0, 0, width, height);
    popStyle();
  }

  // ---------- Lintasan ----------

  void drawTrack() {
    pushStyle();
    noStroke();
    float zN = zNear();
    float hw = halfTrack();
    int laneCount = gameInput.length;

    // Permukaan: lapisan bertumpuk, makin gelap ke arah pemain
    int layers = 12;
    fill(6, 8, 22, 22);
    for (int k = 0; k < layers; k++) {
      strip(-hw, hw, lerp(zFar, zN, k / (float) layers), zN);
    }

    // Lane selang-seling
    fill(255, 255, 255, 10);
    for (int i = 0; i < laneCount; i += 2) {
      strip(laneX(i) - laneGap / 2, laneX(i) + laneGap / 2, zFar, zN);
    }

    // Cahaya lane yang sedang ditekan
    for (int i = 0; i < laneCount; i++) {
      if (!gameInput[i]) continue;
      int steps = 8;
      fill(laneColor(i), 18);
      for (int k = 0; k < steps; k++) {
        float zEnd = zFar * 0.55 * (1 - k / (float) steps);
        strip(laneX(i) - laneGap / 2, laneX(i) + laneGap / 2, zEnd, zN);
      }
    }

    // Pembatas lane dan pagar tepi
    fill(255, 255, 255, 60);
    for (int i = 1; i < laneCount; i++) {
      float x = -hw + i * laneGap;
      strip(x - 0.8, x + 0.8, zFar, zN);
    }
    fill(110, 185, 250, 200);
    strip(-hw - 6, -hw, zFar, zN);
    strip(hw, hw + 6, zFar, zN);

    drawBeatLines(zN, hw);

    // Cincin judgment tiap lane (hitbox)
    ellipseMode(CENTER);
    strokeWeight(2);
    for (int i = 0; i < laneCount; i++) {
      if (gameInput[i]) fill(laneColor(i), 110);
      else noFill();
      stroke(255, 210);
      float w = noteW * 1.08;
      ellipse(xAt(laneX(i), 1), judgeY, w, w * squash(1));
    }

    popStyle();
  }

  void drawBeatLines(float zN, float hw) {
    if (selectedSong == null || selectedSong.bpm <= 0) return;

    float beatTime = 60.0 / selectedSong.bpm;
    float firstTime = songOffset + chartManager.TotalOffset();   // beat ke-0, sudah termasuk offset not

    float tMin = songDuration + zN / pxPerSec();
    float tMax = songDuration + zFar / pxPerSec();
    int firstBeat = max(0, floor((tMin - firstTime) / beatTime));
    int lastBeat = ceil((tMax - firstTime) / beatTime);

    for (int b = firstBeat; b <= lastBeat; b++) {
      float z = zOf(firstTime + b * beatTime);
      if (z < zN || z > zFar) continue;

      boolean bar = (b % 4 == 0);          // awal birama lebih tebal dan terang
      float th = bar ? 2.4 : 1.2;
      fill(255, 255, 255, (bar ? 115 : 38) * fog(z));
      strip(-hw, hw, z + th, z - th);
    }
  }

  // ---------- Not ----------

  // Digambar dari yang terjauh ke terdekat
  void drawNotes() {
    pushStyle();
    noStroke();
    ellipseMode(CENTER);
    float zN = zNear();

    for (int i = chartSize - 1; i >= 0; i--) {
      RhythmNote n = charts[i];
      if (n.state == 1) continue;

      boolean active = (n.state == 0 || n.state == 2);
      boolean isHold = n.holdDuration > 0;

      float zHead = zOf(n.hitTime);
      float zTail = zOf(n.hitTime + n.holdDuration);
      if (n.state == 2) zHead = 0;                                 // sedang ditahan
      else if (n.state == 3) zHead = zOf(n.hitTime + n.heldTime);  // dilepas lebih awal

      if (isHold) {
        if (zTail < zN || zHead > zFar) continue;
        holdBody(laneX(n.lane), constrain(zHead, zN, zFar), constrain(zTail, zN, zFar), n.lane, active);
        if (zTail <= zFar) disc(n.lane, zTail, active);
        if (zHead >= zN - 10 && zHead <= zFar) disc(n.lane, zHead, active);
      } else {
        if (zHead > zFar || zHead < zN - 10) continue;
        disc(n.lane, zHead, active);
      }
    }
    popStyle();
  }

  void holdBody(float lx, float za, float zb, int lane, boolean active) {
    color c = active ? laneColor(lane) : color(120, 125, 140);
    float a = active ? 150 : 110;
    float half = noteW * 0.42;
    float zFogStart = zFar * 0.7;

    float zSolidEnd = min(zb, zFogStart);
    if (za < zSolidEnd) {
      fill(c, a);
      strip(lx - half, lx + half, za, zSolidEnd);
    }

    if (zb > zFogStart) {
      float zs = max(za, zFogStart);
      int steps = 4;
      for (int k = 0; k < steps; k++) {
        float z0 = lerp(zs, zb, k / (float) steps);
        float z1 = lerp(zs, zb, (k + 1) / (float) steps);
        fill(c, a * fog((z0 + z1) / 2));
        strip(lx - half, lx + half, z0, z1);
      }
    }
  }

  void disc(int lane, float z, boolean active) {
    float s = scaleAt(z);
    float x = xAt(laneX(lane), s);
    float y = yAt(s);
    float w = noteW * s;
    float h = w * squash(s);
    float a = 255 * fog(z);
    float thick = discThick * s;

    color c = active ? laneColor(lane) : color(125, 130, 145);

    // sisi
    fill(red(c) * 0.45, green(c) * 0.45, blue(c) * 0.45, a);
    ellipse(x, y + thick, w, h);

    // permukaan atas
    stroke(255, a * 0.9);
    strokeWeight(max(1, 2 * s));
    fill(c, a);
    ellipse(x, y, w, h);
    noStroke();

    // kilap
    fill(255, a * 0.45);
    ellipse(x, y, w * 0.5, h * 0.5);
  }

  // ---------- Tombol ----------

  // Label tombol di bawah cincin judgment (tanpa kotak pad)
  void drawKeyPads() {
    pushStyle();
    noStroke();
    float s = scaleAt(-40);
    textAlign(CENTER, CENTER);
    textSize(30 * s);

    for (int i = 0; i < gameInput.length; i++) {
      fill(255, gameInput[i] ? 255 : 150);
      text(KeyLabel(laneKeys[i]), xAt(laneX(i), s), yAt(s));
    }
    popStyle();
  }
}

// ============================================================
// HUD: skor, combo, judgment, dan life bar
// ============================================================

class GameHUD {

  int lastCombo = 0;
  int comboPopMillis = -1000;

  void display() {
    pushStyle();
    drawScore();
    drawLife();
    drawCombo();
    drawJudgment();
    popStyle();
  }

  // Skor dengan skala yang sama dengan layar hasil (maks 1.000.000)
  void drawScore() {
    float points = (currentJudgment[0] * perfectScore) +
                   (currentJudgment[1] * greatScore) +
                   (currentJudgment[2] * goodScore);
    float accuracy = (fullCombo > 0) ? constrain(points / fullCombo, 0, 1) : 0;
    int score = round(accuracy * 1000000);

    textAlign(RIGHT, TOP);
    fill(150, 170, 200);
    textSize(12);
    text("SCORE", width - 24, 14);
    fill(255);
    textSize(30);
    text(nfc(score), width - 24, 28);
  }

  // Sisa nyawa = batas Miss berturut-turut - Miss berturut-turut saat ini
  void drawLife() {
    int total = gameOverMissLimit;
    int left = max(0, total - gameOverSystem.missStreak);

    float barW = 260, barH = 12;
    float gap = 3;
    float x0 = (width - barW) / 2.0;
    float y0 = 20;
    float segW = (barW - gap * (total - 1)) / total;

    color lit;
    float ratio = left / (float) total;
    if (ratio > 0.6) lit = color(110, 220, 170);
    else if (ratio > 0.3) lit = color(255, 210, 90);
    else lit = color(247, 29, 5);

    float pulse = 1;
    if (left <= 2) pulse = 0.65 + 0.35 * sin(millis() * 0.02);

    noStroke();
    rectMode(CORNER);
    for (int i = 0; i < total; i++) {
      if (i < left) fill(lit, 255 * pulse);
      else fill(255, 255, 255, 28);
      rect(x0 + i * (segW + gap), y0, segW, barH, 2);
    }

    textAlign(CENTER, BOTTOM);
    fill(150, 170, 200);
    textSize(11);
    text("LIFE", width / 2.0, y0 - 3);
  }

  void drawCombo() {
    if (currentCombo != lastCombo) {
      if (currentCombo > lastCombo) comboPopMillis = millis();
      lastCombo = currentCombo;
    }
    if (currentCombo <= 0) return;

    float pop = 1 + 0.16 * max(0, 1 - (millis() - comboPopMillis) / 160.0);

    pushMatrix();
    translate(112, 330);
    scale(pop);

    ellipseMode(CENTER);
    noStroke();
    fill(10, 15, 35, 190);
    ellipse(0, 0, 128, 128);

    noFill();
    stroke(110, 185, 250, 220);
    strokeWeight(4);
    ellipse(0, 0, 128, 128);
    stroke(110, 185, 250, 90);
    strokeWeight(1.5);
    ellipse(0, 0, 142, 142);

    noStroke();
    textAlign(CENTER, CENTER);
    fill(150, 200, 240);
    textSize(14);
    text("COMBO", 0, -24);
    fill(255);
    textSize(currentCombo >= 1000 ? 30 : 38);
    text("x" + currentCombo, 0, 6);
    popMatrix();
  }

  void drawJudgment() {
    float dur = 0.8;
    float age = songDuration - lastJudgmentInfoTime;
    if (lastJudgmentInfo.length() == 0 || age < 0 || age > dur) return;

    color c;
    if (lastJudgmentInfo.compareToIgnoreCase("perfect") == 0) c = color(255, 255, 0);
    else if (lastJudgmentInfo.compareToIgnoreCase("great") == 0) c = color(242, 64, 189);
    else if (lastJudgmentInfo.compareToIgnoreCase("good") == 0) c = color(121, 222, 145);
    else c = color(247, 29, 5);

    float t = age / dur;
    float a = 255 * (1 - constrain((t - 0.6) / 0.4, 0, 1));
    float pop = 1 + 0.25 * max(0, 1 - age / 0.12);

    pushMatrix();
    translate(width / 2.0, 285);
    scale(pop);
    textAlign(CENTER, CENTER);
    textSize(46);
    fill(0, a * 0.6);
    text(lastJudgmentInfo.toUpperCase(), 2, 3);
    fill(c, a);
    text(lastJudgmentInfo.toUpperCase(), 0, 0);
    popMatrix();
  }
}
