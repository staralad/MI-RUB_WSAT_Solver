require_relative './krizeni'

=begin rdoc
 Trida KrizeniDvoubodove je potomkem tridy Krizeni. Pridava konkretni metodu pro krizeni dvou jedincu.

=end
class KrizeniUniformni < Krizeni
##
#Tato metoda nahodne zvoli vektor o velikosti poctu (genomu) promennych instance a pokud vektor obsahuje hodnotu "true", tak dojde k prohozeni danych genomu mezi jedinci.
# 
  def proved_krizeni
    poc_promennych = @vektor_a.length
    nahodny_vektor =[]
    #vygeneruji si nahodny vektor
    citac = 0
    while(citac < poc_promennych)do
      nahodny_vektor[nahodny_vektor.length] = Random.rand(2)
      citac+=1
    end
    
    
    vektor_x = Array.new(poc_promennych)
    vektor_y = Array.new(poc_promennych)
    
    # podle nahodneho vektoru budu prohazovat
    citac = 0
    @vektor_a.each do |prvek| 
      if(nahodny_vektor[citac]==1)then # za nahodne zvolenym bodem prohazuj
        vektor_x[citac] = @vektor_b[citac]
        vektor_y[citac] = @vektor_a[citac];       
      else
        vektor_x[citac] = @vektor_a[citac]
        vektor_y[citac] = @vektor_b[citac];
      end
      citac +=1
    end
    
    #puts vektor_x
    #puts vektor_y
    @vektor_a = vektor_x
    @vektor_b = vektor_y
  end
end
