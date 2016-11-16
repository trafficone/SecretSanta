import random

class rudolph(object):
    def __init__(self,nodes,exclusions=[],excluded_pairs=[]):
        self.nodes = range(nodes)
        self.exclusions = exclusions #directional list of exclusions
#NOTE: Because exclusions only go one direction
# annual exlusion lists need to loop: [A,B,C,D,A]
        self.excluded_pairs = excluded_pairs #bidirectional pairs of exclusions
        self.path = []

    def gen_level(self):
        vnodes = self.prune(list(self.path),list(self.nodes))
        while vnodes == []:
           if len(self.path) == 1:
               #FIXME: I don't think this is right
               raise Exception("No valid path found")
           self.exclusions.append([self.path[-2],self.path[-1]])
           self.go_back()
           vnodes = self.prune(list(self.path),list(self.nodes))
        chimney = random.choice(vnodes)
        self.path.append(chimney)
        self.nodes.remove(chimney)

    def go_back(self):
        santa = self.path.pop()
        self.nodes.append(santa)

    def prune(self,path,nodes):
        if path == []:
            return nodes
        else:
            last = path[-1]
            for exclusion in self.exclusions:
                if last not in exclusion or exclusion[-1] == last:
                    continue
                else:
                    rem = exclusion[exclusion.index(last)+1]
                    if rem in nodes:
                         nodes.remove(rem)
            for exclusion in self.excluded_pairs:
                if last not in exclusion:
                    continue
                else:
                    rem = exclusion[exclusion.index(last)-1]
                    if rem in nodes:
                        nodes.remove(rem)
            return nodes
    def gen_list(self):
        while len(self.nodes) > 0:
            self.gen_level()
        return self.path

if __name__ == '__main__':
    r = rudolph(10,[[6, 2, 9, 3, 5, 4, 1, 0, 7, 8,6],[4, 2, 3, 7, 9, 5, 1, 6, 0, 8,4]])
    print r.gen_list()