String PATH = "processing/data/stroke-grade-freq.csv";

/* Display Constants */
float MARGIN  = 10.0;
float PADDING = 0.10;
float SPACING = 10.0;
float GUTTER  = 150.0;

int data[][][];
String[] chars[][][];

int ilength = 3; 
int jlength = 3; 
int klength = 3; 

int itotal = 0;  
int jtotal = 0; 
int ktotal = 0; 

int ifreqs[] = new int[ilength];
int jfreqs[] = new int[jlength];
int kfreqs[] = new int[klength];

float ixs[] = new float[ilength + 1];
float jxs[] = new float[jlength + 1]; 
float kxs[] = new float[klength + 1]; 

/* Highlighting */
PGraphics pickbuffer = null; 
int hli = -1;
int hlj = -1;
int hlk = -1;

void setup() {
        size(1000, 600);
        data  = new int[ilength][jlength][klength];
        chars = new String[ilength][jlength][klength][];
        wipedata();
        parse();
}

void draw() {

        background(236, 240, 241);
        pickbuffer = createGraphics(width, height);

        float originy = (height - MARGIN - (height * PADDING));

        float set1originx = (MARGIN + (width * PADDING));
        float set1originy = (MARGIN + (height * PADDING));
        float set1rightx  = (width - GUTTER - (width * PADDING));

        float set2originx = set1originx;
        float set2originy = (((MARGIN + (width * PADDING)) + originy) / 2);
        float set2rightx  = set1rightx;

        float set3originx = set1originx;
        float set3originy = originy;  
        float set3rightx  = set1rightx;

        pglink(pickbuffer, set1originy, set2originy, set3originy);

        if (mousePressed) {
                color pixel = pickbuffer.get(mouseX, mouseY);
                hli = (pixel >> 16) & 0xFF;
                hlj = (pixel >> 8) & 0xFF;
                hlk = pixel & 0xFF;
        } else {
                hli = -1; 
                hlj = -1; 
                hlk = -1; 
        }
 
        link(set1originy, set2originy, set3originy);
        drawSetLabels(set1originx, set1originy, set2originy, set3originy);
        drawSet(ifreqs, itotal, ixs, set1originx, set1originy, set1rightx);
        drawSet(jfreqs, jtotal, jxs, set2originx, set2originy, set2rightx);
        drawSet(kfreqs, ktotal, kxs, set3originx, set3originy, set3rightx);

}

void wipedata() {
        for (int i = 0; i < ilength; i++) {
                ifreqs[i] = 0;
                for (int j = 0; j < jlength; j++) {
                        ifreqs[j] = 0;
                        for (int k = 0; k < klength; k++) {
                                ifreqs[k] = 0;
                                data[i][j][k] = 0;
                                chars[i][j][k] = [];
                        }
                }
        }        
}

void parse() {

        String lines[]   = loadStrings(PATH);
        String headers[] = split(lines[0], ",");

        int is[] = new int[lines.length - 1];
        int js[] = new int[lines.length - 1];
        int ks[] = new int[lines.length - 1];

        /* parse csv */
        for (int i = 1; i < lines.length; i++) {
                String row[] = split(lines[i], ",");
                is[i - 1] = parseInt(row[3]);
                js[i - 1] = parseInt(row[2]);
                ks[i - 1] = parseInt(row[1]);
        }

        for (int i = 0; i < is.length; i++) {
                String row[] = split(lines[i + 1], ",");
                int tempi = groupi(is[i]);
                int tempj = groupj(js[i]);
                int tempk = groupk(ks[i]);
                data[tempi][tempj][tempk]++;
                chars[tempi][tempj][tempk].push(row[0]);
        }

        for (int i = 0; i < is.length; i++) {
                ifreqs[groupi(is[i])]++;
        }

        for (int j = 0; j < js.length; j++) {
                jfreqs[groupj(js[j])]++;
        }

        for (int k = 0; k < ks.length; k++) {
                kfreqs[groupk(ks[k])]++;
        }

        itotal = is.length;
        jtotal = js.length;
        ktotal = ks.length;

}

