// ============================================================
// Settings.pde  (tab baru)
// musicVolume sudah ada di main.pde, sisanya didefinisikan di sini
// ============================================================

float sfxVolume = 60;          // 0 - 100
float musicOffsetMs = 0;       // -300 .. 300 ms (+ = note lebih lambat)
float scrollSpeed = 10;        // 1 - 20 (10 = kecepatan lama)
float bgDim = 65;              // 0 - 100 (%)
char[] laneKeys = {'d', 'f', 'j', 'k'};
int rebindingLane = -1;        // -1 = tidak sedang rebind

SettingsScreen settingsScreen = new SettingsScreen();


// ---------------- Helper umum ----------------

String KeyLabel(char k) {
  if (k == ' ') return "SPACE";
  return str(k).toUpperCase();
}

int LaneFromKey(char k) {
  char lk = Character.toLowerCase(k);
  for (int i = 0; i < laneKeys.length; i++) {
    if (laneKeys[i] == lk) return i;
  }
  return -1;
}

boolean IsInSettings() {
  return menuState.equalsIgnoreCase("mainmenu") && mainMenuState.equalsIgnoreCase("settings");
}

// Dipanggil paling awal di keyPressed(). true = key sudah dipakai untuk rebind.
boolean HandleRebindKey() {
  if (rebindingLane < 0) return false;

  if (key == ESC) {
    key = 0;                 // cegah ESC menutup sketch
    rebindingLane = -1;
    return true;
  }
  if (key == CODED) return true;            // abaikan panah, shift, dll

  char k = Character.toLowerCase(key);
  if (k < 32 || k == 127) return true;      // abaikan Enter, Tab, Backspace

  // Kalau key sudah dipakai lane lain, tukar posisinya
  for (int i = 0; i < laneKeys.length; i++) {
    if (i != rebindingLane && laneKeys[i] == k) {
      laneKeys[i] = laneKeys[rebindingLane];
    }
  }
  laneKeys[rebindingLane] = k;
  rebindingLane = -1;
  SaveSettings();
  return true;
}


// ---------------- Simpan / muat ----------------

void SaveSettings() {
  String[] lines = {
    "musicVolume=" + musicVolume,
    "sfxVolume=" + sfxVolume,
    "musicOffsetMs=" + musicOffsetMs,
    "scrollSpeed=" + scrollSpeed,
    "bgDim=" + bgDim,
    "keys=" + new String(laneKeys)
  };
  saveStrings(sketchPath("settings.txt"), lines);
}

void LoadSettings() {
  File f = new File(sketchPath("settings.txt"));
  if (!f.exists()) return;

  String[] lines = loadStrings(f.getAbsolutePath());
  if (lines == null) return;

  for (String line : lines) {
    int eq = line.indexOf('=');
    if (eq < 0) continue;
    String name = line.substring(0, eq);
    String val = line.substring(eq + 1);

    if (name.equals("musicVolume")) musicVolume = constrain(parseFloat(val), 0, 100);
    else if (name.equals("sfxVolume")) sfxVolume = constrain(parseFloat(val), 0, 100);
    else if (name.equals("musicOffsetMs")) musicOffsetMs = constrain(parseFloat(val), -300, 300);
    else if (name.equals("scrollSpeed")) scrollSpeed = constrain(parseFloat(val), 1, 20);
    else if (name.equals("bgDim")) bgDim = constrain(parseFloat(val), 0, 100);
    else if (name.equals("keys") && val.length() == 4) laneKeys = val.toCharArray();
  }
}


// ---------------- Event mouse (khusus layar settings) ----------------

void mousePressed() {
  if (IsInSettings()) settingsScreen.handlePress();
}

void mouseDragged() {
  if (IsInSettings()) settingsScreen.handleDrag();
}

void mouseReleased() {
  if (IsInSettings()) settingsScreen.handleRelease();
}


// ---------------- Layar Settings ----------------

class SettingsScreen {

  float trackX = 330;
  float trackW = 290;
  float rebindY = 405;
  int dragging = -1;

  // Urutan: 0 Music Volume, 1 SFX Volume, 2 Music Offset, 3 Scroll Speed, 4 Background Dim
  String[] labels = {"Music Volume", "SFX Volume", "Music Offset", "Scroll Speed", "Background Dim"};
  String[] units  = {"%", "%", " ms", "", "%"};
  float[] minV    = {0, 0, -300, 1, 0};
  float[] maxV    = {100, 100, 300, 20, 100};
  float[] stepV   = {1, 1, 5, 0.5, 1};
  float[] rowY    = {125, 170, 215, 320, 365};

  float GetSetting(int i) {
    switch (i) {
      case 0: return musicVolume;
      case 1: return sfxVolume;
      case 2: return musicOffsetMs;
      case 3: return scrollSpeed;
      default: return bgDim;
    }
  }

  void SetSetting(int i, float v) {
    switch (i) {
      case 0: musicVolume = v; break;
      case 1: sfxVolume = v; break;
      case 2: musicOffsetMs = v; break;
      case 3: scrollSpeed = v; break;
      default: bgDim = v; break;
    }
  }

