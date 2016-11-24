import random

class rudolph(object):
    def __init__(self,nodes,exclusions=[],excluded_pairs=[]):
        self.nodes = range(nodes)
        self.exclusions = exclusions #directional list of exclusions
#NOTE: Because exclusions only go one direction
# annual exlusion lists need to loop: [A,B,C,D,A]
        self.excluded_pairs = excluded_pairs #bidirectional pairs of exclusions
        self.layer_exclusions = [None]*5
        self.path = []
        self.goback = 0
        self.max_goback = nodes**2
    
    def prune(self):
        path = list(self.path)
        nodes = list(self.nodes)
        return self.prune_t(path,nodes)
        
    def prune_t(self,path,nodes):
        if len(path) == 0:
            return nodes
        else:
            last = path[-1]
            for exclusion in self.exclusions:
                if last in exclusion
                    remindex = (exclusion.index(last)+1) % len(exclusion)
                    rem = exclusion[remindex]
                    if rem in nodes:
                         nodes.remove(rem)
            for exclusion in self.excluded_pairs:
                if last in exclusion:
                    remindex = (exclusion.index(last)-1) % len(exclusion)
                    rem = exclusion[remindex]
                    if rem in nodes:
                        nodes.remove(rem)
            if path.layer_exclusions[len(self.path)] is None:
                path.layer_exclusions[len(self.path)] = []
            for exclusion in path.layer_exclusions[len(self.path)]:
                if last == exclusion[0] and exclusion[1] in nodes:
                    nodes.remove(exclusion[1])
        return nodes
        
    def go_back(self):
        self.goback += 1
        if self.goback >= self.max_goback:
            raise Exception("Too many gobacks")
        if layer_exclusions[len(self.path)-1] is None:
            layer_exclusions[len(self.path)-1] = []
        layer_exclusions[len(self.path)-1].append([self.path[-2],self.path[-1]])
        while [self.path[-2],self.path[-1]] in layer_exclusions[len(self.path)-1]
            santa = self.path.pop()
            self.nodes.append(santa)
        
    def gen_level(self):
        vnodes = self.prune()
        while len(vnodes) == 0:
           self.go_back()
           vnodes = self.prune()
        chimney = random.choice(vnodes)
        self.path.append(chimney)
        self.nodes.remove(chimney)
        if len(self.nodes) == 0:
            #TEST LAST LEVEL
            self.nodes.append(self.path[0])
            valid_path = len(self.prune()) != 0
            self.nodes.pop()
            if not valid_path:
                self.go_back()

    def gen_list(self):
        self.path.append(self.nodes.remove(0))
        while len(self.nodes) > 0:
            self.gen_level()
        return self.path

if __name__ == '__main__':
    r = rudolph(10,[[6, 2, 9, 3, 5, 4, 1, 0, 7, 8,6],[4, 2, 3, 7, 9, 5, 1, 6, 0, 8,4]])
    print r.gen_list()