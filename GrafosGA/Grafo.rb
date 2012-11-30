#! /usr/bin/ruby

require 'rubygems'
require 'igraph'

fsalida=File.new('salida_AG.txt','w')

t = Time.now
#puts t.strftime("%d/%m/%Y %H:%M:%S")

fsalida.puts "Tiempo de inicio #{t.strftime("%d/%m/%Y %H:%M:%S")}"

def crear_grafo (num_nodos)
  t = Time.now
  puts "Tiempo de inicio crear_grafo #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  graph = IGraph::Generate.lattice([num_nodos,num_nodos],false,false,false)

  #eliminamos aristas previamente anadidas por Generate.lattice
  #puts "eliminando aristas por defecto"
  graph.each {|vertex|
    graph.neighbours(vertex,IGraph::ALL).each{ |neighbour|
      if graph.are_connected?(vertex,neighbour)
        graph.delete_edge(vertex,neighbour)
        #puts "Arista eliminada del vertice #{v} al vertice #{n}"
      end
    }
  }
  #puts "done"
t = Time.now
puts "Tiempo de finalizacion crear_grafo #{t.strftime("%d/%m/%Y %H:%M:%S")}"

  return graph
end


def procesar_aristas(graph,cromosoma)
  #puts "procesando aristas"
  t = Time.now
  puts "Tiempo de inicio procesar_aristas #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  n=Math.sqrt(graph.vcount())
  vecinos=[-(n+1),-n,-(n-1),-1,1,(n-1),n,(n+1)] #vecinos de un nodo con ocho vecinos
  #modificado 7 nov, generar el grafo rotando sus cuadrantes
  vecinos_r_1=[5,3,0,6,1,7,4,2]
  vecinos_r_2=[7,6,5,4,3,2,1,0]
  vecinos_r_3=[2,4,7,1,6,0,3,5]

  vertice = n+1
  while vertice<((n*n)-(n+1))

    if vertice % n < (n-(n/2)) and vertice <= ((n*n)-1)/2 #primer cuadrante
      cromosoma.each_index{ |i|
        if cromosoma[i]==1
          graph.add_edge(vertice,vertice+vecinos[i])
          #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
        end
      }
    end

    if vertice % n >= (n-(n/2)) and vertice <= (((n*n)-1)/2) + ((n/2)-1)  #segundo cuadrante
      cromosoma.each_index{ |i|
        if cromosoma[vecinos_r_1[i]]==1
          graph.add_edge(vertice,vertice+vecinos[i])
          #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
        end
      }
    end

    if vertice % n >= (n-(n/2)) and  vertice >= (((n*n)-1)/2)+n and vertice <= ((n*n)-1) - (n+1)  #tercer cuadrante
      cromosoma.each_index{ |i|
        if cromosoma[vecinos_r_2[i]]==1
          graph.add_edge(vertice,vertice+vecinos[i])
          #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
        end
      }
    end

    if vertice >= (((n*n)-1)/2) + ((n/2)-1) + 3 and vertice % n <= (n-(n/2)-1)  #cuarto cuadrante
      cromosoma.each_index{ |i|
        if cromosoma[vecinos_r_3[i]]==1
          graph.add_edge(vertice,vertice+vecinos[i])
          #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
        end
      }
    end

    #aumento de indice
    if vertice % n == (n-2)
      vertice +=3
    else
      vertice += 1
    end

  end

  #puts "done"
  t = Time.now
  #puts t.strftime("%d/%m/%Y %H:%M:%S")
  puts "Tiempo de finalizacion procesar_aristas #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  return graph

end

def iniciar_cromosoma
  cromosoma=[]
  8.times{
    cromosoma.push(rand(2))
  }
  #puts cromosoma.inspect
  return cromosoma
end

