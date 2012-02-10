require_relative './instance_wsat'

=begin rdoc
 Trida WSATHrubouSilou reprezentuje algoritmus resici WSAT problem pomoci pristupu hrubou silou (tj. prozkoumava cely stavovy prostor problemu). Prijima jediny parametr (true/false), ktery urcuje, zda se pouzije prorezavani vetvi stromu rekurze, ktere nevedou k vysledku.
 
=end
class WSATHrubouSilou
##
#Tato metoda slouzi k uvodni inicializaci instancnich promennych.
#
  def initialize(prorezavani)
    @prorezavani = prorezavani                 # pouzit prorezavani
    @poc_klauzuli = 0                          # pocet klauzuli formule
    @poc_promennych_instance = 0               # pocet promennych formule
    @soucet_vsech_vah = 0                      # maximalni soucet ohodnoceni vah
    @nej_soucet_vah = 0                        # vysledny soucet vah ziskaneho reseni
    @nejlepsi_reseni = nil                     # reprezentace ziskaneho reseni (pole true/false hodnot)
    @instance = nil                            # instance WSAT problemu
    @umisteni_prom = nil                       # 2D pole udrzujici info. o vyskytu promennych v klauzulich
  end
  #attr_reader
  attr_accessor :nejlepsi_reseni

##
#Tato metoda slouzi k nacteni dat z pole retezcu (parametr "instance") do datovych struktur.
#  
  def nacti_parametry(instance)
    @instance = instance
    @soucet_vsech_vah = instance.vrat_celkovy_soucet_vah 
    @poc_promennych_instance = instance.pocet_promennych
    @poc_klauzuli = instance.pocet_klauzuli
    @umisteni_prom = Array.new(@poc_promennych_instance)
    @nejlepsi_reseni = Array.new(@poc_promennych_instance)
    @umisteni_prom = Array.new(@poc_promennych_instance)
  end

##
#Tato metoda slouzi k spusteni reseni WSAT problemu.
#  
  def start(instance)
    nacti_parametry(instance)
    zapis_umisteni_prom(instance.klauzule) # vypise do 2D seznamu jednotlove umisteni promennych
    reseni = vytvor_nulovy_vektor(@poc_promennych_instance) # nulovy vektor
    hruba_sila(0, 0, 0, reseni, je_formule_splnitelna?(reseni))
    instance.zapis_vysledek(@nejlepsi_reseni, je_formule_splnitelna?(@nejlepsi_reseni)) # zkontroluje, zda pro vysledek je formule splnitelna (napr. kdyby zustal nulový vektor jako reseni) a zapise vysledky
    return instance 
  end

##
#Tato rekurzivni metoda je jadrem prostupu reseni hrubou silou. Rekurzivne vola sebe sama a tim tvori strom rekurze, dokud nedojde k listum, nebo neni predcasne prorezana. 
#   
  def hruba_sila(pozice, pred_soucet_vah, pred_soucet_vah_vyrazenych, nastaveni, je_splnena)
    soucet_vah_vyrazenych = pred_soucet_vah_vyrazenych
    while(pozice < @poc_promennych_instance)do
      if (!@prorezavani || (@nej_soucet_vah < (@soucet_vsech_vah - soucet_vah_vyrazenych))) then #(PROREZAVANI) pokud nemuze byt lepsi jak nejlepsi ani po pricteni zbyvajicich moznych vah
        nastaveni[pozice] = true # zkusím proměnnou s indexem "pozice" dát na "true"
        if(!je_formule_pouzitelna?(pozice, nastaveni)) then # pokud obsahuje konecne nesplnene klausule
          nastaveni[pozice] = false # vratim zmenu
          if ((je_splnena) && (@nej_soucet_vah < pred_soucet_vah))then  # pokud predchozi formule byla splnena && pokud mam lepsi reseni  
            @nejlepsi_reseni = nastaveni.dup # zapise novy vysledek
            @nej_soucet_vah = pred_soucet_vah # zapise novy vysledny soucet vah
          end  
        else # pokud je F pouzitelna
          soucet_vah = pred_soucet_vah + @instance.pole_vah[pozice].to_i
          hruba_sila(pozice + 1, soucet_vah, soucet_vah_vyrazenych, nastaveni, je_formule_splnitelna?(nastaveni))
          nastaveni[pozice] = false # vratim na false, abych mohl prejit k testovani s nulou na teto pozici
        end 
      else
        nastaveni[pozice] = false
      end
      soucet_vah_vyrazenych += @instance.pole_vah[pozice] # prictu vahu k vyrazenym, abych mohl prejít k testovani s nulou na teto pozici
      
      pozice+=1
    end
       
    if ((je_splnena) && (@nej_soucet_vah < pred_soucet_vah)) then
      @nejlepsi_reseni = nastaveni.dup # zapise novy vysledek
      @nej_soucet_vah = pred_soucet_vah # zapise novy vysledny soucet vah
    end
  end
  
