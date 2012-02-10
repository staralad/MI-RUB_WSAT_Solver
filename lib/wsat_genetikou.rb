require_relative './instance_wsat'
require_relative './krizeni'
require_relative './krizeni_jednobodove'
require_relative './krizeni_dvoubodove'
require_relative './krizeni_uniformni'


=begin rdoc
 Trida WSATGenetikou slouzi reprezentaci iterativniho algoritmu resiciho problem WSATu metodami inspirovanymi prirodou.
 
 
  Obecny popis algoritmu:
  --------------------------------------------------------------------------------- 
  1)Vygeneruj nahodnou pocatecni populaci P(0)                                       
  2)N-krat opakuj:                                                                   
      3) Vytvor novou praznou populaci P(N)                                          
           4)Pouzij selekci na omezeny pocet rodicu z populace P(N-1) a na vitezne:  
               5)pouzij se zvolenou pravdepodobnosti krizeni                         
               6)pouzij na kazdy bit jedince s urcitou pravdepodobnosti mutaci       
       7)Pridej potomky do nove populace                                            
       8)Nahrad starou populaci novou populaci P(N-1)=P(N)                           
  9)Potomek z populace P(N) s nejlepsi kondici (fitness) je resenim                  
  ---------------------------------------------------------------------------------
 
=end
class WSATGenetikou
  ## Udava velikost populace jedincu v kazde generaci.
  VELIKOST_POPULACE = 30
  ## Nastavuje selekcni tlat na vyber jedincu do populace pristi generace.    
  SELEKCNI_TLAK = 0.4 
  ## Pocet generaci (pocet iteraci algoritmu).      
  POCET_GENERACI = 100
  ## Pravdepodobnost, ze dojde ke krizeni jedincu.      
  P_KRIZENI = 0.15 
  ## Pravdepodobnost, je dojde k mutaci genomu jedince.         
  P_MUTACE = 0.1
  ## Typ krizeni: 1=jednobodove/ 2=dvoubodove/ 3=uniformni.             
  TYP_KRIZENI = 1 
  ## TREST SMRTI znamena automaticke nastavovani zdatnosti rovne 0 jedincum, kteri aktualne nejsou resenim problemu.          
  POUZIT_TREST_SMRTI = false 
  ## Pokud nebude TREST SMRTI uplatnovan, tak kolik procent (0.3 = 30%) maximalniho ohodnoceni zdatnosti mohou ziskat jedinci, kteri aktualni nejsou resenim problemu.       
  PROSTOR_K_POMERENI_ZDATNOSTI_NERESENI = 0.3  

##
#Tato metoda slouzi k prednastaveni instancnich promennych.
#  
  def initialize
    @populace = nil               # vygenerované vektory ohodnocení
    @instance = nil               # instance problemu WSAT
    @poc_klauzuli = 0             # pocet klauzuli problemu
    @poc_promennych_instance = 0  # pocet promennych formule
    @soucet_vsech_vah = 0         # maximalni soucet vahovych ohodnoceni
    @nej_soucet_vah = 0           # vysledny soucet vah nejlepsiho ziskaneho reseni
    @nejlepsi_reseni = nil        # nejlepsi ziskane reseni pomoci gen. algoritmu
  end


