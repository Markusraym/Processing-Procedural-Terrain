import controlP5.*;
ControlP5 cp5;
Camera cameraPosition;

//Interactive Variables vv
int rows = 1;
int columns = 1;
float gridSize = 20;
boolean generate = false;
String fileLoad = " ";
boolean useStroke = false;
boolean useColor = false;
boolean useBlend = false;
float heightModifier = 1.0f;
float snowThreshold = 1.0f;

//Slider Interactive Variables vv
int sliderRows = 1;
int sliderColumns = 1;
float slidergridSize = 20;
//String sliderfileLoad = " ";
boolean slideruseStroke = false;
boolean slideruseColor = false;
boolean slideruseBlend = false;
float sliderheightModifier = 1.0f;
float slidersnowThreshold = 1.0f;

// Iteractive Varialbes ^^
float deltaX = 0;
float deltaY = 0;
float phi = 0.0f;
float theta = 0.0f;
ArrayList<PVector> vertexData = new ArrayList<PVector>();
ArrayList<Integer> verticeIndex = new ArrayList<Integer>();
float offsetX = gridSize/columns;
float offsetZ = gridSize/rows;
int startingIndex = 0;
int verticesInaColumn;
int iter = 0;
float x_index = 0;
float y_index = 0;
float colorVar;
float heightFromColor;
int imageWidth;
int imageHeight;
float vertex_index;
float ratio; //Used for interpolation in drawTriangles()
//PImage variables for 7 different images to take height data from
PImage terrain;
String currentString;
Textfield sliderfileLoad;
float relativeHeight;

void setup()
{
  size(1200, 800, P3D);
  background(0);
  cp5 = new ControlP5(this);
  cameraPosition = new Camera();

  //Adding all the sliders
  cp5.addSlider("sliderRows").setPosition(15, 15).setRange(1, 100).setSize(200, 20).setCaptionLabel("ROWS");
  cp5.addSlider("sliderColumns").setPosition(15, 55).setRange(1, 100).setSize(200, 20).setCaptionLabel("COLUMNS");
  cp5.addSlider("slidergridSize").setPosition(15, 95).setRange(20, 50).setSize(200, 20).setCaptionLabel("TERRAIN SIZE");
  cp5.addButton("GENERATE").setValue(1).setPosition(15, 155).setSize(90, 35);
  sliderfileLoad = cp5.addTextfield("sliderfileLoad").setPosition(15, 205).setSize(215, 25).setCaptionLabel("LOAD FROM FILE").setAutoClear(false).setValue("");
  cp5.addToggle("slideruseStroke").setPosition(350, 15).setSize(45, 25).setCaptionLabel("STROKE");
  cp5.addToggle("slideruseColor").setPosition(415, 15).setSize(45, 25).setCaptionLabel("COLOR");
  cp5.addToggle("slideruseBlend").setPosition(480, 15).setSize(45, 25).setCaptionLabel("BLEND");
  cp5.addSlider("sliderheightModifier").setPosition(350, 65).setRange(-5.0f, 5.0f).setSize(200, 20).setCaptionLabel("HEIGHT MODIFIER").setValue(1.0f);
  cp5.addSlider("slidersnowThreshold").setPosition(350, 105).setRange(1.0f, 5.0f).setSize(200, 20).setCaptionLabel("SNOW THRESHOLD");
  GENERATE();
  mouseDragged2();
}

void draw()
{
  perspective(radians(90.0f), width/(float)height, 0.1, 1000.0);
  cameraPosition.Update(phi, theta);
  background(0);

  //If generate button has been pressed, draw the triangles
  if (generate == true)
  {
    DrawTriangles();
  }
  camera();
  perspective();
}

void mouseWheel(MouseEvent event) //Detect if the mousewheel has been moved, and calls Zoom() in the Camera class to adjust the radius variable
{
  float e = event.getCount();
  cameraPosition.Zoom(e);
}

void mouseDragged()
{
  if (cp5.isMouseOver())
    return;

  deltaX = (mouseX - pmouseX) * 0.20f;
  deltaY = (mouseY - pmouseY) * 0.20f;
  //Create phi and theta
  phi = phi + deltaX;
  theta = theta + deltaY;
  //Clamp theta between 1 and 179
  if (theta > 179)
  {
    theta = 179;
  } else if (theta < 1)
  {
    theta = 1;
  }
}

void MakeVerticeArray()
{
  vertexData.clear(); //Clear the array so when every time this is called, it gets a fresh start when the values of rows and columns and gridSize changes.
  //Creates row of points starting at (-gridSize/2, 0, -gridSize/2), working towards the positive x-axis
  float rowX = -gridSize/2;
  for (float i = -gridSize/2; i <= gridSize/2 + 0.01f; i = i + offsetX) //rows loop where offsetX = gridSize/columns
  {
    vertexData.add(new PVector(i, 0, -gridSize/2));
    for (float j = -gridSize/2 + offsetZ; j <= gridSize/2 + 0.01f; j = j + offsetZ) //columns loop where offsetZ = gridSize/rows
    {
      vertexData.add(new PVector(rowX, 0, j));
    }
    rowX = rowX + offsetX;
  }
}

