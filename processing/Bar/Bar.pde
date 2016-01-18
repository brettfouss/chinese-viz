String PATH = "processing/data/lang-freq.csv";

/* Parallel Arrays */
String countries[];
int    numSpeakers[];

/* Display Constants */
float MARGIN      = 20.0;
float PADDING     = 0.1;
float BAR_PADDING = 0.05;

void setup() {
       size(800, 600);
       parse();
}

void draw() {
        background(236, 240, 241);
        drawAxes();
        drawBars();
}

void parse() {

        String lines[]   = loadStrings(PATH);
        String headers[] = split(lines[0], ",");

        countries   = new String[lines.length - 1];
        numSpeakers = new int[lines.length - 1];

        for (int i = 1; i < lines.length; i++) {
                String row[]   = split(lines[i], ",");
                countries[i - 1]   = row[0];
                numSpeakers[i - 1] = parseInt(row[2]);
        }

}

void drawAxes() {

        float originx = (MARGIN + (width * PADDING));
        float originy = (height - MARGIN - (height * PADDING));

        float topx = originx;
        float topy = (MARGIN + (height * PADDING));

        float rightx = (width - MARGIN - (width * PADDING));
        float righty = originy;

        fill(189, 195, 199);

        pushMatrix();
        translate(originx - 60.0, (topy + originy)/2);
        rotate(3*HALF_PI);
        textAlign(CENTER, CENTER);
        text("Number of native (first-language) speakers, in millions",0,0);
        popMatrix();

        textAlign(CENTER, CENTER);
        text("Countries", (rightx + originx)/2, originy + 30.0); 

        fill(236, 240, 241);
        stroke(189, 195, 199);
        line(originx, originy, topx, topy);
        line(originx, originy, rightx, righty);

        float sectiony = ((originy - topy) / numSpeakers.length); 

        int max = findMaxVal(numSpeakers);
        int inc = (max / numSpeakers.length);
        
        for (int i = 1; i < numSpeakers.length; i++) {
                float tickx = originx;
                float ticky = originy - ((float)i * sectiony);
                line(tickx, ticky, tickx - 5.0, ticky);
                fill(189, 195, 199);
                textAlign(RIGHT, CENTER);
                text(round(60 * i), tickx - 10.0, ticky);
                fill(236, 240, 241);
        }

}

void drawBars() {

        float originx = (MARGIN + (width * PADDING));
        float originy = (height - MARGIN - (height * PADDING));

        float topx = originx;
        float topy = (MARGIN + (height * PADDING));
        
        float rightx = (width - MARGIN - (width * PADDING));
        float righty = originy;

        float axisw = rightx - originx;
        float barw  = (axisw / numSpeakers.length);

        int max = findMaxVal(numSpeakers);

        for (int i = (numSpeakers.length - 1); i >= 0; i--) {
                float val  = (float)numSpeakers[numSpeakers.length - 1 - i];
                float barh = ((originy - topy) * (val / max)); 
                fill(52, 73, 94);
                if (val == max) {
                        fill(189, 195, 199);
                        textAlign(LEFT, BOTTOM);
                        float noticex = ((originx + (i * barw)) + ((barw * BAR_PADDING)/2));
                        line(noticex - 20.0, (originy - barh), noticex - 35.0, (originy - barh));
                        line(noticex - 35.0, (originy - barh), noticex - 40.0, (originy - barh) + 20.0);
                        line(noticex - 40.0, (originy - barh) + 20.0, noticex - 550.0, (originy - barh) + 20.0);
                        text("There are roughly three times as many native Chinese speakers than native Spanish speakers", 
                              noticex - 550.0, (originy - barh) + 15.0);
                        fill(231, 76, 60);
                }

                if ((mouseX >= ((originx + (i * barw)) + ((barw * BAR_PADDING)/2))) &&
                    (mouseX <= ((originx + (i * barw)) + ((barw * BAR_PADDING)/2) + barw)) &&
                    (mouseY >= (originy - barh)) &&
                    (mouseY <= originy)) {
                        fill(189, 195, 199);
                        textAlign(CENTER, TOP);
                        text(countries[numSpeakers.length - 1 - i], 
                                        (((originx + (i * barw)) + ((barw * BAR_PADDING)/2)) + (barw/2)), originy + 2.0); 
                        fill(231, 76, 60);
                }
                

                rect(((originx + (i * barw)) + ((barw * BAR_PADDING)/2)),
                     (originy - barh), barw, barh);
        }

}

int findMaxVal(int[] arr) {
        int max = arr[0];
        for (int i = 0; i < arr.length; i++) {
                if (arr[i] > max) {
                        max = arr[i];
                }
        }
        return max;
}
