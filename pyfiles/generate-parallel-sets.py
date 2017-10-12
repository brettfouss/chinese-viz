import sys
import json

def main():

    base_path = sys.argv[1]
    out_path = sys.argv[2]

    mappings = generate_mappings()

    with open(base_path, "r") as infile, open(out_path, "w+") as outfile:
        result = dict()
        data = json.load(infile)
        result["matrix"] = compute_frequencies(data["data"], mappings)
        result["labels"] = get_labels()
        outfile.write(json.dumps(result))

def generate_mappings():
    mappings = list()
    mappings.append(create_mapping("totalStrokes", [(0, 10), (10, 20), (20, 100)]))
    mappings.append(create_mapping("gradeLevel", [(1, 3), (3, 5), (5, 7)])) 
    mappings.append(create_mapping("frequency", [(5, 6), (3, 5), (1, 3)]))
    return mappings

def create_mapping(name, range_pairs):
    mapping = dict()
    mapping["name"] = name
    mapping["ranges"] = range_pairs
    return mapping

def generate_matrix(dim):
    return [[[list() for k in range(0, dim)] for j in range(0, dim)] for i in range(0, dim)]

def getIndex(value, ranges):
    for i, (lower, upper) in enumerate(ranges):
        if int(value) in range(int(lower), int(upper)):
            return i

def compute_frequencies(data, mappings):
    m = generate_matrix(3)
    for character in data:
        indices = [-1, -1, -1]
        for z, mapping in enumerate(mappings):
            indices[z] = getIndex(character[mapping["name"]], mapping["ranges"])
        i = indices[0]
        j = indices[1]
        k = indices[2]
        m[i][j][k].append(character)
    return m

def get_labels():
    i = dict()
    j = dict()
    k = dict()
    i["name"] = "kTotalStrokes"
    i["label"] = "STROKE COUNT"
    i["sets"] = ["LOW", "MEDIUM", "HIGH"]
    j["name"] = "kGradeLevel"
    j["label"] = "GRADE LEVEL"
    j["description"] = "The primary grade in the Hong Kong school system by which a student is expected to know the character."
    j["sets"] = ["PRIMARY 1 OR 2", "PRIMARY 3 OR 4", "PRIMARY 5 OR 6"]
    k["name"] = "kFrequency"
    k["label"] = "FREQUENCY OF USE"
    k["sets"] = ["UNCOMMON", "SOMEWHAT COMMON", "VERY COMMON"]
    return [i, j, k]

if __name__ == "__main__":
    main()
