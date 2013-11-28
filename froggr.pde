import ddf.minim.*;

/**
 * Width of the game in pixels.
 */
public static final int GAME_WIDTH = 500;

/**
 * Height of the game in pixels.
 */
public static final int GAME_HEIGHT = 700;

/**
 * Background color of the screen
 */
public final color GAME_BACKGROUND_COLOR = color(0, 0, 0);

// lane height in pixels
public static final int LANE_HEIGHT = 50;

// how many pixels is one space of movement
public static final int MOVE_AMOUNT = 50;

// number of lives the player starts with
public static final int STARTING_LIVES = 3;

/**
 * The nextPointsPosition keeps track of the next YPos the user must reach
 * to gain NEW_LANE_POINTS.
 */
private int nextPointsPosition = 600;

/**
 * Points that are earned when a fly is consumed.
 */
private final int CONSUME_FLY_BONUS = 100;

/**
 * Points that are earned when entering a lane for the first time.
 */
private final int NEW_LANE_POINTS = 25;

public static final String HOP = "sounds/player-movement.wav";
public static final String COLLISION = "sounds/sprite-collision.wav";
public static final String SPLASH = "sounds/splash.wav";
public static final String VICTORY = "sounds/victory.wav";

int flysConsumed = 0;

int score = 0;

boolean gameWon;
boolean gameOver;

// number of each type of lane
int numWaterLanes;
int numSafeLanes;
int numRoadLanes;

// the player
Player player;

// Win lane
Lane winLane;

// water lanes
ArrayList<Lane> waterLanes = new ArrayList<Lane>();

// safe lanes
ArrayList<Lane> safeLanes = new ArrayList<Lane>();

// road lanes
ArrayList<Lane> roadLanes = new ArrayList<Lane>();

// platforms
ArrayList<Platform> platforms = new ArrayList<Platform>();

// vehicles
ArrayList<Vehicle> vehicles = new ArrayList<Vehicle>();

// starting lane
Lane startLane;

private ArrayList<Fly> flys = new ArrayList<Fly>();

// the x position of where the player starts
int playerStartX;

// boundaries so the player doesn't go off screen
int leftBound;
int rightBound;
int bottomBound;

// keep track of time...
long time;
  
void setup() {
  time = millis();
  size(GAME_WIDTH,GAME_HEIGHT);
  
  gameWon = false;
  gameOver = false;
  numWaterLanes = 5;
  numSafeLanes = 2;
  numRoadLanes = 4;
  setupLanes(numWaterLanes, numSafeLanes, numRoadLanes);
  addMovingSprites();  
  createFlys();

  // set boundaries
  leftBound = 0;
  rightBound = width;
  bottomBound = height - LANE_HEIGHT;

  playerStartX = 250;  
  player = new Player(playerStartX, GAME_HEIGHT - (2 * LANE_HEIGHT), STARTING_LIVES);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
  drawLanes();
  for (Platform p : platforms) {
    p.display();
  }
  drawFlys();
  processPlayer();
  drawPlayerLives();
  processGameplay();
}

void keyPressed() {
  if (keyCode == UP) {
    if (player.getY() - MOVE_AMOUNT >= 0) {
      player.moveForward(MOVE_AMOUNT);
    }
  } 
  else if (keyCode == DOWN) {
    if (player.getY() + MOVE_AMOUNT < bottomBound) {
      player.moveBack(MOVE_AMOUNT);
    }
  } 
  else if (keyCode == LEFT) {
    if (player.getX() - MOVE_AMOUNT >= leftBound) {
      player.moveLeft(MOVE_AMOUNT);
    }
  } 
  else if (keyCode == RIGHT) {
    if (player.getX() + MOVE_AMOUNT < rightBound) {
      player.moveRight(MOVE_AMOUNT);
    }
  }
}

void addMovingSprites() {
  for (Lane l : waterLanes) {
    platforms.add(new Platform(0, l.getY(), MovingSprite.DIRECTION_RIGHT, Platform.LOG, 3));
  }
}

void setupLanes(int _numWaterLanes, int _numSafeLanes, int _numRoadLanes) {

  // start at the top
  int y = 0;

  // win lane
  winLane = new Lane(0, 0, Lane.LANE_WIN);
  y = y + LANE_HEIGHT;

  // water lanes
  for (int i = 0; i < _numWaterLanes; i++) {
    waterLanes.add(new Lane(0, y, Lane.LANE_WATER));
    y = y + LANE_HEIGHT;
  }

  // safe lanes
  for (int i = 0; i < _numSafeLanes; i++) {
    safeLanes.add(new Lane(0, y, Lane.LANE_GRASS));
    y = y + LANE_HEIGHT;
  }

  // top road
  roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_TOP));
  y = y + LANE_HEIGHT;

  // middle road lanes
  for (int i = 0; i < _numRoadLanes-2; i++) {
    roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_MIDDLE));
    y = y + LANE_HEIGHT;
  }

  // bottom road
  roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_BOTTOM));
  y = y + LANE_HEIGHT;

  // start lane
  startLane = new Lane(0, y, Lane.LANE_GRASS);
}

void drawLanes() {

  // draw the lanes starting from the top
  winLane.display();

  for (Lane l : waterLanes) {
    l.display();
  }

  for (Lane l : safeLanes) {
    l.display();
  }

  for (Lane l : roadLanes) {
    l.display();
  }

  startLane.display();
}

void createFlys() {
  for (int i = 0; i < 4; i++) {
    flys.add(new Fly(i * 150, 0));
  }
}

void drawFlys() {
  for ( Fly fly : flys ) {
    fly.display();
  }
}

private void drawPlayerLives() {
  for (int i = 0; i < player.getLives(); i++) {
    image(loadImage("sprites/player/player-idle.gif"), 50 * i, GAME_HEIGHT - 50);
  }
}

public void playSoundEffect(final String soundEffect) {
  Minim minim = new Minim(this);
  AudioSnippet audioSnippet = minim.loadSnippet(soundEffect);
  if (audioSnippet.isPlaying()) {
    audioSnippet.play(0);
  } 
  else {
    audioSnippet.play();
  }
}

private void spawnPlayer(int _lives) {
  this.player = new Player(playerStartX, GAME_HEIGHT - (2 * LANE_HEIGHT), _lives);
}

private void processGameplay() {
  if (!player.isAlive() && player.getLives() > 0) {
    spawnPlayer(player.getLives());
  }

  // Checks if the game is over
  if (player.getLives() == 0) {
    text("GAME OVER", 225, GAME_HEIGHT - 25);
    gameOver = true;
  }

  // Checks if the player wins the game.
  if (flysConsumed == 4) {
    text("YOU WIN!", 225, GAME_HEIGHT - 25);
    gameWon = true;
  }

  // Keeps track of the score
  text("SCORE: " + score, 400, GAME_HEIGHT - 25);
}

private void processPlayer() {
  player.display();

  /*
   * Keeps track of the next position the player must reach to gain
   * points. If player dies he must reach the last nextPointsPosition to
   * gain NEW_LANE_POINTS
   */
  if (player.getY() < nextPointsPosition) {
    score = score + NEW_LANE_POINTS;
    nextPointsPosition = nextPointsPosition - LANE_HEIGHT;
  }
  
  //I Will complete this once Raj gets the platforms moving
}