void drawSet(int set[], int total, float xs[], float originx, float originy, float rightx) {
 
        float linew = rightx - originx;
        float tempx = originx;

        stroke(0);
        strokeWeight(3);
        strokeCap(SQUARE);

        for (int i = 0; i < set.length; i++) {
                int freq = set[i];
                float sectionw = (linew * ((float)freq/(float)total));
                line(tempx, originy, tempx + sectionw - SPACING, originy);
                xs[i] = tempx;
                tempx = tempx + sectionw;
        }

        xs[set.length] = rightx;
                
}

float[] copyOf(float xs[]) {
        float copy[] = new float[xs.length];
        for (int i = 0; i < xs.length; i++) {
                copy[i] = xs[i];
        }
        return copy;
}

void link(float set1originy, float set2originy, float set3originy) {

        noStroke();

        float tempixs[] = copyOf(ixs);
        float tempjxs[] = copyOf(jxs);
        float tempkxs[] = copyOf(kxs);

        for (int i = 0; i < ilength; i++) {

                float majorw = ixs[i + 1] - ixs[i] - SPACING; 

                int r = 0;
                int g = 0;
                int b = 0;

                fill(0);
                textAlign(LEFT, BOTTOM);
                textSize(16);

                if (i == 0) {
                        r = 231;
                        g = 76;
                        b = 60;
                } else if (i == 1) {
                        r = 230;
                        g = 126;
                        b = 34;
                } else {
                        r = 241;
                        g = 196;
                        b = 15;
                }

                fill(r, g, b, 150);
                
                int total = 0; 
                for (int j = 0; j < jlength; j++) {

                        for (int k = 0; k < klength; k++) {
                                total += data[i][j][k];
                        }
                }
                 
                for (int j = 0; j < jlength; j++) {
                        int freq = 0;
                        for (int k = 0; k < klength; k++) {
                                freq += data[i][j][k];
                        }

                        float ratio = ((float)freq/(float)total);
                        float dx = majorw * ratio;

                        if ((i == hli) && (j == hlj) && (hlk == 255)) {
                                fill(r, g, b, 255);
                        } else {
                                fill(r, g, b, 150);
                        }

                        beginShape();
                        vertex(ixs[i], set1originy);
                        vertex(ixs[i] + dx, set1originy);
                        vertex(jxs[j] + dx, set2originy);
                        vertex(jxs[j], set2originy);
                        endShape(CLOSE);

                        float lastj = jxs[j];
                        ixs[i] = ixs[i] + dx;
                        jxs[j] = jxs[j] + dx;

                        for (int k = 0; k < klength; k++) {

                                int subfreq = data[i][j][k];
                                float subratio = ((float)subfreq/(float)freq);
                                float ddx = dx * subratio;

                                if ((i == hli) && (j == hlj) && ((k == hlk) || (hlk == 255))) {
                                        fill(r, g, b, 255);
                                } else {
                                        fill(r, g, b, 150);
                                }
 
                                beginShape();
                                vertex(lastj, set2originy);
                                vertex(lastj + ddx, set2originy);
                                vertex(kxs[k] + ddx, set3originy);
                                vertex(kxs[k], set3originy);
                                endShape(CLOSE);

                                if ((i == hli) && (j == hlj) && (k == hlk)) {
                                        displayChars(i, j, k, set1originy, set3originy);
                                }

                                lastj = lastj + ddx;
                                kxs[k] = kxs[k] + ddx;
                        }


                }
 
                fill(0);
                if (i == 0) {
                        text("LOW", tempixs[i], set1originy);
                        text("LOW", tempjxs[i], set2originy);
                        text("LOW", tempkxs[i], set3originy);
                } else if (i == 1) {
                        text("MEDIUM", tempixs[i], set1originy);
                        text("MEDIUM", tempjxs[i], set2originy);
                        text("MEDIUM", tempkxs[i], set3originy);
                } else {
                        textAlign(CENTER, BOTTOM);
                        text("HIGH", tempixs[i], set1originy);
                        textAlign(LEFT, BOTTOM);
                        text("HIGH", tempjxs[i], set2originy);
                        text("HIGH", tempkxs[i], set3originy);
                }
       
        }

        ixs = tempixs;
        jxs = tempjxs;
        kxs = tempkxs;

}

