=begin rdoc
 Trida ModifikatorInstanci slouzi k dogenerovani nahodneho vektoru vah do instance SAT problemu a tim jej zmeni na WSAT problem, ktery prohram dale resi.
 
=end
class ModifikatorInstanci
##
#Tato metoda slouzi k inicializaci instancnich promennych.
#
  def initialize(pole_dat, max_vaha)
    @pole_dat = pole_dat            # pole retezcu puvodni nactene SAT instance
    @max_vaha = max_vaha            # udava maximalni vahu, kterou generator muze vygenerovat (minimalni je 1)
  end

##
#Tato metoda slouzi ke spravnemu zapsani retezce s nahodne vygenerovanymi vahami do WSAT instance reprezentovane retezcem.
#  
  def vrat_modif_instanci
    vystup=""
    @pole_dat.each do |radek|  
      if(radek[0]=="p")then     
        vystup +=radek
        vystup += "w #{generuj_vahy(radek).join(' ')}\n" #pridani radku s vahami
      else
        vystup +=radek
      end     
    end
    # puts vystup
    return vystup
  end
  
##
#Tato metoda slouzi k vygenerovani retezce s nahodnymi vahami.
#  
  def generuj_vahy(radek)
    pole_vah=[]
    
    pole = radek.split(' ') # ze stringu udela pole podle mezer
    poc_promennych = pole[2].to_i #zjistíme pocet promennych instance
    
    poc_promennych.times{      
      pole_vah[pole_vah.length]=1+Random.rand(@max_vaha) # vygeneruje nahodne vahu od 1 do max. vahy
    }
    ## puts pole_vah.join(' ') 
    return pole_vah
  end
   
end
