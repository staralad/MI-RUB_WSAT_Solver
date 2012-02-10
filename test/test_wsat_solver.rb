require 'test/unit'
require_relative '../lib/modifikator_instanci'
require_relative '../lib/instance_wsat'
require_relative '../lib/krizeni'
require_relative '../lib/wsat_hrubou_silou'
require_relative '../lib/wsat_genetikou'

class TestWSATSolver < Test::Unit::TestCase

  def setup
    #definování spoleèných prostøedkù
    @fi = File.open( "./test/a.cnf" , "r" )
    @pole = @fi.readlines # naète vstupní soubor do pole øádkù
    @spol_instance = InstanceWSAT.new
  end
  
  def teardown
    # zde by bylo uvolòování spoleèných prostøedkù
    @fi.close
  end

  def test_modificator_vytvoreni
    masina = ModifikatorInstanci.new(@pole,10)
    refute_nil(masina, "Objekt masina ze tridy ModifikatorInstanci by mel byt vytvoren.")  
  end

  def test_modificator_vrat_modif_instanci
  
    ocekavano = ["c Priklad CNF","c 4 promenne a 6 klauzuli","c kazda klauzule konci nulou (ne novym radkem)","p cnf 4 6","w 5 6 5 3","1 -3 4 0","-1 2 -3 0","3 4 0","1 2 -3 -4 0","-2 3 0","-3 -4 0"]  
    vystup = ModifikatorInstanci.new(@pole,10).vrat_modif_instanci
    vyst_pole = vystup.split("\n")
    
    assert_equal(ocekavano[0], vyst_pole[0])
    assert_equal(ocekavano[1], vyst_pole[1])
    assert_equal(ocekavano[2], vyst_pole[2])
    assert_equal(ocekavano[3], vyst_pole[3])
    assert_equal(ocekavano[4][0...1], vyst_pole[4][0...1])  #vektor vah (je náhodný)
    assert_equal(ocekavano[5], vyst_pole[5])
    assert_equal(ocekavano[6], vyst_pole[6])
    assert_equal(ocekavano[7], vyst_pole[7])
    assert_equal(ocekavano[8], vyst_pole[8])
    assert_equal(ocekavano[9], vyst_pole[9])
    assert_equal(ocekavano[10], vyst_pole[10])
  end

  def test_instance_wsat_vytvoreni
    instance = InstanceWSAT.new
    refute_nil(instance, "Objekt instance ze tridy InstanceWSAT by mel byt vytvoren.")  
  end
  
  def test_instance_wsat_nastaveni_param
    
    assert_equal(false, @spol_instance.je_splnitelna)
    assert_equal(0, @spol_instance.pocet_klauzuli)
    assert_equal(0, @spol_instance.pocet_promennych)
    assert_equal(0, @spol_instance.vysledny_soucet_vah)
    assert_equal(0, @spol_instance.pole_vah.length)
    assert_equal(0, @spol_instance.reseni.length)
  end
  
  def test_instance_wsat_nacti_data
    vystup = ModifikatorInstanci.new(@pole,10).vrat_modif_instanci
    
    @spol_instance.nacti_data(vystup, -1)
    
    
    cnt = 0
    @spol_instance.pole_vah.each do |item|  
      cnt+=1
    end
    
    
    assert_equal(false, @spol_instance.je_splnitelna)
    assert_equal(6, @spol_instance.pocet_klauzuli)
    assert_equal(4, @spol_instance.pocet_promennych)
    assert_equal(0, @spol_instance.vysledny_soucet_vah)
    assert_equal(cnt, @spol_instance.pole_vah.length)
    assert_equal(0, @spol_instance.reseni.length)
    assert_equal([1, -3, 4], @spol_instance.klauzule[0])
    assert_equal([-1, 2, -3], @spol_instance.klauzule[1])
    assert_equal([3, 4], @spol_instance.klauzule[2])
    assert_equal([1, 2, -3, -4], @spol_instance.klauzule[3])
    assert_equal([-2, 3], @spol_instance.klauzule[4])
    assert_equal([-3, -4], @spol_instance.klauzule[5])
  end

  def test_instance_wsat_vrat_celkovy_soucet_vah
    @spol_instance.nacti_data(ModifikatorInstanci.new(@pole,10).vrat_modif_instanci, -1)
    
    vysl_soucet = 0
    @spol_instance.pole_vah.each do |item|  
      vysl_soucet += item
    end
    assert_equal(vysl_soucet, @spol_instance.vrat_celkovy_soucet_vah)
  end

  def test_instance_wsat_zapis_vysledek
    @spol_instance.nacti_data(ModifikatorInstanci.new(@pole,10).vrat_modif_instanci, -1)
    @spol_instance.zapis_vysledek([true,true,true,false], true)
    soucet = @spol_instance.pole_vah[0] + @spol_instance.pole_vah[1]+@spol_instance.pole_vah[2]
    
    assert_equal([true,true,true,false], @spol_instance.reseni)
    assert_equal(true, @spol_instance.je_splnitelna)
    assert_equal(soucet, @spol_instance.vysledny_soucet_vah)
  end

  def test_instance_wsat_vypis_reseni
    @spol_instance.nacti_data(ModifikatorInstanci.new(@pole,10).vrat_modif_instanci, -1)
    @spol_instance.zapis_vysledek([true,true,true,false], true)
 
    assert_equal("(1110)", @spol_instance.vypis_reseni)
  end

  def test_instance_wsat_vrat_soucet_vah
    @spol_instance.nacti_data(ModifikatorInstanci.new(@pole,10).vrat_modif_instanci, -1)
    soucet = @spol_instance.pole_vah[0] + @spol_instance.pole_vah[1]+@spol_instance.pole_vah[2]
 
    assert_equal(soucet, @spol_instance.vrat_soucet_vah([true,true,true,false]))
  end

  def test_krizeni_vytvoreni
    krizeni = Krizeni.new([true, true, true, true],[false, false, false, false])
    refute_nil(krizeni, "Objekt krizeni ze tridy Krizeni by mel byt vytvoren.")  
  end

  def test_krizeni_nastaveni_param
    krizeni = Krizeni.new([true, true, true, true],[false, false, false, false])
    assert_equal([true, true, true, true], krizeni.vektor_a) 
    assert_equal([false, false, false, false], krizeni.vektor_b) 
  end

  def test_wsat_hrubou_silou_vytvoreni
    solver = WSATHrubouSilou.new(true)
    refute_nil(solver, "Objekt solver ze tridy WSATHrubouSilou by mel byt vytvoren.")  
  end

  def test_wsat_hrubou_silou_nastaveni_param
    solver = WSATHrubouSilou.new(true)
    assert_equal(nil, solver.nejlepsi_reseni)  
  end

  def test_wsat_hrubou_silou_start
    solver = WSATHrubouSilou.new(true)
    
    vystup = ModifikatorInstanci.new(@pole,10).vrat_modif_instanci
    
    @spol_instance.nacti_data(vystup, -1)
    
    instance = solver.start(@spol_instance)
    
    assert_equal([true,true,true,false], instance.reseni)  
    assert_equal(true, instance.je_splnitelna)
    refute_equal(0, instance.vysledny_soucet_vah)
  end

   def test_wsat_genetikou_vytvoreni
    solver = WSATGenetikou.new
    refute_nil(solver, "Objekt solver ze tridy WSATGenetikou by mel byt vytvoren.")  
  end

  # POZN. Geneticky alg. je dosti nahodny, proto zde neuvadim zadne testy, ktere bych musel vzdy upravovat podle vygenerovanych nahodnych cisel (byly by zavisle).
  

end
