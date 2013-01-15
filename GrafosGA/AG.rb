#! /usr/bin/ruby

require 'Grafo.rb'

class AG

  attr_accessor :cant_pob, :matting_pool, :poblacion, :hijos, :aptitudes, :num_nodos, :mejor
  def initialize(cant_pob,num_nodos)
    @poblacion=[]

    @num_nodos=num_nodos
    cant_pob.times{ |i|
      @poblacion.push(Grafo.new(@num_nodos))
    }    
  end

  def calcular_aptitud
    puts "calculando max aptitud"
    max=0
    @aptitudes=[]
    @poblacion.each{|indi|
      max= max + indi.aptitud
    }
    
    puts "maxima aptitud #{max}"

    @poblacion.each{|grafo|
      @aptitudes.push(grafo.aptitud.to_f / max.to_f )
    }
    puts @aptitudes.inspect
    @mejor=@aptitudes.max
    puts "done"
  end

  def seleccion
    puts "proceso de seleccion"
    @matting_pool=[]
    25.times{|i|
      valor= rand()
      @aptitudes.each_index{|j|
        if j==0
          if valor<@aptitudes[j]
            @matting_pool.push(@poblacion[j])
            break
          end

        else
          if valor >= @aptitudes[j-1] #and valor < @aptitudes[j]
            @matting_pool.push(@poblacion[j])
            break
          end

        end
      }

    }
    puts "done"
  end

  def reproduccion
    puts "reproduccion"
    @hijos=[]
    i=0
    while i<25
      if rand()<0.60
        grafos_hijos=cruce(@matting_pool[rand(25)],@matting_pool[rand(25)])

        @hijos.push(grafos_hijos[0])
        @hijos.push(grafos_hijos[1])

      else

        @hijos.push(@matting_pool[rand(25)])
        @hijos.push(@matting_pool[rand(25)])

      end
      i+=2
    end
    puts "cantidad de hijos #{@hijos.size}"
    puts "done"
  end

  def cruce (grafo1, grafo2)
    puts "cruce"
    point = 7-rand(7)

    cromo_1=grafo1.cromosoma[0..point].concat(grafo2.cromosoma[(point+1)..7])
    cromo_2=grafo2.cromosoma[0..point].concat(grafo1.cromosoma[(point+1)..7])

    if rand()<0.1
      cromo_1=mutacion(cromo_1)
    end
    if rand()<0.1
      cromo_2=mutacion(cromo_2)
    end

    return [Grafo.new(@num_nodos,cromo_1),Grafo.new(@num_nodos,cromo_2)]

    puts "done"
  end

  def mutacion (cromosoma)
    puts "mutacion"

    puts "cromosoma normal #{cromosoma.inspect}"
    point = rand(7)

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
    index_hijos=0
    @poblacion.each_index{|index|
      if index_hijos < 25
        if @poblacion[index].aptitud == 0 or @poblacion[index].aptitud < @hijos[index_hijos].aptitud
          @poblacion[index]=@hijos[index_hijos]
          index_hijos+=1
          puts "reemplazo.. #{@poblacion[index].aptitud} por ... #{@hijos[index_hijos].aptitud}"
        end
      else
        break
      end
    }

    puts "done"
  end

  def evolucion
    #puts "aptitudes antes de evolucionar #{@aptitudes.inspect}"
    calcular_aptitud()
    seleccion()
    reproduccion()
    reemplazo()
        
  end

end