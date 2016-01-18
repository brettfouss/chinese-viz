import csv

CIHAN_PATH = '../cihaidata-unihan/data/unihan.csv'
OUT_PATH   = 'out.csv'

# Indices of all useful data
UCN         = 0
CHAR        = 1
DEFINITION  = 15
FREQUENCY   = 20
GRADE_LEVEL = 28
MANDARIN    = 65
STROKES     = 86 

class Character: 
        def __init__ (self, ucn, char, definition,
                        frequency, grade, pinyin,
                        mandarin, strokes):
                self._ucn    = ucn
                self._char   = char
                self._def    = definition
                self._freq   = frequency
                self._grade  = grade
                self._mand   = mandarin
                self._stroke = strokes

f = open(CIHAN_PATH)
csv_f = csv.reader(f)

first_row = ''
char_list = list()

def isComplete(char):
    complete = True
    for field in char: 
        complete = complete and (field != '')
    return complete

# read and process CSV file
first = True 
for row in csv_f:

        this_c = list()    
        # this_c.append(row[UCN]) 
        this_c.append(row[CHAR])
        # this_c.append(row[DEFINITION])
        this_c.append(row[FREQUENCY])
        this_c.append(row[GRADE_LEVEL])
        # this_c.append(row[MANDARIN])
        this_c.append(row[STROKES])

        if (first == True):
                first = False                
                first_row = this_c
        else:
                if (isComplete(this_c) == True):
                        char_list.append(this_c)
        char_list = sorted(char_list, key=lambda char : (int(char[2]), int(char[3]), int(char[1])))
 
# write new csv file
with open(OUT_PATH, 'wb') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(first_row)
        for c in char_list:
                writer.writerow(c)

f.close()
