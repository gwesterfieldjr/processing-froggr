class Lane extends Sprite {
  
  private String laneType;
  
  public static final String LANE_WATER = "water.gif";
  public static final String LANE_GRASS = "grass.png";
  public static final String LANE_WIN = "win.png";
  public static final String LANE_ROAD_TOP = "road-top.png";
  public static final String LANE_ROAD_MIDDLE = "road-middle.png";
  public static final String LANE_ROAD_BOTTOM = "road-bottom.png";
  
  public Lane(int _x, int _y, String _laneType) {
    super(loadImage("sprites/lane/" + _laneType), _x, _y);
    this.laneType = _laneType;
    if (laneType.equals(LANE_WATER)) {
      this.setAnimated(true);
      this.setAnimatedImage("sprites/lane/" + LANE_WATER);
    }
  }
  
}
