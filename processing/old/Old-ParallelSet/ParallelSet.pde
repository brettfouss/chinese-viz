String PATH_1 = "../data/stroke-grade-freq.csv";
String PATH_2 = "../data/grade-freq-stroke.csv";

int smajorstrokes[];
int smajorlevels[];
int smajorstrokemax = 0;
int smajorlevelmax  = 0;
int smajortotalval  = 0;

int lmajorstrokes[];
int lmajorlevels[];
int lmajorstrokemax = 0;
int lmajorlevelmax  = 0;
int lmajortotalval  = 0;

int strokesvslevels[][];

float sxs[];

int   lID[];  
float lxs[];

int   fID[];
float fxs[];

/* Display Constants */
float MARGIN = 20.0;
float PADDING = 0.1;
float SLICE_WIDTH = 50.0;

void setup() {
        size(800, 600);
        surface.setResizable(true);
        parse();
        mapStrokesLevels();
}

void draw() {

        background(236, 240, 241);

        float originy = (height - MARGIN - (height * PADDING));

        float set1originx = (MARGIN + (width * PADDING));
        float set1originy = (MARGIN + (height * PADDING));
        float set1rightx  = (width - MARGIN - (width * PADDING));

        float set2originx = set1originx;
        float set2originy = (((MARGIN + (width * PADDING)) + originy) / 2);
        float set2rightx  = set1rightx;

        drawSetOne(set1originx, set1originy, set1rightx);
        drawSetTwo(set2originx, set2originy, set2rightx);
        linkOneTwo(set1originy, set2originy);

}

void parse() {

        String lines[]   = loadStrings(PATH_1);
        String headers[] = split(lines[0], ",");

        smajorstrokes   = new int[lines.length - 1];
        smajorlevels    = new int[lines.length - 1];
        smajortotalval = lines.length - 1;

        for (int i = 1; i < lines.length; i++) {
                String row[] = split(lines[i], ",");
                smajorstrokes[i - 1] = parseInt(row[3]);
                smajorlevels[i - 1]  = parseInt(row[2]);
        }

        String maxRow[] = split(lines[lines.length - 1], ",");
        smajorstrokemax = parseInt(maxRow[3]);
        smajorlevelmax  = parseInt(maxRow[2]);

        lines   = loadStrings(PATH_2);
        headers = split(lines[0], ",");

        lmajorstrokes   = new int[lines.length - 1];
        lmajorlevels    = new int[lines.length - 1];
        lmajortotalval = lines.length - 1;

        for (int i = 1; i < lines.length; i++) {
                String row[] = split(lines[i], ",");
                lmajorstrokes[i - 1] = parseInt(row[3]);
                lmajorlevels[i - 1]  = parseInt(row[2]);
        }

        maxRow = split(lines[lines.length - 1], ",");
        lmajorstrokemax = parseInt(maxRow[3]);
        lmajorlevelmax  = parseInt(maxRow[2]);

}

void mapStrokesLevels() {

        // Count major categories
        int numMajor = 1;
        strokesvslevel = new int[6][6];

        boolean broken = false;
        int subi = 0;
        int subj = 0;
        for (int i = 0; i < smajorstrokes.length; i++) {
                int val = smajorstrokes[i];
                if (i == 0 || ((val % 5) && !broken)) {

                        int count = 0;
                        int temp  = i;
                        int limit = smajorstrokes[i] + 5;
                        while ((smajorstrokes[temp] < limit) && 
                                (temp < smajorstrokes.length)) {
                                subj = 
                                count++;
                                temp++;
                        }

                }
        }

}

void drawSetOne(float originx, float originy, float rightx) {
        
        float sectionx = ((rightx - originx) / smajortotalval);
        float tempx = originx;
        boolean broken = false;

        strokeWeight(1);
        strokeCap(SQUARE);

        int diff = 5;

        sxs = new float[6];
        sxs[0] = tempx; 

        int subindex = 1;

        for (int i = 0; i < smajorstrokes.length; i++) {
                int val = smajorstrokes[i];
                if ((val % 5) == 0 && !broken) { 
                        broken = true;
                        tempx  = tempx + 4.0;
                        line(tempx, originy, tempx + sectionx, originy);
                        sxs[subindex] = val;
                        subindex++;
                } else if ((val % 5) == 0) {
                        line(tempx, originy, tempx + sectionx, originy);
                } else  {
                        broken = false;
                        line(tempx, originy, tempx + sectionx, originy);
                }
                tempx = tempx + sectionx;
        }

}

void drawSetTwo(float originx, float originy, float rightx) {
 
        float sectionx = ((rightx - originx) / smajortotalval);
        float tempx = originx;

        strokeWeight(1);
        strokeCap(SQUARE);

        int diff = 5;
        int lastval = lmajorlevels[0];

        int numUnique = 1;

        for (int i = 0; i < lmajorlevels.length; i++) {
                int val = lmajorlevels[i];
                if (val == lastval) {
                        line(tempx, originy, tempx + sectionx, originy);
                } else  {
                        tempx  = tempx + 4.0;
                        lastval = val;
                        line(tempx, originy, tempx + sectionx, originy);
                        numUnique++;
                }
                tempx = tempx + sectionx;
        }

        lID = new int[numUnique];
        lxs = new float[numUnique];

        tempx = originx;
        lastval = lmajorlevels[0];
        int subindex = 1;

        lID[0] = lmajorlevels[0];
        lxs[0] = tempx;

        for (int i = 0; i < lmajorlevels.length; i++) {
                int val = lmajorlevels[i];
                if (val != lastval) {
                        tempx = tempx + 4.0;
                        lID[subindex] = val;
                        lxs[subindex] = tempx;
                        subindex++;
                        lastval = val;
                } 
                tempx = tempx + sectionx;
        }
}

void linkOneTwo(float set1originy, float set2originy) {
}












// int alpha = (int)(255 - ((float)val/(float)smajorstrokemax));



