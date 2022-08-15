import json
import math
#you need to add you path here
with open('movie.json','r', encoding='utf8') as m:
    data = json.load(m)
    print(len(data['movie'])) #total 9995 movies
    partition = 8
    size_of_the_split = math.ceil(len(data['movie'])/partition)
    print(size_of_the_split) #1250
    for i in range(partition):
        json.dump(data['movie'][i * size_of_the_split:(i + 1) * size_of_the_split], open(
            "movie_Split_" + str(i+1) + ".json", 'w',
            encoding='utf8'), ensure_ascii=False, indent=True)