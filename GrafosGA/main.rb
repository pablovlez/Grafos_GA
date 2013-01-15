#! /usr/bin/ruby


require 'AG.rb'


class Main
  
  ag=AG.new(100,32)
  fsalida=File.new('salida_evolucion.txt','w')
  20.times{
  ag.evolucion()
  fsalida.puts ag.mejor
  fsalida.puts ag.poblacion[rand(100)].cromosoma.inspect
  }
  fsalida.close
  
end