class Camera //Simple orbit camera which rotates around, and looks at, a specific point x, y, z
{
  float x = 0;
  float y = 0;
  float z = 0;
  float derivedX = 0;
  float derivedY = 0;
  float derivedZ = 0;
  float radius = 30;
  float eyeX = 0.0f;
  float eyeY = 0.0f;
  float eyeZ = 0.0f;
  float centerX = 0.0f;
  float centerY = 0.0f;
  float centerZ = 0.0f;
  float theta = 0.0f;
  float phi = 0.0f;
  float lookAtTargetX = 0;
  float lookAtTargetY = 0;
  float lookAtTargetZ = 0;
  

  void Update( float phi, float theta) //Called every frame from the draw() function, calculates values to pass to the camera() function
  { 
    //Calculate the derived x, y, and z values
    derivedX = radius * cos(radians(phi)) * sin(radians(theta));
    derivedY = radius * cos(radians(theta));
    derivedZ = radius * sin(radians(theta)) * sin(radians(phi));
       
    //Assign my cameraPositions
    cameraPosition.x = lookAtTargetX + derivedX;
    cameraPosition.y = lookAtTargetY + derivedY;
    cameraPosition.z = lookAtTargetZ + derivedZ;
    
    //Assign the Eye variables that will be used in calling camera()
    eyeX = cameraPosition.x;
    eyeY = cameraPosition.y;
    eyeZ = cameraPosition.z;
    
    //Assign the center variables that will be used in calling camera(), in this case it's all zeros since our target never moves
    centerX = 0;
    centerY = 0;
    centerZ = 0;
    
    //Call camera
    camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, 0.0, 1.0, 0.0); //camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
  }

  void Zoom(float mouseWheelCount) //Move toward or away from the look at target by using the scroll wheel 
  {
      if ((mouseWheelCount == 1.0) && (radius < 200))
      {
        radius = radius + 2;
      }
      else if ((mouseWheelCount == -1.0) && (radius > 10))
      {
        radius = radius - 2;
      }
  }
  
}
