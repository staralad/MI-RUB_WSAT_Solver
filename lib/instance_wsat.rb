=begin rdoc
Trida InstanceWSAT zastupuje v programu data reseneho problemu.

=end
class InstanceWSAT

##
#Inicializace instancnich promennych. 
#
  def initialize
    @klauzule = []              # 2D pole cisel reprezentujicich klauzule formule
    @pole_vah = []              # 1D pole cisel vahovych ohodnoceni jednotlich promennych
    @je_splnitelna = false      # vyjadruje vyslednou splnitelnost formule
    @pocet_klauzuli = 0         # pocet klauzuli ve formuli
    @pocet_promennych = 0.0     # pocet promennych ve formuli
    @reseni = []                # vysledne nejlepsi reseni zaskane danym algoritmem
    @vysledny_soucet_vah = 0    # vysledny soucet vah daneho reseni
  end
  #attr_reader
  attr_reader :pocet_klauzuli, :pocet_promennych, :klauzule, :pole_vah, :reseni, :je_splnitelna, :vysledny_soucet_vah
  
##
#Tato metoda slouzi k nacteni dat ze vstupniho retezce, ktery prijima jako parametr "data". Dale umoznuje regulovat obtiznost instance zmenou nastaveni parametru "pomer", ktery urcuje kolik klauzuli bude pouzito pri reseni problemu (pomer poctu klauzuli ku poctu promennych).
#
  def nacti_data(data, pomer)
    poc_nactenych_klauzuli = 0   
    pole_radku = data.split("\n")
    
    pole_radku.each do |radek|
      if(radek[0]!="c")then #preskakuji komentar
        pole_hodnot = radek.split(' ') # ulozim si hodnoty do pole
        
        case radek[0]
          
        when "p"
          #nacteni zakladniho nastaveni instance
          @pocet_promennych = pole_hodnot[2].to_i
          @pocet_klauzuli = pole_hodnot[3].to_i
          # pokud je nastaven pomer (tj. obtiznost instance)
          if((pomer!=-1)&&(@pocet_klauzuli>=@pocet_promennych.to_f*pomer))then
            @pocet_klauzuli = @pocet_promennych.to_f*pomer
          end
          
        when "w"
          #nacitani vahoveho vektoru
          citac = 1
          while(citac < pole_hodnot.length)do
            @pole_vah[citac-1] = pole_hodnot[citac].to_i
            citac +=1
          end

          # when "%" # pouze pro kontrolu
          #ukoncovaci znak
          #  puts "%"   
       
        else
          #nacitani klauzuli
          if(poc_nactenych_klauzuli<@pocet_klauzuli)then
            citac = 0
            while(citac < pole_hodnot.length-1)do
              if(@klauzule[poc_nactenych_klauzuli]==nil)then
                nove_pole = []
                @klauzule[poc_nactenych_klauzuli]= nove_pole
              end
              @klauzule[poc_nactenych_klauzuli][@klauzule[poc_nactenych_klauzuli].length] = pole_hodnot[citac].to_i
              citac +=1
            end
            poc_nactenych_klauzuli+=1
          end             
        end
      end
    end     
  end
  
##
#Tato metoda vypocte maximalni soucet vah (tj. vsechny vahy secte).
#  
  def vrat_celkovy_soucet_vah
    soucet = 0
    @pole_vah.each do |prvek|  
      soucet += prvek.to_i
    end
    return soucet
  end
 
##
#Tato metoda pro parametr "jedinec" (pole true/false hodnot) vypocte celkovy soucet pouzitych vah.
#
  def vrat_soucet_vah(jedinec)
    soucet = 0
    citac = 0
    jedinec.each do |prvek|  
      if(prvek)then
        soucet += @pole_vah[citac].to_i
      end
      citac +=1
    end
    return soucet
  end
 
##
#Tato metoda slouzi k zapsani ziskanych vysledku do instance teto tridy. Prijima parametry "reseni" (pole hodnot true/false) a "je_splnitelna" (udava jestli dany algoritmus nalezl platne reseni).
# 
  def zapis_vysledek(reseni, je_splnitelna) 
    @reseni = reseni
    @vysledny_soucet_vah = vrat_soucet_vah(reseni)
    @je_splnitelna = je_splnitelna
  end

##
#Tato metoda slouzi k vypisu ciselneho vyjadreni reseni (pole true/false hodnot) neboli vitezneho jedince.
#  
  def vypis_reseni

    vystup = "("
    @reseni.each do |prvek|
      if(prvek)then
        vystup += "1"
      else
        vystup += "0"
      end     
    end
    vystup += ")"
    
    return vystup
  end
  
end