void MakeIndexArray() //Makes the index array for the triangles
{
  verticeIndex.clear(); //Clear the array so the next time its called its blank.
  startingIndex = 0; //curentColumn and currentRow = 0 at start
  for (int i = 0; i < columns * rows; i++)
  {
    //Top triangle
    verticeIndex.add(startingIndex);
    verticeIndex.add(startingIndex + 1);
    verticeIndex.add(startingIndex + verticesInaColumn);
    //Bottom triangle
    verticeIndex.add(startingIndex + 1);
    verticeIndex.add(startingIndex + verticesInaColumn);
    verticeIndex.add(startingIndex + verticesInaColumn + 1);

    for (float j = 1; j < 500; j++)
    {
      if (startingIndex == (j * rows + iter) - 1) //If startingIndex is at the second to last vertice of a column, otherwise it breaks once startingIndex equals the bottom most vertice
      {
        startingIndex = startingIndex + 1;
        iter++; //iter starts off at 0
      }
    }
    startingIndex++;
  }
}

void GENERATE()
{
  UpdateVariables();
  MakeVerticeArray(); //Makes the vertices depending on the gridSize, columns, and rows size
  MakeIndexArray(); //Makes the index array to keep track of where the triangles vertices are
  if (sliderfileLoad.getText() != "")
  {
    getImageData(); //It calls a function that gets the height values from the images and applies them to the y values of vertexData array
  }
  generate = true; //After the first click of generate, the triangles will always be drawn
}

void getImageData()
{
  //Load the images from the data folder
  fileLoad = sliderfileLoad.getText();
  terrain = loadImage(fileLoad + ".png");
  imageWidth = terrain.width;
  imageHeight = terrain.height;
  //Take the image data and covert the y values of the vertex index array
  for (float i = 0; i <= rows; i++)
  {
    for (int j = 0; j <= columns; j++)
    {
      x_index = map(j, 0, columns+1, 0, imageWidth);
      y_index = map(i, 0, rows+1, 0, imageHeight);
      colorVar = red(terrain.get((int)x_index, (int)y_index));


      heightFromColor = map(colorVar, 0, 255, 0, 1.0f);
      vertex_index = i * (columns + 1) + j;
      vertexData.get((int)vertex_index).y = heightFromColor;
    }
  }
}

void DrawTriangles()
{
  beginShape(TRIANGLES);
  if (useStroke == false)
  {
    noStroke();
  } else if (useStroke == true)
  {
    stroke(0);
  }
  for (int i = 0; i < verticeIndex.size(); i++)
  {
    int indexIterator = verticeIndex.get(i);
    PVector index = vertexData.get(indexIterator);
    //Color
    relativeHeight = ((abs(index.y) * -heightModifier) / -snowThreshold);
    color snow = color(255, 255, 255);
    color grass = color(143, 170, 64);
    color rock = color(135, 135, 135);
    color dirt = color(160, 126, 84);
    color water = color(0, 75, 200);

    if (useColor == true)
    {
      if (relativeHeight > 1.0f)
      {
        fill(0, 75, 200);
      }
      if ((relativeHeight > 0.8f) && (relativeHeight < 1.0f))
      {
        if (useBlend == true)
        {
          ratio = (relativeHeight - 0.8f) / 0.2f;
          fill(lerpColor(rock, snow, ratio));
        } else if (useBlend == false)
        {
          fill(143, 170, 64);
        }
      } else if ((relativeHeight > 0.4f) && (relativeHeight < 0.8f))
      {
        if (useBlend == true)
        {
          ratio = (relativeHeight - 0.4f) / 0.4f;
          fill(lerpColor(grass, rock, ratio));
        } else if (useBlend == false)
        {
          fill(135, 135, 135);
        }
      } else if ((relativeHeight > 0.2f) && (relativeHeight < 0.4f))
      {
        if (useBlend == true)
        {
          ratio = (relativeHeight - 0.2f) / 0.2f;
          fill(lerpColor(dirt, grass, ratio));
        } else if (useBlend == false)
        {
          fill(143, 170, 64);
        }
      } else if (relativeHeight < 0.2f)
      {
        if (useBlend == true)
        {
          ratio = relativeHeight / 0.2f;
          fill (lerpColor(dirt, grass, ratio));
        } else if (useBlend == false)
        {
          fill(255, 255, 255);
        }
      }
    }
    vertex(index.x, index.y * heightModifier, index.z);
  }
  endShape();
}

void UpdateVariables()
{
  iter = 0;
  rows = sliderRows;
  columns = sliderColumns;
  gridSize = slidergridSize;
  useStroke = slideruseStroke;
  useColor = slideruseColor;
  useBlend = slideruseBlend;
  heightModifier = sliderheightModifier;
  snowThreshold = slidersnowThreshold;
  offsetX = gridSize/columns;
  offsetZ = gridSize/rows;
  verticesInaColumn = (int)rows + 1;
}


void mouseDragged2() //This function is to bypass a bug where the grid wouldn't be visible until I dragged the mouse. This is only called once at setup()
{
  if (cp5.isMouseOver())
    return;

  deltaX = 100;
  deltaY = 100;
  //Create phi and theta
  phi = phi + deltaX;
  theta = theta + deltaY;
  //Clamp theta between 1 and 179
  if (theta > 179)
  {
    theta = 179;
  } else if (theta < 1)
  {
    theta = 1;
  }
}
