#! /usr/bin/ruby

require 'Grafo.rb'

class AG

  attr_accessor :cant_pob, :matting_pool, :poblacion, :hijos, :aptitudes, :num_nodos
  
  def initialize(cant_pob,num_nodos)
    @poblacion=[]
    @matting_pool=[]
    @hijos=[]
             
    @num_nodos=num_nodos
    cant_pob.times{ |i|
      @poblacion.push(Grafo.new(@num_nodos))
    }
    calcular_aptitud
  end

  def calcular_aptitud
    puts "calculando max aptitud"
    max=0
    @aptitudes=[] 
    @poblacion.each{|indi|
      puts "#{indi}"
      max= max + indi.aptitud
    }
    puts "maxima aptitud #{max}"

    @poblacion.each{|grafo|
      @aptitudes.push(grafo.aptitud.to_f / max.to_f )
    }
    puts @aptitudes.inspect
    puts "done"
  end
  
  def seleccion    
    puts "proceso de seleccion"
    25.times{|i|
      valor= rand()
      puts "valor aleatorio #{valor}"
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
    puts "tamanio del matting pool #{@matting_pool.size}"
    puts "done"
  end
  
  def reproduccion
    puts "reproduccion"
    
    i=0
    while i<25
      if rand()<0.60
        grafos_hijos=cruce(@matting_pool[rand(25)],@matting_pool[rand(25)])
        
        if rand()<0.1
          grafos_hijos[0]=mutacion(grafos_hijos[0])
        end
        if rand()<0.1
          grafos_hijos[1]=mutacion(grafos_hijos[1])
        end
        
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
      
    return [Grafo.new(@num_nodos,cromo_1),Grafo.new(@num_nodos,cromo_2)]  
    
    puts "done"
  end
  
  def mutacion (grafo) 
    puts "mutacion"
    cromosoma=grafo.cromosoma
    puts "cromosoma normal #{cromosoma.inspect}"
    cromosoma[rand(7)]=rand(2)
    puts "cromosoma mutado #{cromosoma.inspect}"
    grafo.mutar_cromosoma(cromosoma)
    
    puts "done"
    return grafo
    
    
  end
  
  def reemplazo
    puts "reemplazo"
    @hijos.each{|hijo_grafo|
      @poblacion[rand(@cant_pob)]=hijo_grafo
    }
    puts "done"
  end
  
  def evolucion
    puts "aptitudes antes de evolucionar #{@aptitudes.inspect}"
    seleccion()
    reproduccion()
    reemplazo()
    calcular_aptitud()
    puts "aptitudes despues de evolucionar #{@aptitudes.inspect}"
  end

end