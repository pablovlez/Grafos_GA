#! /usr/bin/ruby


require 'AG.rb'


class Main
  
  ag=AG.new(100,35,0)
  
  fsalida=File.new('salida_evolucion.txt','w')
  i=0
  t = Time.now
  fsalida.puts "N 60"
  fsalida.puts "Tiempo de inicio AG #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  15.times{
  at=rand(100)    
  ag.evolucion()
  fsalida.puts "Generacion #{i}"
  fsalida.puts ag.aptitudes.inspect
  fsalida.puts ag.poblacion[at].aptitud
  fsalida.puts ag.poblacion[at].cromosoma.inspect
  fsalida.puts ag.poblacion[at].datos.inspect
  fsalida.puts "\n\n"
  i=i+1
  }
  
  t = Time.now
  fsalida.puts "Tiempo fin AG #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  fsalida.close
  
end