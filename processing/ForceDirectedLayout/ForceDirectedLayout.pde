String PATH = "processing/data/dict.csv";
String dict[]; 

/* CONSTANTS */
float ENERGY_THRESHOLD = 0.5;
float NODE_RADIUS = 55.0;

float CHARGE  = 1250.0;
float SPRING_CONSTANT = -0.01;
float DAMPING = 0.8;
float TIME = 10.0;

Graph myGraph;

float MASS           = 5.0;
float RESTING_LENGTH = 20.0;

int MAX_FIRST_DEGREE = 10;
int MAX_SECOND_DEGREE = 5;
int RADID = 1;

/* controller */
$(document).ready(function() {

        $("#left").on("click", function() {
                if (done) {
                        RADID--;
                        if (RADID < 0) {
                                RADID = num - 1;
                        }
                        createGraph(RADID);
                }
        });

        $("#right").on("click", function() {
                if (done) {
                        RADID++;
                        if (RADID >= num) {
                                RADID = 0;
                        }
                        createGraph(RADID);
                }
        });

});

void setup() {
      size(1000, 600);
      dict = loadStrings(PATH);
      getData();
}

void draw() {

      fill(0);
      textSize(48);
      textMode(CENTER, CENTER);
      background(236, 240, 241);

      if (done) {
             myGraph.animate();
             myGraph.render();
      } else {
              textAlign(CENTER, CENTER);
              text("loading...", 0, 0, width, height);
      }

      if (radicals.length >= num && !done) {
              done = true;
              createGraph(RADID);
      } 
}

void createGraph(int charId) {
      
      /* Split up radical and rest of characters */
      String radical = radicalData[charId][0].string;
      var characters = [];

      for (int i = 1; i < radicalData[charId].length; i++) {
              if (getOneDef(radicalData[charId][i].string) != "") {
                characters.push(radicalData[charId][i].string);
              }
              if (characters.length > MAX_FIRST_DEGREE) {
                      break;
              }
      }

      Node nodes[]; 
      Edge edges[];

      Node root = new Node(radical, getOneDef(radical), MASS);
      Node firstDegreeNodes[] = new Node[characters.length];
      Edge firstDegreeEdges[] = new Edge[characters.length];

      for (int i = 0; i < characters.length; i++) {
              String def = getOneDef(characters[i]);
              Node newNode = new Node(characters[i], def, MASS);
              Edge newEdge = new Edge(root, newNode, RESTING_LENGTH);
              firstDegreeNodes[i] = newNode;
              firstDegreeEdges[i] = newEdge;
      }

      int totalNodes = 1 + firstDegreeNodes.length;
      for (int i = 0; i < firstDegreeNodes.length; i++) {
              Node n = firstDegreeNodes[i];
              totalNodes += count(n.id);
      }

      nodes = new Node[totalNodes];
      edges = new Edge[totalNodes - 1];

      nodes[0] = root;
      for (int i = 0; i < firstDegreeNodes.length; i++) {
              Node n = firstDegreeNodes[i];
              Edge e = firstDegreeEdges[i];
              nodes[i + 1] = n;
              edges[i] = e;
      }

      int soFar = 1 + firstDegreeNodes.length;
      for (int i = 0; i < firstDegreeNodes.length; i++) {
              Node n = firstDegreeNodes[i];
              int num = count(n.id);
              String chars[] = find(n.id, num);
              String defs[]  = getDefs(n.id, num); 
              for (int j = 0; j < chars.length; j++) {
                      Node m = new Node(chars[j], defs[j], MASS);
                      Edge e = new Edge(n, m, RESTING_LENGTH);
                      nodes[soFar + j]     = m;
                      edges[soFar + j - 1] = e;
              }
              soFar = soFar + chars.length;
      }

      myGraph = new Graph(nodes, edges, ENERGY_THRESHOLD);

}

int count(String c) {

        int num = 0;
        for (int i = 0; i < dict.length; i++) {
                String row = split(dict[i], " ");
                String chars = row[0];
                if ((c.equals(chars[0])) ||
                    (c.equals(chars[1]))) {
                        if ((chars.length == 1 && chars[0].equals(c)) ||
                            (chars.length > 2)) {
                                continue;
                        }
                        num++;

                }
        }

        if (num > MAX_SECOND_DEGREE) {
                num = MAX_SECOND_DEGREE;
        }

        return num;
}

