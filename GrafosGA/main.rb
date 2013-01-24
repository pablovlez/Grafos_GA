#! /usr/bin/ruby


require 'AG.rb'


class Main
  
  ag=AG.new(100,50)
  fsalida=File.new('salida_evolucion.txt','w')
  i=0
  t = Time.now
  
  fsalida.puts "Tiempo de inicio AG #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  20.times{
    
  ag.evolucion()
  fsalida.puts "Generacion #{i}"
  fsalida.puts ag.aptitudes.inspect
  fsalida.puts ag.poblacion[rand(100)].cromosoma.inspect
  fsalida.puts ag.poblacion[rand(100)].datos.inspect
  fsalida.puts "\n\n"
  i=i+1
  }
  
  t = Time.now
  fsalida.puts "Tiempo fin AG #{t.strftime("%d/%m/%Y %H:%M:%S")}"
  fsalida.close
  
end