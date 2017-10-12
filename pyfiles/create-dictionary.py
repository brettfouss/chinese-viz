import sys
import re
import json

def main():

    base_path = sys.argv[1]
    out_path = sys.argv[2]
    
    data = dict();

    with open(base_path, "r") as infile:
        for line in infile.readlines():
            words = line.split(" ")[0].decode("utf-8")
            definition = re.search(r"/(.*?)/", line).group(1)
            if (len(words) == 2):
                data[words] = definition

    with open(out_path, "w") as outfile:
        outfile.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))

if __name__ == "__main__":
    main()
