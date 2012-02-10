=begin rdoc
 Trida Krizeni je spolecny rodic, od ktereho dedim inicializaci. Kazdy potomek doda konkretni metodu pro krizeni. Krizeni je proces promichani genomu jednoho jedince s jinym jedincem.
 
 gettry: vektor_a, vektor_b
=end
class Krizeni
##
#Tato metoda slouzi k inicializaci instancnich promennych.
#
  def initialize(vektor_a, vektor_b)
    @vektor_a = vektor_a       # jedna se o pole true/false hodnot, ktere vyjadruje nastaveni reprezentujici jednoho jedince populace gen. algoritmu
    @vektor_b = vektor_b       # vektor reprezentujici druheho jedince, kteri se budou krizit
  end
  #attr_reader 
  attr_reader :vektor_a, :vektor_b
end