String[] find(String c, int num) {

        int count = 0;

        if (num > MAX_SECOND_DEGREE) {
                num = MAX_SECOND_DEGREE;
        }

        Character result[] = new Character[num];

        for (int i = 0; i < dict.length; i++) {

                String row = split(dict[i], " ");
                String chars = row[0];

                if ((c.equals(chars[0])) ||
                    (c.equals(chars[1]))) {
                        if ((chars.length == 1 && chars[0].equals(c)) ||
                            (chars.length > 2)) {
                                continue;
                        }

                        result[count] = chars;
                        count++;

                        if (count == num) {
                                break;
                        }
                }
        }
        return result;
}

String getOneDef(String c) {

        String def = "";

        for (int i = 0; i < dict.length; i++) {

                String row = split(dict[i], " ");
                String chars = row[0];

                if ((chars.length == 1 && chars[0].equals(c)))  {

                        int index = 0;
                        
                        while (!dict[i][index].equals("/")) {
                                index++;
                        }

                        index++;

                        while (!dict[i][index].equals("/")) {
                                def += dict[i][index];
                                index++;
                        }

                }
        }

        return def;
}

String[] getDefs(String c, int num) {

        int count = 0;

        if (num > MAX_SECOND_DEGREE) {
                num = MAX_SECOND_DEGREE;
        }

        String result = new String[num];

        for (int i = 0; i < dict.length; i++) {

                String row = split(dict[i], " ");
                String chars = row[0];

                if ((c.equals(chars[0])) ||
                    (c.equals(chars[1]))) {
                        if ((chars.length == 1 && chars[0].equals(c)) ||
                            (chars.length > 2)) {
                                continue;
                        }

                        int index = 0;
                        int def   = "";

                        while (!dict[i][index].equals("/")) {
                                index++;
                        }

                        index++;

                        while (!dict[i][index].equals("/")) {
                                def += dict[i][index];
                                index++;
                        }

                        result[count] = def;
                        count++;

                        if (count == num) {
                                break;
                        }
                }
        }

        return result;

}

Node nodeToDrag = null;

void mousePressed() { 
 if (done) {
 myGraph.dragging = true;
 for (int i = 0; i < myGraph.nodes.length; i++) {
   Node n = myGraph.nodes[i];
   if (n.isHovering()) {
     nodeToDrag = n;
     nodeToDrag.dragging = true;
     nodeToDrag.highlighted = true;
     break;
   }
 }
 }
}

void mouseDragged() {
  if (nodeToDrag != null) {
    nodeToDrag.position.x = mouseX;
    nodeToDrag.position.y = mouseY;
  }
}

void mouseReleased() {
  myGraph.dragging = false;
 if (nodeToDrag != null) {
   nodeToDrag.dragging = false;
   nodeToDrag.highlighted = false;
   nodeToDrag = null;
 }
}


/* JS STUFF */
var radicals    = [];
var radicalData = [];
var done = false;
var num = 10000;

function getData() {
      
      var RADICAL_PATH = "http://ccdb.hemiola.com/characters/radicals"

      function init() {
              loadRadicals();
      }

      function loadRadicals() {

              function addRadical(data) {
                      radicals.push(data[0]);
                      radicalData.push(data);
              }

              function parseRadicals (data) {
                      num = data.length;
                      // Get data for each radical 
                      for (var i = 0; i < data.length; i++) {
                              var radId = data[i].radical;
                              $.getJSON(RADICAL_PATH + "/" + radId, addRadical);
                      }
              }
              $.getJSON(RADICAL_PATH, parseRadicals);
      }

      $(document).ready(function() {
              init();
      });

}

