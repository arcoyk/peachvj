import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;

float max_thre = 20;
int shape_mode = 0;
float color_mode = -1;
int back_mode = -1;

int div = 600;
PVector center = new PVector(0, 0);

ArrayList<Ball> bs = new ArrayList<Ball>();
ArrayList<PImage> imgs = new ArrayList<PImage>();
PShader shader;

class Ball {
  Ball(){
  }
  PVector p = new PVector(random(width / 2 - 100, width / 2 + 100),
                          random(height / 2 - 100, height / 2 + 100));
  PVector v = new PVector(random(-3, 3), random(-3, 3));
  float r = 20;
  color c = color(255);
}

void setup()
{
  size(700, 700, P2D);
  shader = loadShader("blur.glsl");
  shader.set("div", 19.0);
  noFill();
  minim = new Minim(this);
  jingle = minim.loadFile("All_the_spieces_on_the_earth.mp3", 1024);
  jingle.loop();
  fft = new FFT( jingle.bufferSize(), jingle.sampleRate() );  
  for (int i = 0; i < div; i++){
    Ball b = new Ball();
    bs.add(b);
  }
  center.x = width/2;
  center.y = height/2;
  ellipseMode(CENTER);
  background(0);
  for (int i = 0; i < 5; i++) {
    PImage img = loadImage("img/" + i + ".jpg");
    imgs.add(img);
  }
}


void draw()
{
  if (back_mode != -1) {
    background(back_mode);
  }
  back_mode = -1;
  fft.forward( jingle.mix );  
  int interval = (int)(fft.specSize() / div) + 1;
  for (Ball b : bs) {
    b.r = 2;
  }
  for (int i = 0; i < fft.specSize(); i++) {
    Ball b = bs.get((int)(i / interval));
    b.r += pow(fft.getBand(i),2);
  }
  for (Ball b : bs) {
    b.r = min(b.r, max_thre);
  }
  filter(shader);
  show();
}

void show(){
  for(Ball b : bs){
    if(b.r <= max_thre * 0.2){
      b.p.x += b.v.x;
      b.p.y += b.v.y;
    }
  }
  for(int i = 0; i < bs.size(); i++){
    Ball b1 = bs.get(i);
    for(int m = i+1; m < bs.size(); m++){
      Ball b2 = bs.get(m);
      if(PVector.dist(b1.p, b2.p) < b1.r+b2.r){
        PVector tmp = new PVector(0, 0);
        tmp.x = b1.v.x;
        tmp.y = b1.v.y;
        b1.v.x = b2.v.x;
        b1.v.y = b2.v.y;
        b2.v.x = tmp.x;
        b2.v.y = tmp.y;
      }
    }
    if(PVector.dist(b1.p, center) > width/2){
      b1.v.x *= -1;
      b1.v.y *= -1;
    }
    b1.c = basic_color(b1);
    stroke(b1.c);
    draw_shape(b1);
  }
}

void draw_shape(Ball b) {
  if (shape_mode == 0) {
    ellipse(b.p.x, b.p.y, b.r, b.r);
  } else if (shape_mode == 1) {
    float theta = random(2 * PI);
    line(b.p.x, b.p.y, b.p.x + b.r * cos(theta), b.p.y + b.r * sin(theta));
  } else if (shape_mode == 2) {
    rect(b.p.x, b.p.y, b.r, b.r);
  }
}

color basic_color(Ball b1) {
  if (color_mode == -1) {
    return color(b1.r, 255, 0);
  } else if (color_mode == -2) {
    return color(0, 255, 200 + b1.r);
  } else {
    return (int)color_mode;
  }
}

void keyPressed() {
  if (key == 'q') {
    shader.set("div", 20.0);
  }else if (key == 'w') {
    shader.set("div", 19.0);
  }else if (key == 'a') {
    color_mode = -2;
  }else if (key == 's') {
    color_mode = -1;
  }else if (key == 'd') {
    color_mode = color((int)random(200, 255),
                       (int)random(200, 255),
                       (int)random(200, 255));
  }else if (key == 'z') {
    shape_mode = 0;
  }else if (key == 'x') {
    shape_mode = 1;
  }else if (key == 'c') {
    shape_mode = 2;
  }else if (key == 'p') {
    back_mode = color(255, 10, 0);
  }else if (key == 'o') {
    back_mode = color(0, 255, 10);
  }else if (key == 'i') {
    back_mode = color(0, 100, 255);
  }else if (key == 'u') {
    back_mode = (int)random(255 * 255 * 255);
  }else if (key == 'l') {
    PImage img = imgs.get(1);
    image(img, (width - img.width) / 2, (height - img.height) / 2);
  }else if (key == 'k') {
    PImage img = imgs.get(2);
    image(img, (width - img.width) / 2, (height - img.height) / 2);
  }else if (key == 'j') {
    PImage img = imgs.get(3);
    image(img, (width - img.width) / 2, (height - img.height) / 2);
  }else if (key == 'h') {
    PImage img = imgs.get(4);
    image(img, (width - img.width) / 2, (height - img.height) / 2);
  }else if (key == 'g') {
    PImage img = imgs.get(0);
    image(img, (width - img.width) / 2, (height - img.height) / 2);
  }
}
