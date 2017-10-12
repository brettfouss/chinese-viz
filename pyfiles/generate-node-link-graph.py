import sys
import json

def main():

    assert(len(sys.argv) == 4)

    words_path = sys.argv[1]
    dict_path = sys.argv[2]
    out_path = sys.argv[3]

    characters = None
    radicals = None
    compound_words = None
    cdata = None

    with open(words_path, "r") as wordsfile, open(dict_path, "r") as dictfile:
        words = json.load(wordsfile)
        characters = words["characters"]
        radicals = words["radicals"]
        cdata = create_lookup_table(words["data"], "character")
        compound_words = json.load(dictfile)

    (nodes, lookup) = create_nodes(radicals, characters, compound_words, cdata)

    nodes = find_neighborhoods(nodes, lookup)

    with open(out_path, "w+") as outfile:
        outfile.write(json.dumps(nodes)) 

def create_lookup_table(data, key):
    lookup = dict()
    for datum in data:
        lookup[datum[key]] = datum
    return lookup

def find_neighborhoods(nodes, lookup):
    for node in nodes:
        node["neighborhood"] = list()
    for i, node in enumerate(nodes):
        if node["type"] == "character":
            radical_index = lookup[node["radical"]]
            node["neighborhood"].append(radical_index)
            nodes[radical_index]["neighborhood"].append(i)
        if node["type"] == "compound_word":
            for c in node["name"]:
                if c in lookup:
                    char_index = lookup[c]
                    node["neighborhood"].append(char_index)
                    nodes[char_index]["neighborhood"].append(i)
    return nodes 

def create_nodes(radicals, characters, compound_words, cdata):
    nodes = list()
    lookup = dict()
    for i, radical in enumerate(radicals):
        node = dict()
        node["type"] = "radical"
        node["id"] = i
        node["name"] = radical 
        node["definition"] = "Radical " + str(i)
        nodes.append(node)
        lookup[radical] = i
    for i, character in enumerate(characters):
        node = dict()
        node["type"] = "character"
        node["id"] = len(nodes)
        node["name"] = character 
        node["definition"] = cdata[character]["definition"]
        node["radical"] = cdata[character]["radical"]
        nodes.append(node)
        lookup[character] = node["id"]
    for i, cw in enumerate(compound_words):
        if cw[0] in characters or cw[1] in characters:
            node = dict()
            node["type"] = "compound_word"
            node["id"] = len(nodes)
            node["name"] = cw
            node["definition"] = compound_words[cw]
            nodes.append(node)
            lookup[cw] = node["id"]
    return (nodes, lookup)

if __name__ == "__main__":
    main()