  String FormatValue(int i, float v) {
    if (i == 3) return nf(v, 1, 1);
    if (i == 2 && v > 0) return "+" + round(v) + units[i];
    return round(v) + units[i];
  }

  void SectionTitle(String title, float y) {
    fill(#6ba0cc);
    textSize(18);
    textAlign(LEFT, TOP);
    text(title, 40, y);
    fill(60);
    rectMode(CORNER);
    rect(40, y + 26, width - 80, 1);
  }

  void DrawSlider(int i) {
    float y = rowY[i] + 13;
    float v = GetSetting(i);
    float frac = (v - minV[i]) / (maxV[i] - minV[i]);

    fill(255);
    textSize(20);
    textAlign(LEFT, CENTER);
    text(labels[i], 60, y - 2);

    noStroke();
    rectMode(CORNER);
    fill(60);
    rect(trackX, y - 3, trackW, 6, 3);
    fill(#6ba0cc);
    rect(trackX, y - 3, trackW * frac, 6, 3);
    fill(255);
    ellipse(trackX + trackW * frac, y, 18, 18);

    fill(255, 255, 0);
    textSize(20);
    textAlign(LEFT, CENTER);
    text(FormatValue(i, v), trackX + trackW + 25, y - 2);
  }

  void display() {
    background(10);

    // Top bar + Back
    rectMode(CORNER);
    noStroke();
    fill(#6ba0cc);
    rect(0, 0, width, 60);

    textSize(36);
    textAlign(LEFT, TOP);
    if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) fill(255, 255, 0);
    else fill(255);
    triangle(40, 12, 40, 48, 20, 30);
    text("Back", 54, 16);

    fill(255);
    textAlign(CENTER, TOP);
    text("Settings", width / 2, 16);

    // Sound
    SectionTitle("SOUND", 80);
    for (int i = 0; i < 3; i++) DrawSlider(i);

    fill(140);
    textSize(13);
    textAlign(LEFT, TOP);
    text("Sering tap kecepetan? turunkan (-). Sering telat? naikkan (+).", trackX, rowY[2] + 30);

    // Gameplay
    SectionTitle("GAMEPLAY", 275);
    for (int i = 3; i < labels.length; i++) DrawSlider(i);

    // Rebind key
    fill(255);
    textSize(20);
    textAlign(LEFT, CENTER);
    text("Rebind Key", 60, rebindY + 18);

    for (int i = 0; i < laneKeys.length; i++) {
      float bx = trackX + (i * 75);
      boolean waiting = (rebindingLane == i);
      boolean hover = mouseX >= bx && mouseX <= bx + 65 && mouseY >= rebindY && mouseY <= rebindY + 40;

      rectMode(CORNER);
      noStroke();
      if (waiting) fill(255, 255, 0);
      else if (hover) fill(110);
      else fill(60);
      rect(bx, rebindY, 65, 40, 6);

      if (waiting) fill(0);
      else fill(255);
      textAlign(CENTER, CENTER);
      textSize(waiting ? 18 : 22);
      text(waiting ? "..." : KeyLabel(laneKeys[i]), bx + 32, rebindY + 18);
    }

    fill(140);
    textSize(13);
    textAlign(LEFT, TOP);
    text("Klik kotak lalu tekan key baru (ESC = batal)", trackX, rebindY + 50);
  }

  // ---- Input ----

  void UpdateFromMouse(int i) {
    float f = constrain((mouseX - trackX) / trackW, 0, 1);
    float v = minV[i] + round((f * (maxV[i] - minV[i])) / stepV[i]) * stepV[i];
    SetSetting(i, constrain(v, minV[i], maxV[i]));
  }

  void handlePress() {
    for (int i = 0; i < labels.length; i++) {
      if (mouseX >= trackX - 12 && mouseX <= trackX + trackW + 12 &&
          abs(mouseY - (rowY[i] + 13)) <= 14) {
        dragging = i;
        UpdateFromMouse(i);
        return;
      }
    }
  }

  void handleDrag() {
    if (dragging >= 0) UpdateFromMouse(dragging);
  }

  void handleRelease() {
    if (dragging < 0) return;

    // Preview suara saat selesai geser slider SFX
    if (dragging == 1 && guideSound != null) {
      guideSound.amp(sfxVolume / 100);
      guideSound.play();
    }
    dragging = -1;
    SaveSettings();
  }

  void handleClick() {
    // Back
    if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) {
      rebindingLane = -1;
      mainMenuState = "root";
      return;
    }

    // Kotak rebind
    for (int i = 0; i < laneKeys.length; i++) {
      float bx = trackX + (i * 75);
      if (mouseX >= bx && mouseX <= bx + 65 && mouseY >= rebindY && mouseY <= rebindY + 40) {
        rebindingLane = (rebindingLane == i) ? -1 : i;
        return;
      }
    }
  }
}
