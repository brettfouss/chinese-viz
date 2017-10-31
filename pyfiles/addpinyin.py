import json

with open("../static/chinese-vis-data.json") as f, open("data/unihan.json") as wordfile:
    data = json.load(f)
    worddata = json.load(wordfile)
    words = dict()
    for word in worddata["data"]:
        words[word["character"]] = word["pinyin"]
    for word in data["node-link"]:
        chars = word["name"]
        if (word["type"] == "radical"):
            word["pinyin"] = "radical"
        elif (len(chars) == 1):
            if chars in words:
                word["pinyin"] = words[chars]
            else: s += "(missing data)"
        elif (len(chars) == 2):
            s = ""
            if chars[0] in words:
                s += words[chars[0]]
            else: s += "(missing data)"
            if chars[1] in words:
                s += words[chars[1]]
            else: s += "(missing data)"
            word["pinyin"] = s 
    with open("out.json", "w+") as outfile:
        outfile.write(json.dumps(data, separators=(',', ': ')))