void displayChars(int i, int j, int k, float topy, float bottomy) { 
        String result = "";
        String[] cs = chars[i][j][k];
        for (int n = 0; n < cs.length; n++) {
                result = result + cs[n] + " ";
        }
        float leftx = width - GUTTER - (PADDING * width);
        fill(0);
        text(result, leftx + 10.0, topy, width - leftx - 20.0, (bottomy - topy));
}

int groupi(int value) {

        if ((value >= 0) && (value < 10)) {
                return 0;
        } else if ((value >= 10) && (value < 20)) {
                return 1;
        } else {
                return 2;
        }

}

int groupj(int value) {

        if ((value == 1) || (value == 2)) {
                return 0;
        } else if ((value == 3) || (value == 4)) {
                return 1;
        } else {
                return 2;
        }

}

int groupk(int value) {

        if ((value == 1) || (value == 2)) {
                return 2;
        } else if ((value == 3) || (value == 4)) {
                return 1;
        } else {
                return 0;
        }

}

void pglink(PGraphics pg, float set1originy, float set2originy, float set3originy) {

        pg.beginDraw();
        pg.noStroke();
        pg.background(255, 255, 255);

        float tempixs[] = copyOf(ixs);
        float tempjxs[] = copyOf(jxs);
        float tempkxs[] = copyOf(kxs);

        for (int i = 0; i < ilength; i++) {

                float majorw = ixs[i + 1] - ixs[i] - SPACING; 
                int total = 0; 
                for (int j = 0; j < jlength; j++) {
                        for (int k = 0; k < klength; k++) {
                                total += data[i][j][k];
                        }
                }
                 
                for (int j = 0; j < jlength; j++) {
                        int freq = 0;
                        for (int k = 0; k < klength; k++) {
                                freq += data[i][j][k];
                        }

                        float ratio = ((float)freq/(float)total);
                        float dx = majorw * ratio;

                        pg.fill(i, j, 255);
                        pg.beginShape();
                        pg.vertex(ixs[i], set1originy);
                        pg.vertex(ixs[i] + dx, set1originy);
                        pg.vertex(jxs[j] + dx, set2originy);
                        pg.vertex(jxs[j], set2originy);
                        pg.endShape(CLOSE);

                        float lastj = jxs[j];
                        ixs[i] = ixs[i] + dx;
                        jxs[j] = jxs[j] + dx;

                        for (int k = 0; k < klength; k++) {
                                int subfreq = data[i][j][k];
                                float subratio = ((float)subfreq/(float)freq);
                                float ddx = dx * subratio;
                                pg.fill(i, j, k);
                                pg.beginShape();
                                pg.vertex(lastj, set2originy);
                                pg.vertex(lastj + ddx, set2originy);
                                pg.vertex(kxs[k] + ddx, set3originy);
                                pg.vertex(kxs[k], set3originy);
                                pg.endShape(CLOSE);
                                lastj = lastj + ddx;
                                kxs[k] = kxs[k] + ddx;
                        }


                }
        
        }

        pg.endDraw();  

        ixs = tempixs;
        jxs = tempjxs;
        kxs = tempkxs;

}

void drawSetLabels(float originx, float set1originy, float set2originy, float set3originy) {

        fill(127, 140, 141);
        textSize(16);
        textAlign(LEFT, BOTTOM);

        text("STROKE COUNT", originx, set1originy - 20.0);
        text("GRADE LEVEL", originx, set2originy - 20.0);
        text("FREQUENCY", originx, set3originy - 20.0);

}
