#! /usr/bin/ruby

require_relative 'Grafo.rb'

class AG

  attr_accessor :cant_pob, :matting_pool, :poblacion, :hijos, :aptitudes
  
  def initialize(cant_pob)
    cant_pob.times{ |i|
      @poblacion[i] = Grafo.new(20)
    }
  end

  def calcular_aptitud ()

    max=0

    @poblacion.each{|indi|
      max= max + indi.aptitud
    }

    @poblacion.each{|grafo|
      @aptitudes.push(grafo.aptitud.to_f / max )
    }

  end

end