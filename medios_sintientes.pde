import processing.sound.*;
import java.io.File;
import java.util.TreeMap;
import java.util.Random;

AudioIn input;
SawOsc sin;
PinkNoise pn;
Amplitude amp;
File dir;
File [] files;
TreeMap<Float, PImage> images;
boolean mouse_pressed = false;
int numFrame = 0;
int maxFrame = 0;
PImage currentImg;
float maxVolume = 0.0;
Random r = new Random();

float [] doScale = new float[]{261.626/4, 293.665/4, 329.628/4, 349.228/4, 391.995/4, 391.995/4, 493.883/4,
                               261.626/2, 293.665/2, 329.628/2, 349.228/2, 391.995/2, 391.995/2, 493.883/2, 
                               261.626, 293.665, 329.628, 349.228, 391.995, 391.995, 493.883,
                               261.626*2, 293.665*2, 329.628*2, 349.228*2, 391.995*2, 391.995*2, 493.883*2,
                               261.626*4, 293.665*4, 329.628*4, 349.228*4, 391.995*4, 391.995*4, 493.883*4};
void setup(){
  size(1024, 640);
  pixelDensity(displayDensity());
  background(0);
  
  // Check sound list
  Sound s = new Sound(this);
  s.inputDevice(0);
  
  // Create audio input signal
  input = new AudioIn(this, 0);
  input.start();
  
  // Create sine oscilator
  sin = new SawOsc(this);
  // Create pink noise
  pn = new PinkNoise(this);
  
  // Create a new Amplitude analyzer
  amp = new Amplitude(this);
  amp.input(input); // Patch the input to the volume analyzer
  
  // Load folder with images and map each image to its brightness
  dir = new File(savePath("data"));
  files = dir.listFiles();
  images = new TreeMap<Float, PImage>();
  
  for (int i = 0; i <= files.length - 1; i++) {
    String path = files[i].getAbsolutePath();
    if(path.toLowerCase().endsWith(".jpeg") || path.toLowerCase().endsWith(".jpg")
       || path.toLowerCase().endsWith(".png")) {
      PImage image = loadImage(path);
      images.put(calculateWeight(image), image);
    }
  }
  println("Finished loading archive.");
  println(images.keySet());
}

float calculateWeight(PImage img) {
  
  img.loadPixels();
  
  float mean_color = (red(img.pixels[0])+green(img.pixels[0])+blue(img.pixels[0]))/3.0;
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 1; x < img.width; x++) {
      int loc = x + y*img.width;
      // We calculate the mean_color
      mean_color = mean_color +
        (red(img.pixels[loc])+green(img.pixels[loc])+blue(img.pixels[loc]))/3.0;
    }
  }
  return map(mean_color/img.pixels.length, 0, 255, 0, 1);
}

void mousePressed() {
  if (mouse_pressed == false) {
    sin.play();
    pn.play();
    mouse_pressed = true;
  } else {
    sin.stop();
    pn.stop();
    mouse_pressed = false;
  }
}

PImage getImage(float volume) {
  PImage img;
  try {
    img = images.higherEntry(volume).getValue();
  } catch (Exception e) {
    img = images.get(images.lastKey());
  }
  int[] final_dim = getScaledDimension(img.width, img.height, width, height);
  img.resize(final_dim[0], final_dim[1]);
  return img;
}

int [] getScaledDimension(int original_width, int original_height,
                         int bound_width, int bound_height) {

    int new_width = original_width;
    int new_height = original_height;

    // first check if we need to scale width
    if (original_width > bound_width) {
        //scale width to fit
        new_width = bound_width;
        //scale height to maintain aspect ratio
        new_height = (new_width * original_height) / original_width;
    }
    // then check if we need to scale even with the new height
    if (new_height > bound_height) {
        //scale height to fit instead
        new_height = bound_height;
        //scale width to maintain aspect ratio
        new_width = (new_height * original_width) / original_height;
    }

    return new int[]{int(new_width), int(new_height)};
}

void setImagePosMode(PImage img, float random){
  if (random <= 75){
    imageMode(CENTER);
    image(img, width/2, height/2);
  } else {
    imageMode(CORNER);
    image(img, int(random(-width/2, width/2)), int(random(-height/2, height/2)));
  }
}
void draw() {
  if (numFrame==0.0){
    int napTime = int(random(1, 4));
    numFrame = napTime*60;
    maxFrame = napTime*60;
  } else if (numFrame == 1) {
    // Volume is used to select an image that is shown on screen
    float volume = amp.analyze();
    if (volume > 0.0015){
      volume = volume - 0.0015;
    } else {
      volume = 0;
    }
    volume = map(volume, 0, 0.06, images.firstKey(), images.lastKey());
    
    currentImg = getImage(volume);
  
    setImagePosMode(currentImg, random(0, 100));
  }
  
  if (mouse_pressed == true) {
    if (numFrame%60==0){
      float [] params = getSinParams(currentImg);
      sin.set(params[0], params[1], params[2], params[3]);
      pn.set(params[1], params[2], 0.0);
    }
  }
  numFrame = numFrame - 1;
}

float [] getSinParams(PImage img){
  int x = int(map(numFrame, 0, maxFrame-1, 0, img.width-1));
  img.loadPixels();
  int y = r.nextInt(img.height-1);
  float freq = mapFreq(y, img.height);
  float add = map(x, 0, img.width, 0, 0.5);
  float amp = mapAmp(img, x, y);
  float pos = 0;
  return new float [] {freq, amp, add, pos};
}

float mapFreq(int i, int h){
  int j = int(map(i, 0, h-1, 0, doScale.length-1));
  return doScale[j];
}

float mapAmp(PImage img, int x, int y){
  img.loadPixels();
  float r = red(img.pixels[x + y*img.width]);
  float g = green(img.pixels[x + y*img.width]);
  float b = blue(img.pixels[x + y*img.width]);
  return map((0.2126*r + 0.7152*g + 0.0722*b), 0, 255, 0.01, 0.05);
}
