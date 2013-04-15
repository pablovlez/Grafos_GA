#! /usr/bin/ruby

require 'rubygems'
require 'igraph'

class GraphRand

  attr_accessor :graph, :cromosoma, :aptitud, :datos, :errores, :cantidad_nodos, :vecindad, :histograma
    
    def initialize (num_nodos,vecindad,cromosoma=nil)
     
      @vecindad=vecindad
      
      if cromosoma == nil
        @cromosoma= iniciar_cromosoma
      else
        @cromosoma = cromosoma
      end
      
      @cantidad_nodos=num_nodos
      
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
      @graph = procesar_aristas(graph,@cromosoma, 0.5)
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
      @histograma=histogram
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

  def round_to(a,x)
    (a * 10**x).round.to_f / 10**x
  end

  def procesar_aristas(graph,cromosoma,r)
    #puts "procesando aristas"
    n=Math.sqrt(graph.vcount())
    vecinos=[]
        index_rot1=[]
        index_rot2=[]
        index_rot3=[]
        if @vecindad == 1
          vecinos=[-(n+1),-n,-(n-1),-1,1,(n-1),n,(n+1)]
          index_rot1=[5,3,0,6,1,7,4,2]
          index_rot2=[7,6,5,4,3,2,1,0]
          index_rot3=[2,4,7,1,6,0,3,5]
        else
          if @vecindad == 2
            vecinos=[-(n*2+2),-(n*2+1),-(n*2),-(n*2-1),-(n*2-2),
              -(n+2),-(n+1),-n,-(n-1),-(n-2),
              -2,-1,1,2,
              (n-2),(n-1),n,(n+1),(n+2),
              (n*2-2),(n*2-1),(n*2),(n*2+1),(n*2+2)]
            index_rot1=[19,14,10,5,0,20,15,11,6,1,21,16,7,2,22,17,12,8,3,23,18,13,9,4]
            index_rot2=[23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0]
            index_rot3=[4,9,13,18,23,2,8,12,17,22,2,7,16,21,1,6,11,15,20,0,5,10,14,19]
          end
        end

    vertice = n+1
    while vertice<((n*n)-(n+1))

      if vertice % n < (n-(n/2)) and vertice <= ((n*n)-1)/2 #primer cuadrante
              cromosoma.each_index{ |i|
                if cromosoma[i]<r
                  #puts vertice+vecinos[i]
                  if vertice+vecinos[i]>0
                    graph.add_edge(vertice,vertice+vecinos[i])
                    #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
                  end
                end
              }
            end
      
            if vertice % n >= (n-(n/2)) and vertice <= (((n*n)-1)/2) + ((n/2)-1)  #segundo cuadrante
              cromosoma.each_index{ |i|
                if cromosoma[index_rot1[i]]<r
                  if vertice+vecinos[i]>0
                    graph.add_edge(vertice,vertice+vecinos[i])
                    #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
                  end
                end
              }
            end
      
            if vertice % n >= (n-(n/2)) and  vertice >= (((n*n)-1)/2)+n and vertice <= ((n*n)-1) - (n+1)  #tercer cuadrante
              cromosoma.each_index{ |i|
                if cromosoma[index_rot2[i]]<r
                  if vertice+vecinos[i]<n*n
                    graph.add_edge(vertice,vertice+vecinos[i])
                    #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
                  end
                end
              }
            end
      
            if vertice >= (((n*n)-1)/2) + ((n/2)-1) + 3 and vertice % n <= (n-(n/2)-1)  #cuarto cuadrante
              cromosoma.each_index{ |i|
                if cromosoma[index_rot3[i]]<r
                  if vertice+vecinos[i]<n*n
                    graph.add_edge(vertice,vertice+vecinos[i])
                    #puts "Arista anadida del vertice #{vertice} al vertice #{vertice+vecinos[i]}"
                  end
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
    veces=0
    if @vecindad==1
      veces=8
    else
      veces=24
    end
    veces.times{
      num=round_to(rand(),1)
      cromosoma.push(num)
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
      distance_nodA_nodM=nil

      begin
        distance_nodA_nodM=graph.get_shortest_paths(nodo_a,[nodo_m],IGraph::ALL)
      rescue Exception => msg
        # dispone el mensaje de error
        #puts "distance_nodA_nodM #{msg}"

      end

      if distance_nodA_nodM!=nil
        nodos_p.each{|nodo_p|

          distance_nodA_nodP=nil
          distance_nodP_nodM=nil
          begin

            distance_nodA_nodP=graph.get_shortest_paths(nodo_a,[nodo_p],IGraph::ALL)
            distance_nodP_nodM=graph.get_shortest_paths(nodo_p,[nodo_m],IGraph::ALL)
          rescue Exception => msg
            # dispone el mensaje de error
            #puts msg

          end

          if distance_nodA_nodP==nil or distance_nodP_nodM==nil or distance_nodA_nodP.first.size==0 or distance_nodP_nodM.first.size==0
            break
          end

          #añandido el 5 nov, para eliminar rutas iguales
          resp=false
          distance_nodA_nodM.first.each_index{|i|
            if i>0
              if distance_nodA_nodP.first.include?(distance_nodA_nodM.first[i])
                resp=true
                break
              end
            end
          }
          if(!resp)
            error=((distance_nodA_nodM.first.size - 1)**2 + (distance_nodP_nodM.first.size - 1)**2) - (distance_nodA_nodP.first.size - 1)**2

            #fsalida.puts "------------------"
            #fsalida.puts "rutas"
            #fsalida.puts "ruta de a hasta m #{distance_nodA_nodM.first.inspect}"
            #fsalida.puts "ruta de a hasta p #{distance_nodA_nodP.first.inspect}"
            #fsalida.puts "ruta de p hasta m #{distance_nodP_nodM.first.inspect}"
            #fsalida.puts "\n"
            #fsalida.puts "distancias d(a,m) = #{distance_nodA_nodM.first.size - 1} d(a,p)= #{distance_nodA_nodP.first.size - 1} d(p,m)= #{distance_nodP_nodM.first.size - 1}"
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