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

#  def calcular_aptitud2
#    puts "calculando max aptitud"
#    max=0
#    @aptitudes=[]
#    @poblacion.each{|indi|
#      max= max + indi.aptitud
#    }
#    
#    puts "maxima aptitud #{max}"
#
#    @poblacion.each{|grafo|
#      @aptitudes.push(grafo.aptitud.to_f / max.to_f )
#    }
#    puts @aptitudes.inspect
#    @mejor=@aptitudes.max
#    puts "done"
#  end
  
  def calcular_aptitud
    #entre mas ceros haya mejor es el individuo
    @aptitudes=[]
    @poblacion.each{|grafo|
      per_zeros=grafo.aptitud.count(0).to_f/grafo.aptitud.count
      per_ones=grafo.aptitud.count(1).to_f/grafo.aptitud.count
      
      if per_ones>0.35 and per_ones < 0.65 and per_ones>per_zeros
        @aptitudes.push(per_ones)
      else  
        @aptitudes.push(per_zeros)
      end      
    }
    puts @aptitudes.inspect
  end
  
  

#  def seleccion2
#    puts "proceso de seleccion"
#    @matting_pool=[]
#    25.times{|i|
#      valor= rand()
#      @aptitudes.each_index{|j|
#        if j==0
#          if valor<@aptitudes[j]
#            @matting_pool.push(@poblacion[j])
#            break
#          end
#
#        else
#          if valor >= @aptitudes[j-1] #and valor < @aptitudes[j]
#            @matting_pool.push(@poblacion[j])
#            break
#          end
#
#        end
#      }
#
#    }
#    puts "done"
#  end
  
  #3 individuos aleatorios y selecciono el de mayor aptitud
  
def seleccion
  puts "proceso de seleccion"
  @matting_pool=[]
  factibles=[]  
  
      
##  @poblacion.each{|grafo|
##    if grafo.aptitud !=0
##      factibles.push(grafo)
##    end
##  }  
#    
#  @mejor=@poblacion.max{|a,b|
#    a.aptitud <=> b.aptitud
#  } 
#  @matting_pool.push(@mejor) 
#  25.times{|i|
#    ind1=@poblacion[rand(@cant_pob)]
#    ind2=@poblacion[rand(@cant_pob)] 
#    
#    if ind1.aptitud > ind2.aptitud 
#      @matting_pool.push(ind1)
#    else      
#      @matting_pool.push(ind2)      
#    end    
#  }
    
  #@mejor=@poblacion.max{|a,b|
  #    a.aptitud <=> b.aptitud
  #  }   
  
  
  @aptitudes.each_index{|i|
    if @aptitudes[i]>0
      @matting_pool.push(@poblacion[i])
    end
  }
  
  
  n=26-@matting_pool.count
  if @matting_pool.count <= 26    
  n.times{
    al1=rand(@cant_pob)
    al2=rand(@cant_pob)
    
    if @aptitudes[al1] > @aptitudes[al2]
      @matting_pool.push(@poblacion[al1])
    else
      @matting_pool.push(@poblacion[al2])
    end
  }
  end  
    
    
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
  
  
  #drop_while
  def reemplazo
    puts "reemplazo"
       
    index_hijos=0
#    @poblacion.each_index{|index|
#      if index_hijos < 25
#        if @poblacion[index].aptitud < 5 or @poblacion[index].aptitud < @hijos[index_hijos].aptitud
#          @poblacion[index]=@hijos[index_hijos]
#          index_hijos+=1
#          puts "reemplazo.. #{@poblacion[index].aptitud} por ... #{@hijos[index_hijos].aptitud}"
#        end      
#      end
#    }
    
    apt_hijos=[]
        @hijos.each{|hijo|
          per_zeros=hijo.aptitud.count(0).to_f/hijo.aptitud.count
                per_ones=hijo.aptitud.count(1).to_f/hijo.aptitud.count
                
                if per_ones>0.35 and per_ones>per_zeros
                  apt_hijos.push(per_ones)
                else  
                  apt_hijos.push(per_zeros)
                end         
        }
    puts apt_hijos.inspect
    puts @aptitudes.inspect
    
    @aptitudes.each_index{|index|
          if index_hijos < 25
            if @aptitudes[index] == 0 or @aptitudes[index] < apt_hijos[index_hijos]
              @poblacion[index]=@hijos[index_hijos]
              @aptitudes[index]=apt_hijos[index_hijos]
              index_hijos+=1
              puts "reemplazo.. #{@aptitudes[index]} por ... #{apt_hijos[index_hijos]}"
            end      
          end
        }
    
    puts @aptitudes.inspect
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