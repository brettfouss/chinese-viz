import csv

CEDICT_PATH = '../cedict/cedict.txt'
OUT_PATH    = 'dict.csv'

with open(CEDICT_PATH, 'r') as f:
    with open(OUT_PATH, 'wb') as outfile:
        writer = csv.writer(outfile)
        for line in f:
            outfile.write(line.split(' ', 1)[-1])
