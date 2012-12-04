#! /usr/bin/ruby

require_relative 'Grafo.rb'

class AG

  attr_accessor :cant_pob, :matting_pool, :poblacion, :hijos, :aptitudes, :num_nodos
  
  def initialize(cant_pob,num_nodos)
    @num_nodos=num_nodos
    cant_pob.times{ |i|
      @poblacion[i] = Grafo.new(@num_nodos)
    }
    
  end

  def calcular_aptitud

    max=0

    @poblacion.each{|indi|
      max= max + indi.aptitud
    }

    @poblacion.each{|grafo|
      @aptitudes.push(grafo.aptitud.to_f / max )
    }

  end
  
  def seleccion    
    
    25.times{|i|
      valor= rand()
      @aptitudes.each_index{|j|
        if j==0
          if valor<@aptitudes[j]
            @matting_pool.push(@poblacion[j])
            break
          end
          
        else
          if valor >= @aptitudes[j-1] and valor < @aptitudes[j]
            @matting_pool.push(@poblacion[j])
            break
          end
           
        end    
      }
      
    }
    
  end
  
  def reproduccion
    i=0
    while i<25
      if rand()<0.60
        grafos_hijos=cruce(@matting_pool[rand(25)],@matting_pool[rand(25)])
        
        if rand()<0.05
          grafos_hijos[0]=mutacion(grafos_hijos[0])
        end
        if rand()<0.05
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
    
  end
  
  def cruce (grafo1, grafo2)
    
    point = 7-rand(7)
    
    cromo_1=grafo1.cromosoma[0..point].concat(grafo2.cromosoma[(point+1)..7])
    cromo_2=grafo2.cromosoma[0..point].concat(grafo1.cromosoma[(point+1)..7])      
      
    return [Grafo.new(@num_nodos,cromo1),Grafo.new(@num_nodos,cromo2)]  
    
    
  end
  
  def mutacion (grafo) 
    
    cromosoma=grafo.cromosoma
    cromosoma[rand(7)]=rand(2)
    grafo.cromosoma(cromosoma)
    
    return grafo
  end
  
  def reemplazo
    
  end

end