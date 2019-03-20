float PROP_BRAZO = 0.021;

public class Cuerpo {
  protected float tam;
  protected float x;
  protected float masa;
  protected float v;
  
  // tam en cm, x coordenada, masa en kg, v en m/s
  Cuerpo(float tam, float x, float masa, float v) {
    this.tam = tam/10; //en decenas de cm
    this.x = x;
    this.masa = masa;
    this.v = v; 
  }
  
  void dibujar() {
    ellipse(x, 0, tam, tam); 
  }
  
  void actualizarPos() {
    x += v; 
  }
    
  float pos() {
    return x;
  }
  float masa() {
    return masa;
  }
  float vel() {
    return v*frameRate/10;
    // La v real es los pixeles avanzados cada frame, por el frameRate,
    // entre 10 
  }
  
  // Devuelve la altura en cm
  float altura() {
    return tam*10;
  }
  
}
public class Astronauta extends Cuerpo {
  private Cuerpo brazo;
  private boolean deUnaPieza;
  
  Astronauta(float tam, float x, float masa, float v) {
    super(tam, x, masa, v);
    brazo = new Cuerpo(tam * PROP_BRAZO, x, masa * PROP_BRAZO, v);
    this.deUnaPieza = true;
  }
  
  void dibujar(){
    super.dibujar();
    if (!deUnaPieza) {
      brazo.dibujar();
    }
  }
  
  void lanzarBrazo(float vBrazo) {
    //momFin = momIni
    //momFin = vIni * mIni
    //mSinB*vSinB + mBrazo*vBrazo = vIni * mIni
    //vSinB = (vIni*mIni - mBrazo*vBrazo) / mSinB
    // la velocidad final del astronauta sera vSinB
    float masaTot = this.masa;
    this.masa -= this.brazo.masa; // Nueva masa del astronauta
    this.deUnaPieza = false;      // Yep
    this.brazo.v = vBrazo;        // Nuevas posiciones y velocidades del brazo
    this.brazo.x = this.x;
    this.v = (this.v * masaTot - this.brazo.masa * vBrazo) / this.masa; // Velocidad final del astronauta
  }
  
  boolean manca() {
    return !deUnaPieza;
  }

  void actualizarPos() {
    super.actualizarPos();
    if (!deUnaPieza) {
      brazo.actualizarPos();
    }
  }

}

void dibujarBarra() {
  pushMatrix();
  translate(0,-50);
  
  line(0,0,width,0);
  for (int i = 0; i < width/10; i+=2) {
    translate(20,0);
    line(0,-3,0,3);
    if ((i+2)%10 == 0) { // cada 10 m
      fill(255);
      text((i+2) + " m", -15, -10);
    
    }
  }
  
  
  popMatrix();
  
}

void mostrarStats(boolean mostrarTodo) {
  pushMatrix();
  translate(0,8*height/9);
  text("Josefa: ",10,-14);
  text("Altura: " + josefa.altura()+ " cm",30,0);
  text("Masa: " + josefa.masa() + " kg",30,14);
  text("Velocidad: " + nf(josefa.vel(),0,2) + " m/s",30,28);
  text(nf(3.6*josefa.vel(),0,2) + " km/h", 95, 42);
  if (true) {
    pushMatrix();
    translate(width-width/5,0);
    text("Brazo: ",10,-14);
    text("Masa: " + josefa.brazo.masa() + " kg",30,0);
    text("Velocidad: " + nf(josefa.brazo.vel(),0,2) + " m/s",30,14);
    text(nf(3.6*josefa.brazo.vel(),0,2) + " km/h", 95, 28);
    popMatrix();
  }
  popMatrix();
}

Astronauta josefa; 
PImage fondo;
void setup() {
    size(960,480);
    fondo = loadImage("image.png");
    background(fondo);
    stroke(255);
    josefa = new Astronauta(160, 0, 60, 1);
    
}
    
void draw() {
    // Para dejar estela:
    /*fill(0, 120);
    rect(0, 0, width, height);*/
    background(fondo);
    pushMatrix();
    translate(0, height/5); // Empieza en medio
    
    dibujarBarra();
    
    
    fill(255);
    josefa.dibujar();
    josefa.actualizarPos();
    if (josefa.pos() > width/2 && !josefa.manca()) {
      josefa.lanzarBrazo(100);
    }
    fill(255);
    popMatrix();
    mostrarStats(josefa.pos() > 2*width/5 || josefa.manca());
    if(josefa.pos() > width || josefa.pos() < 0) {
      //Se ha salido. reseteamos
      setup();
    }
}
