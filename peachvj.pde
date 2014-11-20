import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;

ArrayList<Ball> bs = new ArrayList<Ball>();

void setup()
{
  size(700, 700);
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
}

int div = 600;
PVector center = new PVector(0, 0);
void draw()
{
  background(0);
  fft.forward( jingle.mix );  
  for(Ball b : bs){
    b.r = 2;
  }
  int interval = (int)(fft.specSize() / div) + 1;
  for(int i=0; i<fft.specSize(); i++){
    Ball b = bs.get((int)(i/interval));
    b.r += pow(fft.getBand(i),2);
  }
  for(Ball b : bs){
    b.r = min(b.r, max_thre);
  }
  show();
}

float max_thre = 20;
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
    b1.c = color(map(b1.r, 0, max_thre, 0, 255),
                 map(b1.r*b1.r, 0, max_thre, 0, 255),
                 map(b1.r, 0, max_thre, 0, 25));
    stroke(b1.c);
    ellipse(b1.p.x, b1.p.y, b1.r, b1.r);
  }
}

class Ball {
  Ball(){
  }
  PVector p = new PVector(random(width/2 - 100, width/2 + 100),
                          random(height/2 - 100, height/2 + 100));
  PVector v = new PVector(random(-3, 3), random(-3, 3));
  float r = 20;
  color c = color(255);
}
