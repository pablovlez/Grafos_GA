#! /usr/bin/ruby

require 'GraphEvo.rb'
require 'GraphRand.rb'

class AG

  attr_accessor :cant_pob, :matting_pool, :poblacion, :hijos, :aptitudes, :num_nodos, :mejor,:clase
  def initialize(cant_pob,num_nodos,clase)

    @clase=clase
    @poblacion=[]

    @num_nodos=num_nodos
    if @clase==0 then
      cant_pob.times{ |i|
        @poblacion.push(GraphEvo.new(@num_nodos))
        puts i
      }
    else
      cant_pob.times{ |i|
        @poblacion.push(GraphRand.new(@num_nodos))
      }
    end

  end
  
  def set_aptitudes
    @aptitudes=[]
    @poblacion.each{|graph|
      @aptitudes.push(graph.aptitud)
    }
      
  end 

  def seleccion
    puts "proceso de seleccion"
    @matting_pool=[]
    26.times{
      al1=rand(@cant_pob)
      al2=rand(@cant_pob)
      if @poblacion[al1].aptitud < @poblacion[al2].aptitud
        @matting_pool.push(@poblacion[al1])
      else
        @matting_pool.push(@poblacion[al2])
      end
    }
    puts "done"
  end

  def reproduccion
    puts "reproduccion"
    @hijos=[]
    i=0
    while i<25
      if rand()<0.60

        #grafos_hijos=cruce(@matting_pool[rand(25)],@matting_pool[rand(25)])
        #cambio
        grafos_hijos=cruce(@matting_pool[i],@matting_pool[i+1])
        @hijos.push(grafos_hijos[0])
        @hijos.push(grafos_hijos[1])

      else

        @hijos.push(@matting_pool[i])
        @hijos.push(@matting_pool[i+1])

      end
      i+=2
    end
    puts "cantidad de hijos #{@hijos.size}"
    puts "done"
  end

  def cruce (grafo1, grafo2)
    puts "cruce"
    point = 7-rand(7)
    #cruce
    cromo_1=grafo1.cromosoma[0..point].concat(grafo2.cromosoma[(point+1)..7])
    cromo_2=grafo2.cromosoma[0..point].concat(grafo1.cromosoma[(point+1)..7])

    #mutacion
    if rand()<0.1
      cromo_1=mutacion(cromo_1)
    end
    if rand()<0.1
      cromo_2=mutacion(cromo_2)
    end

    if @clase==0 then
      hijo1=GraphEvo.new(@num_nodos,cromo_1)
      hijo2=GraphEvo.new(@num_nodos,cromo_2)
    else
      hijo1=GraphRand.new(@num_nodos,cromo_1)
      hijo2=GraphRand.new(@num_nodos,cromo_2)
    end

    puts "apitud hijo1 #{hijo1.aptitud} , aptitud hijo2 #{hijo2.aptitud}"
    return [hijo1,hijo2]

    puts "done"
  end

  def mutacion (cromosoma)
    puts "mutacion"

    puts "cromosoma normal #{cromosoma.inspect}"
    point = rand(7)
    #cambio de gen en el cromosoma
    if cromosoma[point]==0
      cromosoma[point]=1
    else
      cromosoma[point]=0
    end

    puts "cromosoma mutado #{cromosoma.inspect}"

    puts "done"
    return cromosoma

  end

  def reemplazo
    puts "reemplazo"    
    @hijos.each{|hijo|
      i=0
      @poblacion.each{|graph|
      
        if hijo.aptitud<graph.aptitud
          @poblacion[i]=hijo
          puts "reemplazo #{graph.aptitud} por #{hijo.aptitud}"
          break
        end
        i+=1
      }
    }
    puts "done"
  end

  def evolucion
    #puts "aptitudes antes de evolucionar #{@aptitudes.inspect}"
    
    seleccion()
    reproduccion()
    reemplazo()
    set_aptitudes()
  end

end