##
#Tato metoda slouzi k zjisteni, zda existuji pro dane "nastaveni" (tedy jedince) konecna (jiz nemenici se) klauzule, ktera je nesplnena. Protoze jedna nesplnena klauzule ve formuli tvaru CNF znamena nesplnenou celou formuli a tudiz, ze se nejedna o reseni naseho problemu. 
#  
  def je_formule_pouzitelna?(pozice, nastaveni) # neboli neexistuji konecne klauzule, ktere jsou NESPLNENE
  
    if(@umisteni_prom[pozice]==nil)then
      nove_pole = []
      @umisteni_prom[pozice]= nove_pole
    end
    
    @umisteni_prom[pozice].each do |cislo|   # projde vsechny klauzule, ktere zmenena promenna ovlivnuje
      poc_prom = @instance.klauzule[cislo].length 
      jsou_hotove = true # jsou pevne stanoveny vsechny prom. v klazuli?
      je_splnena = false
    
      citac = 0
      while(citac < poc_prom)do
        if(@instance.klauzule[cislo][citac].to_i.abs > (pozice + 1))then # pozice je od 0 a promenne od 1 => pozice+1
          jsou_hotove = false # pokud se najde v klauzuli promenna s vyssim indexem, tak jeste neni klazule definitivne urcena
        end
        poradi_v_nastaveni = @instance.klauzule[cislo][citac].to_i.abs - 1
        if(((@instance.klauzule[cislo][citac].to_i < 0) && (!nastaveni[poradi_v_nastaveni])) || ((@instance.klauzule[cislo][citac].to_i > 0) && nastaveni[poradi_v_nastaveni])) then # je klauzule splnena?
          je_splnena = true
        end
        citac+=1
      end 
      
      if ((jsou_hotove) && (!je_splnena))then # pokud je klauzule urcena definitivne timto ohodnocenim a je nesplnena => cela formule nesplnena
        return false
      end
    end
    return true
  end 
  
##
#Tato metoda slouzi k zapsani nalezeneho umisteni promenne do 2D pole vyskytu promennych.
# 
  def zapis_umisteni_prom(klauzule)
    # prohleda vsechny klauzule a zapise jejich promenne na patricna mista v seznamu
    citac = 0
    while(citac < @poc_klauzuli)do
      poc_prom = klauzule[citac].length
      citac2 = 0
      while(citac2 < poc_prom)do # zapisuji vsechny promenne
        index_prom_v_poli = klauzule[citac][citac2].to_i.abs - 1 # .abs -> absolutni hodnota cisla
        if(@umisteni_prom[index_prom_v_poli]==nil || !(@umisteni_prom[index_prom_v_poli].include?(citac))) then # pokud jiz nemam poznamenan index teto klauzule
          if(@umisteni_prom[index_prom_v_poli]==nil)then
            nove_pole = []
            @umisteni_prom[index_prom_v_poli]=nove_pole
          end
          @umisteni_prom[index_prom_v_poli][@umisteni_prom[index_prom_v_poli].length] = citac
        end
        citac2+=1
      end         
      citac+=1
    end
  end
 
##
#Tato metoda slouzi k vytvoreni vektoru false hodnot reprezentujiciho pocatecniho jedince.
#       
  def vytvor_nulovy_vektor(pocet)
    vystup = []
    pocet.times {
      vystup[vystup.length] = false
    }
    return vystup
  end
     
##
#Tato metoda pro dane reseni (jedince) zjisti, zda je cela formule splnena a vrati true/false hodnotu.
# 
  def je_formule_splnitelna?(reseni)
    citac = 0
    while(citac < @instance.klauzule.length)do # prochazi jednotlive klauzule
      je_splnena = false
      citac2 = 0
      while(citac2 < @instance.klauzule[citac].length)do # prochazi promennne klauzule
        poradi_v_reseni = @instance.klauzule[citac][citac2].abs - 1 # poradi v logickem vektoru reseni
        if (((@instance.klauzule[citac][citac2] < 0) && (!reseni[poradi_v_reseni])) || ((@instance.klauzule[citac][citac2] > 0) && reseni[poradi_v_reseni])) then # je klauzule splnena?
          je_splnena = true
        end    
        citac2+=1
      end
      
      if (!je_splnena) then
        return false
      end
      
      citac+=1
    end
    
    return true  
  end

##
#Tato metoda slouzi pouze pro kontrolu. A vypisuje na standardni vystup dane reseni.
# 
  def vypis_reseni(reseni)
    print "reseni(BF): "
    reseni.each do |prvek|  
      if(prvek) then
        print "1"
      else 
        print "0"
      end
    end
    print " #{@instance.vrat_soucet_vah(reseni)} "
    puts
  end
  
end
