class Rudolph
    def initialize (nodes, exclusions, excluded_pairs)
        @nodes = (0..(nodes-1)).to_a()
        @exclusions = exclusions
        @excluded_pairs = excluded_pairs
        @layer_exclusions = Array.new(nodes,nil)
        @path = []
        @goback = 0
        @max_goback = nodes**2
    end
    
    def prune()
        path = Array.new(@path)
        nodes = Array.new(@nodes)
        return prune_t(path,nodes)
    end
        
    def prune_t(path,nodes)    
        if path.length == 0 
            return nodes
        else
            last = path[-1]
            for exclusion in @exclusions
                if exclusion.include?(last)
                    # assumes every exclusions list is a loop
                    remindex = (exclusion.index(last) + 1) % exclusion.length
                    rem = exclusion[remindex]
                    puts " Excluding #{rem} because #{last}"
                    if nodes.include?(rem)
                        nodes.delete(rem)
                    end
                end
            end
            for exclusion in @excluded_pairs
                if exclusion.include?(last) 
                    remindex = (exclusion.index(last) - 1) % exclusion.length
                    if nodes.include?(rem)
                        nodes.delete(rem)
                    end
                end
            end
            for exclusion in (@layer_exclusions[@path.length] ||= [])
                if last == exclusion[0] and nodes.include?(exclusion[1])
                    puts " Level exclusion #{exclusion} because #{last}"
                    nodes.delete(exclusion[1])
                end
            end
        end
        return nodes
    end
    
    def go_back 
        #add to the goback counter
        @goback += 1
        #debug
        puts " <- Go back #{@goback}"
        #failout after too many gobacks
        if @goback == @max_goback or (@layer_exclusions[0] ||= [])[0] == [[nil,0],[nil,0]]
            raise 'Too many gobacks'
        end
        #Add the latest failure edge to the failure tree
        (@layer_exclusions[@path.length()-1] ||= []).push([@path[-2],@path[-1]])
        #Go back until path contains no failure edges
        while (@layer_exclusions[@path.length()-1] ||= []).include?([@path[-2],@path[-1]]) and not @path[-2] == nil
            @nodes.push(@path.pop())
        end 
        #debug
        puts "  #{@layer_exclusions}"
        puts "  #{@path}"
    end
    
    def gen_level 
        vnodes = prune()
        puts "Gen level #{@path.length} from #{@path[-1]} to #{vnodes}"
        while vnodes.length == 0
            #if @path.length == 1
            #    #FIXME: is this right?
            #    raise 'No valid path found'
            #end
            go_back()
            vnodes = prune()
        end
        chimney = vnodes.sample
        @path.push(@nodes.delete(chimney))
        if @nodes.length() == 0
            #TEST LAST level
            #add value of first level to nodes
            @nodes.push(@path[0])
            #see if that node would be pruned
            valid_path = prune().length() != 0
            #remove the value
            @nodes.pop()
            #if the path isn't valid, go back
            if not valid_path
                go_back()
            end
        end
    end
    
    
    def gen_list 
        @path.push(@nodes.delete(0))
        while @nodes.length > 0
            gen_level()
        end
        return @path
    end
end

if __FILE__ == $0
    r = Rudolph.new(10,[[0,1,2,3,4,5,6,7,8,9],[0,6,8,2,9,7,4,1,3,5]],[])
    puts "#{r.gen_list()}"
end