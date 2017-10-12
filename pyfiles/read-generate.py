import sys, os
import random
import json

UNIHAN_RSCOUNTS_FILE = "Unihan_RadicalStrokeCounts.txt"
UNIHAN_READINGS_FILE = "Unihan_Readings.txt"
UNIHAN_DICTIONARYLIKEDATA_FILE = "Unihan_DictionaryLikeData.txt"
UNIHAN_VARIANTS_FILE = "Unihan_Variants.txt"

RADICAL_MIN = 12032
RADICAL_MAX = 12245

CHARACTER_MIN = 19968
CHARACTER_MAX = 40938 

def main():

    base_path = sys.argv[1]
    out_path = sys.argv[2]
    
    data = dict()
    radicals = [chr(i) for i in range(RADICAL_MIN, RADICAL_MAX + 1)]
    characters = [chr(i) for i in range(CHARACTER_MIN, CHARACTER_MAX + 1)]
    data["radicals"] = radicals
    data["characters"] = characters
    data["data"] = list()

    # note: "characters" variable is a list passed by reference here, and extractData will
    # remove characters from it if it doesn't find any data on that character. This is to
    # ensure a complete data set. 
    definitions_of_characters = extractData(base_path, UNIHAN_READINGS_FILE, characters, "kDefinition")
    pinyin_of_characters = extractData(base_path, UNIHAN_READINGS_FILE, characters, "kMandarin")
    rskangxi_of_characters = extractData(base_path, UNIHAN_RSCOUNTS_FILE, characters, "kRSKangXi")
    frequency_of_characters = extractData(base_path, UNIHAN_DICTIONARYLIKEDATA_FILE, characters, "kFrequency")
    grade_level_of_characters = extractData(base_path, UNIHAN_DICTIONARYLIKEDATA_FILE, characters, "kGradeLevel")
    total_strokes_of_characters = extractData(base_path, UNIHAN_DICTIONARYLIKEDATA_FILE, characters, "kTotalStrokes")

    # don't throw away any characters for this one.
    # "simplified variant" is only listed if the traditional character differs from the simplified.
    characters_copy = list(characters)
    simplified_variants_of_characters = extractData(base_path, UNIHAN_VARIANTS_FILE, characters_copy, "kSimplifiedVariant")

    for character in characters:
        c = dict()
        c["character"] = character
        c["definition"] = definitions_of_characters[character]
        c["pinyin"] = pinyin_of_characters[character]
        c["radical"] = rskangxi_to_radical(rskangxi_of_characters[character], radicals)
        c["frequency"] = frequency_of_characters[character]
        c["gradeLevel"] = grade_level_of_characters[character]
        c["totalStrokes"] = total_strokes_of_characters[character]
        c["simplified"] = simplified_variants_of_characters[character] if character in simplified_variants_of_characters else character
        data["data"].append(c)

    print("writing", out_path)
    with open(out_path, "w") as outfile:
        outfile.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))

def rskangxi_to_radical(rs, radicals):
    return radicals[int(rs.split(".")[0]) - 1]

def extractData(path, f, characters, key):
    result = dict()
    with open(path + os.sep + f, "r") as infile:
        lines = [line.rstrip("\n").split("\t") for line in infile.readlines() if key in line]
        lines = [line for line in lines if len(line) == 3]
        character_data = [chr(int(x[0][2:], 16)) for x in lines]
        data = [x[2] for x in lines]
        total = len(data)
        for (c, d) in zip(character_data, data):
            if c in characters:
                result[c] = d
        unknown = [char for char in characters if char not in result]
        for char in unknown:
            characters.remove(char)
        k = random.randint(0, len(characters) - 1)
        print("==== done getting", key, "for each character ====")
        print("saved", len(result), "- for example", characters[k], "has", key, result[characters[k]]) 
        print("passed on", total - len(result), "unknown or obscure characters") 
        print("discarded", len(unknown), "characters from original set (maybe because they were simplified)") 
        print("now our data set has", len(characters), "characters")
        print("")
        return result

if __name__ == "__main__":
    main()