##
#Tato metoda slouzi ke spusteni genetickeho algoritmu. Vystupem je instance WSAT problemu se zapsanymi hodntami ziskanimi prubehem algoritmu.
#   
  def start(instance)
    
    # 1)Vygeneruj nahodnou pocatecni populaci P(0)
    nacti_parametry(instance)
    generuj_populaci(VELIKOST_POPULACE)
    
    # Vyhodnot kvalitu kazdeho jedince v populaci P pomoci ohodnocovaci funkce.
    #    - zjisti nejlepsiho jedince  
    sampion = dej_sampiona(@populace)
    
    # 2)N-krat opakuj:
    citac= 0
    while(citac < POCET_GENERACI)do
      # 3) Vytvoř novou práznou populaci P(N)
      nova_populace = Array.new(VELIKOST_POPULACE)
      nova_populace.each do |prvek| 
        prvek = Array.new(@poc_promennych_instance)
      end
      
      # 4)Pouzij selekci na omezeny pocet rodicu z populace P(N-1) a na vitezne:
      pocet_novych = 0
      citac2 = 0
      while(pocet_novych < VELIKOST_POPULACE)do # dokud nenaplnim celou populaci
        
        potomek_a = nil
        potomek_b = nil
        # 5)pouzij se zvolenou pravdepodobnosti krizeni
        if ((Random.rand(1001)/1000.0) < P_KRIZENI) then # (0<X<1)
          # provest krizeni
          potomek_a = (turnajovy_vyber(SELEKCNI_TLAK).dup)
          potomek_b = (turnajovy_vyber(SELEKCNI_TLAK).dup)
          case TYP_KRIZENI  
          when 1
            krizeni = KrizeniJednobodove.new(potomek_a,potomek_b)
          when 2
            krizeni = KrizeniDvoubodove.new(potomek_a,potomek_b) 
          else
            krizeni = KrizeniUniformni.new(potomek_a,potomek_b)  
          end
          krizeni.proved_krizeni
          potomek_a = krizeni.vektor_a.dup
          potomek_b = krizeni.vektor_b.dup
        else
          # provest vyber
          potomek_a = (turnajovy_vyber(SELEKCNI_TLAK).dup)         
        end
        
        # 6)pouzij na kazdy bit jedince s urcitou pravdepodobnosti mutaci  
        potomek_a = mutace(potomek_a)
        if (potomek_b != nil) then # pokud se provedlo krizeni a ma se provest mutace
          potomek_b = mutace(potomek_b)
        end
        
        # 7)Pridej potomky do nove populace
        nova_populace[pocet_novych] = potomek_a
        pocet_novych+=1
        if ((potomek_b != nil) && (pocet_novych != VELIKOST_POPULACE)) then
          nova_populace[pocet_novych] = potomek_b
          pocet_novych+=1
        end
            
        citac2+=1
      end
      # 8)Nahrad starou populaci novou populaci P(N-1)=P(N)
     
      @populace = nova_populace.dup # stara populace nahrazena novou
      #puts " #{vypis_populaci(@populace)}"
      citac+=1
    end
    # 9)Potomek z populace P(N) s nejlepsi kondici (fitness) je resenim
    sampion = dej_sampiona(@populace)

    if (dej_pocet_splnenych_klauzuli(sampion, instance.klauzule) == @poc_klauzuli)then # pokud je F splnena
      instance.zapis_vysledek(sampion, true)  # zapisi vysledky do instance
    else 
      instance.zapis_vysledek(sampion, false)
    end
    
    return instance
    
  end

private

##
#Tato metoda slouzi k nacteni instancnich promennych.
#  
  def nacti_parametry(instance)
    @instance = instance
    @poc_klauzuli = instance.pocet_klauzuli
    @poc_promennych_instance = instance.pocet_promennych
    @soucet_vsech_vah = instance.vrat_celkovy_soucet_vah
    @populace = Array.new(VELIKOST_POPULACE)
    citac = 0
    while(citac < VELIKOST_POPULACE)do
      @populace[citac] = Array.new(@poc_promennych_instance)
      citac +=1
    end
  end
  

##
#Tato metoda slouzi k vygenerovani nahodnych vektiru jedincu pocatecni populace.
# 
    
  def generuj_populaci(velikost)
    citac = 0
    while(citac < velikost)do
      citac2 = 0
      while(citac2<@poc_promennych_instance)do
        if (Random.rand(2)== 1)then # vrací 0/1
          @populace[citac][citac2] = true
        else
          @populace[citac][citac2] = false
        end
        citac2+=1
      end
      citac+=1
    end
  end
 
##
#Tato metoda slouzi k porovnavani dvou jedincu. Vraci toho zdatnejsiho.
#  
  def dej_sampiona(populace)
    nejlepsi = populace[0]
    fitness_sampiona = vypocti_fitness(nejlepsi)
    fitness_protivnika = 0
    
    citac = 1
    while(citac < VELIKOST_POPULACE)do
      fitness_protivnika = vypocti_fitness(populace[citac])
      if(fitness_sampiona < fitness_protivnika)then
        nejlepsi = populace[citac]
        fitness_sampiona = fitness_protivnika
      end
      citac+=1
    end
    return nejlepsi
    
  end
 
