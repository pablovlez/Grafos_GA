#! /usr/bin/ruby

require 'rubygems'
require 'igraph'

class GraphEvo

  attr_accessor :graph, :cromosoma, :aptitud, :datos, :errores
  def initialize (num_nodos,cromosoma=nil)

    if cromosoma == nil
      @cromosoma= iniciar_cromosoma
    else
      @cromosoma = cromosoma
    end

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
    fsalida=File.new('salida_grafo.txt','w')
    @graph = procesar_aristas(graph,@cromosoma)
    @errores = puntuar_aptitud(@graph, fsalida)
    @aptitud=calcular_aptitud(@errores)

  end
  
def calcular_aptitud(errores)
  #entre mas ceros haya mejor es el individuo
      n=6
      histogram=[]
      n.times{|i|
        if i==0 then
          histogram[i]=[0..1,0]
        else
          if i==(n-1) then
            histogram[i]=[2**i..1024,0]
          else
            histogram[i]=[2**i..(2**(i+1))-1,0]
          end
        end
      }

      puts histogram.inspect

      errores.each{|value|
        histogram.each{|histo|
          key=histo[0]
          count=histo[1]
          if key.include?(value)
            histo[1]+=1
          end
        }
      }
      puts histogram.inspect
      i=0
      apt=0
      histogram.each{|histog|
        value=histog[1]
        apt+=value* 2**i
        i+=1
      }
      puts "aptitud grafo #{apt}"
      return apt     
    
  end

  

  def procesar_aristas(graph,cromosoma)
    #puts "procesando aristas"

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

  def mutar_cromosoma(cromosoma)
    @cromosoma=cromosoma
  end

  def puntuar_aptitud(graph, fsalida)
    t = Time.now
    #puts t.strftime("%d/%m/%Y %H:%M:%S")
    #puts "Tiempo de inicio aptitud #{t.strftime("%d/%m/%Y %H:%M:%S")}"
    n=Math.sqrt(graph.vcount())
    apt=[]
    resul=[]
    15.times do |iter|
      #fsalida.puts "iteracion #{iter}"
      #definimos los nodos a y b aleatoriamente

      nodo_a=rand(n*n)
      nodo_b=rand(n*n)

      #fsalida.puts "nodo a #{nodo_a}"
      #fsalida.puts "nodo b #{nodo_b}"

      #calculamos el nodo m entre los nodos a y b
      #fsalida.puts "calculando nodo medio"
      nodo_m=nil
      graph.get_shortest_paths(nodo_a,[nodo_b],IGraph::ALL).each {|a|
        l=a.size/2
        #puts "Nodo medio #{a[l]}"
        nodo_m=a[l]
      }
      #fsalida.puts "nodos medios encontrados #{nodos_m.size}"
      #fsalida.puts "nodo medio #{nodo_m}"
      #fsalida.puts "done"

      #calculamos los nodos p
      #fsalida.puts "calculando nodos p"

      #30 nov 2012
      #cambia la forma en como se hallan los nodos p
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
      #fsalida.puts "done"
      #fsalida.puts "nodos p encontrados #{nodos_p.size}"

      #fsalida.puts "calculando error de pitagoras"
      d_a_m=nil

      begin
        d_a_m=graph.get_shortest_paths(nodo_a,[nodo_m],IGraph::ALL)
      rescue Exception => msg
        # dispone el mensaje de error
        #puts "d_a_m #{msg}"

      end

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
            
              #fsalida.puts "------------------"
              #fsalida.puts "rutas"
              #fsalida.puts "ruta de a hasta m #{d_a_m.first.inspect}"
              #fsalida.puts "ruta de a hasta p #{d_a_p.first.inspect}"
              #fsalida.puts "ruta de p hasta m #{d_p_m.first.inspect}"
              #fsalida.puts "\n"
              #fsalida.puts "distancias d(a,m) = #{d_a_m.first.size - 1} d(a,p)= #{d_a_p.first.size - 1} d(p,m)= #{d_p_m.first.size - 1}"
              resul.push([error,nodo_a,nodo_b,nodo_p,nodo_m])              
              if error<0
                apt.push(error * -1)
              else
                apt.push(error)  
              end
              #fsalida.puts "error pitagoras #{error} nodo m #{nodo_m} nodo p #{nodo_p}"

            end
          
        }

      end
      #fsalida.puts "done \n"
      #fsalida.puts "****************** \n\n"
    end
    #puts apt
    #t = Time.now
    #puts t.strftime("%d/%m/%Y %H:%M:%S")
   # puts "Tiempo de finalizacion aptitud #{t.strftime("%d/%m/%Y %H:%M:%S")}"
    fsalida.close
    @datos=resul
    if apt.count == 0
      apt.push(1000)
    end
    return apt
  end

end