class MenuScreen {

  void MainMenu() {
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
      SongSelectionMenu();
    } else if (mainMenuState.compareToIgnoreCase("settings") == 0) {
      settingsScreen.display();
    }
  }
}

void mouseClicked()
{
  if (mouseButton != LEFT) return;

  if (menuState.equalsIgnoreCase("result")) {
    resultScreen.handleClick();
    return;
  }

  if (!menuState.equalsIgnoreCase("mainmenu")) {
    return;
  }

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
        mainMenuState = "settings";
      }
    } else if (mainMenuState.compareToIgnoreCase("selectsong") == 0) {
      // Back
      if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) {
        mainMenuState = "root";
      }

      if (mouseX >= 286 && mouseX <= 514 && mouseY >= 434 && mouseY <= 474) {
        LoadLevel(GetSong(songList[highlightSongSelection].id));
      }
      
      if (mouseX >= 240 && mouseX <= 260 && mouseY >= 514 && mouseY <= 546) {
        if (highlightSongSelection <= 0) return;
        highlightSongSelection--;
      }
      if (mouseX >= 540 && mouseX <= 560 && mouseY >= 514 && mouseY <= 546) {
        if (highlightSongSelection >= songList.length - 1) return;
        highlightSongSelection++;
      }
      
      
    } else if (mainMenuState.compareToIgnoreCase("settings") == 0) {
      settingsScreen.handleClick();
    }
  }
}