##
#Tato metoda slouzi k vypocteni zdatnosti jedince. Zdatnost je urcena na zaklade vlastnosti urcujici budouci prospesnost jedince.
#  
  def vypocti_fitness(jedinec)
    poc_splnenych_k = 0
    soucet_vah = 0
    fitness = 0.0
    
    # pocet splnenych klauzuli
    poc_splnenych_k = dej_pocet_splnenych_klauzuli(jedinec, @instance.klauzule)
    
    # splnena cela formule (TREST SMRTI)
    if (poc_splnenych_k == @poc_klauzuli) then
      # zvyhodneni za splnenou formuli  
      fitness = PROSTOR_K_POMERENI_ZDATNOSTI_NERESENI # pokud je splnena, tak zdatnost je vzdy >= zdatnosti nejlepsimu moznemu "nereseni"
      # bonus za pouzite vahy
      soucet_vah = @instance.vrat_soucet_vah(jedinec)
      fitness += (((1-PROSTOR_K_POMERENI_ZDATNOSTI_NERESENI) / @soucet_vsech_vah) * soucet_vah)    
    else  
      if (!POUZIT_TREST_SMRTI) then
        fitness = (PROSTOR_K_POMERENI_ZDATNOSTI_NERESENI / @poc_klauzuli) * poc_splnenych_k
      end   
    end
    
    return fitness    
  end
 
##
#Tato metoda vraci pocet splnenych klauzuli aktualnim nastavenim jedince.
#  
  def dej_pocet_splnenych_klauzuli(jedinec, klauzule)
    prom = 0
    poc_splnenych_k = 0
    
    citac = 0
    while(citac < @poc_klauzuli)do
      je_splnena = false
      citac2 = 0
      while(citac2 < klauzule[citac].length)do
        prom = klauzule[citac][citac2]
        if(((prom < 0) && !jedinec[prom.abs - 1]) || ((prom > 0) && jedinec[prom - 1])) then
          je_splnena = true
        end
        citac2+=1
      end
      if (je_splnena) then
        poc_splnenych_k+=1
      end
      citac +=1
    end
    
    return poc_splnenych_k
  end

##
#Tato metoda slouzi k vyberu nejzdatnejsiho jedince formou turnaje.
#   
  def turnajovy_vyber(selekcni_tlak)
    poc_zapasicich = (1-selekcni_tlak) * VELIKOST_POPULACE
    prihlaseni = []
    
    citac =0
    while(citac < VELIKOST_POPULACE)do
      prihlaseni[prihlaseni.length]=@populace[citac].dup
      citac+=1
    end
    citac = 0

    while(citac < poc_zapasicich)do

      nahoda = Random.rand(VELIKOST_POPULACE-citac)
      prihlaseni[nahoda] = nil
      prihlaseni.compact!
      
      citac+=1    
    end
    
    #vyberu sampiona s nejlepsim fitness
    vel = prihlaseni.length
    sampion = prihlaseni[0]
    
    citac = 0
    while(citac < vel)do
      sampion = dej_vyherce(sampion, prihlaseni[citac])
      citac+=1
    end
    
    return sampion
  end
 
##
#Tato metoda slouzi k urceni vyherce ze dvou zapasicich jedincu.
# 
  def dej_vyherce(jedinec_a, jedinec_b)
    if (vypocti_fitness(jedinec_a) >= vypocti_fitness(jedinec_b)) then
      return jedinec_a
    else
      return jedinec_b
    end
  end

##
#Tato metoda slouzi aplikaci procesu mutace genomu jedince.
#   
  def mutace(jedinec) # na kazdy bit jedince se pusti s MALOU pravdepodobnosti proces mutace
    citac = 0
    while(citac < @poc_promennych_instance)do
      if ((Random.rand(1001)/1000.0) < P_MUTACE) then # nahoda od 0.000 do 1.000
        jedinec[citac] = !jedinec[citac] # zneguju bit, ktery zasahla mutace
      end
      citac+=1
    end
    return jedinec
  end
 
##
#Tato metoda je pouze kontrolni a slouzi k vypisu jedince na standardni vystup.
#  
  def vypis_jedince(jedinec)
    print "("
    citac = 0
    while(citac < @poc_promennych_instance)do
      if(jedinec[citac]) then
        print "1"
      else
        print "0"
      end
      citac +=1
    end
    puts ")"
  end
  
##
#Tato metoda je pouze kontrolni a slouzi k vypisu populace na standardni vystup.
#  
  def vypis_populaci(populace)
    citac=0
    while(citac < populace.length)do
      print "("
      citac2=0
      while(citac2<@poc_promennych_instance)do
        if (populace[citac][citac2])then
          print"1"
        else 
          print"0"
        end
        citac2+=1
      end
      puts ")"
      citac+=1
    end
    puts
  end
  
end

