require_relative './krizeni'

=begin rdoc
 Trida KrizeniDvoubodove je potomkem tridy Krizeni. Pridava konkretni metodu pro krizeni dvou jedincu.

=end
class KrizeniDvoubodove < Krizeni

##
#Tato metoda nahodne zvoli dva body ve vektoru promennych (genomu) jedincu a mezi temito body prohodi genomy jednoho jedince s genomy druheho. 
#  
  def proved_krizeni
    poc_promennych = @vektor_a.length
    puts "poc_p_ #{poc_promennych}"
    # nahodne vyberu hranice prohazovani
    nahoda = Random.rand(poc_promennych)
    nahoda2 = Random.rand(poc_promennych)
    # opakuj dokud se nevyberou ruzne hranice
    while(nahoda==nahoda2)do
      nahoda2 = Random.rand(poc_promennych)
    end
    # pokud jsou prohozene, tak jednou prohod
    if(nahoda2 < nahoda)then 
      pom = nahoda
      nahoda = nahoda2
      nahoda2 = pom
    end
    
    vektor_x = Array.new(poc_promennych)
    vektor_y = Array.new(poc_promennych)
    puts "n: #{nahoda}, #{nahoda2}"
    # prohazuj v ramci hranic
    citac = 0
    poc_promennych.times{
      if((citac>=nahoda)&&(citac<=nahoda2))then
        vektor_x[citac] = @vektor_b[citac]
        vektor_y[citac] = @vektor_a[citac];       
      else
        vektor_x[citac] = @vektor_a[citac]
        vektor_y[citac] = @vektor_b[citac];
      end
      citac +=1
    }  
     
    #puts vektor_x
    #puts vektor_y
    @vektor_a = vektor_x
    @vektor_b = vektor_y
  end
  
end
