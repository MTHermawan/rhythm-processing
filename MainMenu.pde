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
