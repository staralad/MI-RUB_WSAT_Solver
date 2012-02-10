require_relative './krizeni'
=begin rdoc
 Trida KrizeniDvoubodove je potomkem tridy Krizeni. Pridava konkretni metodu pro krizeni dvou jedincu.

=end
class KrizeniJednobodove < Krizeni
##
#Tato metoda nahodne zvoli jeden bod ve vektoru promennych (genomu) jedincu a od tohoto bodu až do konce prohodi genomy jednoho jedince s genomy druheho. 
# 
  def proved_krizeni
    poc_promennych = @vektor_a.length
    nahoda = 1+Random.rand(poc_promennych-1)
    vektor_x = Array.new(poc_promennych)
    vektor_y = Array.new(poc_promennych)
    citac = 0
    @vektor_a.each do 
      if(citac >= nahoda)then # za nahodne zvolenym bodem prohazuj
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