def aptitud(graph, fsalida)
  t = Time.now
  #puts t.strftime("%d/%m/%Y %H:%M:%S")
  puts "Tiempo de inicio aptitud #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  n=Math.sqrt(graph.vcount())
  apt=0
  20.times do |iter|
    fsalida.puts "iteracion #{iter}"
    #definimos los nodos a y b aleatoriamente
    nodo_a=rand(n*n)
    nodo_b=rand(n*n)

    fsalida.puts "nodo a #{nodo_a}"
    fsalida.puts "nodo b #{nodo_b}"

    #calculamos el nodo m entre los nodos a y b
    fsalida.puts "calculando nodo medio"
    nodo_m=nil
    graph.get_shortest_paths(nodo_a,[nodo_b],IGraph::ALL).each {|a|
      l=a.size/2
      #puts "Nodo medio #{a[l]}"
      nodo_m=a[l]
    }
    #fsalida.puts "nodos medios encontrados #{nodos_m.size}"
    fsalida.puts "nodo medio #{nodo_m}"
    fsalida.puts "done"

    #calculamos los nodos p
    fsalida.puts "calculando nodos p"

    nodos_p=[]
      iter=((n*n)/10)
      iter=iter.to_int
      iter.times{|i|
      nodo_p=rand(n*n)
      ruta_a_p=graph.get_shortest_paths(nodo_a,[nodo_p],IGraph::ALL)
      ruta_b_p=graph.get_shortest_paths(nodo_b,[nodo_p],IGraph::ALL)

      if ruta_a_p.first.size == ruta_b_p.first.size and ruta_a_p.first.size != 1 and ruta_b_p.first.size!=1 and nodo_p!=nodo_a and nodo_p!=nodo_b

        if nodo_p!=nodo_m and nodo_a!=nodo_m and nodo_b!=nodo_m
          nodos_p.push(nodo_p)

        end
      end
    }
    fsalida.puts "done"
    fsalida.puts "nodos p encontrados #{nodos_p.size}"

    fsalida.puts "calculando error de pitagoras"
    d_a_m=nil

    begin
      d_a_m=graph.get_shortest_paths(nodo_a,[nodo_m],IGraph::ALL)
    rescue Exception => msg
      # dispone el mensaje de error
      #puts "d_a_m #{msg}"

    end

    resul=[]

    if d_a_m!=nil
      nodos_p.each{|nodo_p|

        d_a_p=nil
        d_p_m=nil
        begin

          d_a_p=graph.get_shortest_paths(nodo_a,[nodo_p],IGraph::ALL)
          d_p_m=graph.get_shortest_paths(nodo_p,[nodo_m],IGraph::ALL)
        rescue Exception => msg
          # dispone el mensaje de error
          #puts msg

        end

        if d_a_p==nil or d_p_m==nil or d_a_p.first.size==0 or d_p_m.first.size==0
          break
        end

        #añandido el 5 nov, para eliminar rutas iguales
        resp=false
        d_a_m.first.each_index{|i|
          if i>0
            if d_a_p.first.include?(d_a_m.first[i])
              resp=true
              break
            end
          end
        }
        if(!resp)
          error=((d_a_m.first.size - 1)**2 + (d_p_m.first.size - 1)**2) - (d_a_p.first.size - 1)**2
          if error<5 and error>-5
            fsalida.puts "------------------"
            fsalida.puts "rutas"
            fsalida.puts "ruta de a hasta m #{d_a_m.first.inspect}"
            fsalida.puts "ruta de a hasta p #{d_a_p.first.inspect}"
            fsalida.puts "ruta de p hasta m #{d_p_m.first.inspect}"
            fsalida.puts "\n"
            fsalida.puts "distancias d(a,m) = #{d_a_m.first.size - 1} d(a,p)= #{d_a_p.first.size - 1} d(p,m)= #{d_p_m.first.size - 1}"
            resul.push([error,nodo_a,nodo_b,nodo_p,nodo_m])
            if error ==0
              apt= apt+ 5
            end
            if error==1 or error==-1
              apt=apt + 4
            end
            if error ==2 or error==-2
              apt= apt+ 3
            end
            if error==3 or error==-3
              apt=apt + 2
            end
            if error ==4 or error==-4
              apt= apt+ 1
            end

            fsalida.puts "error pitagoras #{error} nodo m #{nodo_m} nodo p #{nodo_p}"

          end
        end
      }
    end
    fsalida.puts "done \n"
    fsalida.puts "****************** \n\n"
  end
  #puts apt
t = Time.now
#puts t.strftime("%d/%m/%Y %H:%M:%S")
puts "Tiempo de finalizacion aptitud #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  return apt
end

#poblacion inicial
def crear_poblacion (cantidad_pob, num_nodos,fsalida)
  poblacion = []  
  cantidad_pob.times{ |i|
    
    cromosoma=iniciar_cromosoma
    puts "hijo #{i}"
    grafo_sin_aristas=crear_grafo(num_nodos)
    puts "numero de aristas #{grafo_sin_aristas.ecount()}"
    grafo=procesar_aristas(grafo_sin_aristas,cromosoma)
    poblacion[i]=[grafo,cromosoma,aptitud(grafo,fsalida)]
  }
  #puts poblacion.size
  return poblacion
end

def calcular_aptitud (poblacion)

  max=0

  poblacion.each{|indi|
    max= max + indi.last
  }

  poblacion.each{|indi|
    puts indi.last
    indi[2] = indi.last.to_f / max
  }

  return poblacion

end

puts "-------------aptitues----------------"
pob_ini=crear_poblacion(100,30,fsalida)

calcular_aptitud(pob_ini).each{|individuo|

  puts "aptitud #{individuo.last}"
}

t = Time.now
#puts t.strftime("%d/%m/%Y %H:%M:%S")
fsalida.puts "Tiempo de finalizacion #{t.strftime("%d/%m/%Y %H:%M:%S")}"
fsalida.close