class Graph {

float threshold;
Node[] nodes;
Edge[] edges;
boolean dragging;

Graph(Node[] _nodes, Edge[] _edges, float _threshold) {

  nodes = _nodes;
  edges = _edges;
  threshold = _threshold;
  dragging = false;
 
}

float totalEnergy() {
  float energy = 0.0;
  for(int i = 0; i < nodes.length; i++) {
    Node n = nodes[i];
    energy += (0.5 * n.getMass() * sq(n.getVelocity()));
  }
  return energy;
}
boolean debug = true;
void animate() {
  
  for(int i = 0; i < nodes.length; i++) {

    Node n = nodes[i];
    Tuple force = new Tuple(0.0, 0.0);

    for(int j = 0; j < edges.length; j++) {
      Edge e = edges[j];
      if (n.getID() == e.node1.getID()){
        Tuple t = springForce(n, e.node2, e.resting_length, e.curr_length);
        force.x += t.x;
        force.y += t.y;
      } 
      if (n.getID() == e.node2.getID()){
       Tuple t = springForce(n, e.node1, e.resting_length, e.curr_length);  
       force.x += t.x;
       force.y += t.y;
      }
     e.setCurrLength();
    }
    
    //force due to Coulomb's law
    for(int j = 0; j < nodes.length; j++) {
      Node m = nodes[j];
      if (m.id == n.id) continue;
      Tuple t = coulombForce(n, m);
      force.x += t.x;
      force.y += t.y;
    }
    
    n.setVelocityX(force.x);
    n.setVelocityY(force.y);
    n.move();

  }

}

Tuple coulombForce(Node n, Node m){
  float delta_y = n.position.y - m.position.y;
  float delta_x = n.position.x - m.position.x;
     
  float distance = dist(n.position.x, n.position.y, m.position.x, m.position.y);
  float f = CHARGE / sq(distance);
  float theta = atan(delta_y / delta_x);
  if (delta_x < 0) theta += PI;
     
  Tuple force = new Tuple(f * cos(theta), f * sin(theta));
  return force;
}


Tuple springForce(Node n, Node m, float rl, float cl){
  float delta_x = n.position.x - m.position.x;
  float delta_y = n.position.y - m.position.y;
  float delta_length;
  
  delta_length = (cl / 2) - (rl / 2);
  float theta = atan(delta_y / delta_x);
  
  // in second quadrant
  if (delta_x < 0) theta += PI;
  float f = SPRING_CONSTANT * delta_length;
  
  Tuple force = new Tuple(f * cos(theta), f * sin(theta));

  return force;
}

void render() {
  for (int i = 0; i < edges.length; i++) {
     Edge e = edges[i];
     e.render(); 
  }
  for (int i = 0; i < nodes.length; i++) {
     Node n = nodes[i];
     n.render();
  }
}

}

class Node {
int id;
String def;
float mass;
float radius;
Tuple position;
Tuple velocity;

boolean highlighted;
boolean dragging;

Node (int _id, String _def, float _mass) {
  id = _id;
  def = _def;
  mass = _mass;
  
  radius = NODE_RADIUS;

  velocity = new Tuple (0.0, 0.0);
  
  highlighted = false;
  dragging = false;
  
  float randomX = (float)(Math.random() * width);
  float randomY = (float)(Math.random() * height);
    
  position = new Tuple (randomX, randomY);
    
}

int getID() {
  return id;
}

float getMass(){
  return mass; 
}

// gives the magnitude of the total velocity
float getVelocity() {
  return sqrt(sq(velocity.x) + sq(velocity.y));
}

void setVelocityX(float f) {
  float acceleration =(f / mass);
  velocity.x =  (DAMPING * velocity.x) + (acceleration * TIME);   
}

void setVelocityY(float f){
  float acceleration = (f / mass);
  velocity.y = (DAMPING * velocity.y) + (acceleration * TIME); 
}

boolean isHovering() {
  float mouse_distance = dist(position.x, position.y, mouseX, mouseY);
  return (mouse_distance < (radius * 0.5));
}

void move() {
  if (dragging) {
    position.x = mouseX;
    position.y = mouseY;
  } else {
    position.x += velocity.x;
    position.y += velocity.y;
  }
}

void render() {

  fill(255, 255, 255); 
  textAlign(CENTER, CENTER);    
  
  if (dragging || (isHovering() && !dragging)) {
    stroke(231, 76, 60);
    fill(231, 76, 60);
  }

  ellipse(position.x, position.y, radius, radius);

  fill(0);
  textSize(24);
  text(id, position.x, position.y);

  stroke(0, 0, 0);
 
  if (dragging || (isHovering() && !dragging)) {
          renderInfoBox(id, def, position.x + 30.0, position.y + 30.0); 
  }

}

void renderInfoBox(String c, String d, float x, float y) {
        float w = 150.0;
        float h = 100.0;
        
        textAlign(CENTER, CENTER);
        if ((x + w) > width) {
                x = x - w;
        }
        if ((y + h) > height) {
                y = y - h;
        }

        fill(255, 255, 255)
        rect(x, y, w, h); 

        fill(0);
        textSize(12);
        text(d, x, y, w, h); 
}

}

class Edge {
Node node1, node2;
float curr_length, resting_length;

Edge(Node _node1, Node _node2, float _resting_length){
  node1 = _node1;
  node2 = _node2;
  resting_length = _resting_length;
  setCurrLength();
}

void setCurrLength(){
  curr_length = dist(node1.position.x, node1.position.y,
                     node2.position.x, node2.position.y);
}

float getCurrLength(){
  return curr_length;
}

void render() {
  fill(0);
  line(node1.position.x, node1.position.y, node2.position.x, node2.position.y);
}

}

class Tuple {

float x;
float y;

Tuple(float _x, float _y) {
 x = _x;
 y = _y;
}

float getX(){
 return x; 
}

float getY(){
 return y; 
}

void setX(float _x){
 x = _x; 
}

void setY(float _y){
 y = _y; 
}

}
