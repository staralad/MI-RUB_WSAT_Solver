require_relative '../lib/modifikator_instanci'
require_relative '../lib/instance_wsat'
require_relative '../lib/wsat_hrubou_silou'
require_relative '../lib/wsat_genetikou'


#KONSTANTY
MAX_VAHA = 10
POMER = 2
POUZIT_PROREZAVANI = false

def nacti_data_souboru(cesta)
  fi = File.open( cesta , "r" )
  pole = fi.readlines # načte vstupní soubor do pole řádků
  fi.close
  return pole
end

parametry = $* #zastupuje pole parametrů

if(parametry[0] == nil)then #kontrola existence parametru
  puts "Chybi cesta k instanci problemu. Tvar pri spousteni: $ ruby bin/main.rb cesta_k_souboru_instance"
  Process.exit(0)
end

if(!File.exists?(parametry[0]))then
  puts "Zadany soubor neexistuje."
  Process.exit(0) 
end

koncovka = parametry[0][parametry[0].length-4..parametry[0].length]

if(koncovka!=".cnf" && koncovka!="cnfw")then #kontrola koncovek souborů
  puts "Zadan neznamy soubor."
  Process.exit(0) 
end


if(koncovka == ".cnf")then          #pokud je vstupem nemodifikovaný soubor
  
  #načtení souboru
  pole = nacti_data_souboru(parametry[0])
  stroj = ModifikatorInstanci.new(pole, MAX_VAHA)
  m_instance =  stroj.vrat_modif_instanci
    
  #vytvoření modifikovaného souboru
  fo = File.open(parametry[0]+"w", "w")
  m_instance.each_line do |radek|
    fo << radek
  end
  fo.close
  #puts m_instance
else                                # pokud je vstupem již modifikovaný soubor
  pole = nacti_data_souboru(parametry[0])
  m_instance = pole.join('')        # abych měl stejnej formát jako u .cnf
  #puts m_instance
end

instance = InstanceWSAT.new
instance.nacti_data(m_instance, POMER)
                                                                           
puts "Nazev algoritmu | Splnitelnost |  Vektor reseni WSAT  | Soucet vah | Cas vypoctu  "

#Hrubá síla (BF)
bf = WSATHrubouSilou.new(POUZIT_PROREZAVANI)
zacatek = Time.now
vysledek_bf =bf.start(instance)
konec = Time.now 
cas_bf = (konec - zacatek) * 1000
vahy_bf = vysledek_bf.vysledny_soucet_vah

printf "%17s%15s%22s%10d%12.2f%3s\n","Hruba sila      ",  "#{vysledek_bf.je_splnitelna}      ", vysledek_bf.vypis_reseni,vysledek_bf.vysledny_soucet_vah, cas_bf,"ms"

#Gentický algoritmus (GA)
ga = WSATGenetikou.new
zacatek = Time.now
vysledek_ga = ga.start(instance)
konec = Time.now
cas_ga = (konec - zacatek)*1000

if(vysledek_ga.je_splnitelna)then
  rel_chyba =  ((vahy_bf - vysledek_ga.vysledny_soucet_vah) / vahy_bf.to_f)
  vektor = vysledek_ga.vypis_reseni
  soucet = vysledek_ga.vysledny_soucet_vah
else
  rel_chyba = 1
  vektor = ""
  soucet = 0
end

printf "%17s%15s%22s%10d%12.2f%3s\n","Geneticky alg.  ",  "#{vysledek_ga.je_splnitelna}      ", vektor, soucet, cas_ga,"ms"
puts "--------------------------------------------------------------------------------"
printf "%16s%6.2f%2s"," Relativni chyba:", rel_chyba*100, "%"

