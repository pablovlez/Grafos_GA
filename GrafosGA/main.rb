#! /usr/bin/ruby


require 'AG.rb'


class Main
  
  ag=AG.new(100,32)
  fsalida=File.new('salida_evolucion.txt','w')
  i=0
  20.times{
    
  ag.evolucion()
  fsalida.puts "Generacion #{i}"
  fsalida.puts ag.aptitudes.inspect
  fsalida.puts ag.poblacion[rand(100)].cromosoma.inspect
  i=i+1
  }
  fsalida.close
  
end