class CategoryService {
  var categories = [

//    {
//      "category": "Fleisch",
//      "products": [
//        {"name":"Rindfleisch","category":"Fleisch"},{"name":"Faschiertes Fleisch","category":"Fleisch"},{"name":"Schweinefleisch","category":"Fleisch"},{"name":"Schnitzel","category":"Fleisch"},{"name":"Rindfleisch","category":"Fleisch"},{"name":"Hühnerfleisch","category":"Fleisch"},{"name":"Geflügel","category":"Fleisch"},{"name":"Schinken","category":"Fleisch"},{"name":"Salami","category":"Fleisch"},{"name":"Filet","category":"Fleisch"},{"name":"Dry Aged Beef","category":"Fleisch"},{"name":"Steak","category":"Fleisch"},{"name":"Beef","category":"Fleisch"},{"name":"Speck","category":"Fleisch"},{"name":"Hähnchenbrust","category":"Fleisch"},{"name":"Parmaschinken","category":"Fleisch"},{"name":"Gelbwurst","category":"Fleisch"},{"name":"Weißwurst","category":"Fleisch"},{"name":"Käsekrainer","category":"Fleisch"},{"name":"Leberkäse","category":"Fleisch"},{"name":"Käseleberkäse","category":"Fleisch"},{"name":"Extrawurst","category":"Fleisch"},{"name":"Putensalami","category":"Fleisch"},{"name":"Ungarische Salami","category":"Fleisch"},{"name":"Cabanossi","category":"Fleisch"}
//      ]
//    },
//    {
//      "category": "Gebäck",
//      "products":
//
//    },
    {
      "category": "Getränke",
      "products": [
        {"name":"Coca Cola ","category":"Getränke"},{"name":"Coca Cola Light","category":"Getränke"},{"name":"Coca Cola Zero","category":"Getränke"},{"name":"Fanta ","category":"Getränke"},{"name":"Sprite","category":"Getränke"},{"name":"Pepsi","category":"Getränke"},{"name":"Pepsi Max","category":"Getränke"},{"name":"Römerquelle still","category":"Getränke"},{"name":"Römerquelle mild","category":"Getränke"},{"name":"Römerquelle prickelnd","category":"Getränke"},{"name":"Schweppes Tonic","category":"Getränke"},{"name":"Schweppes Orange","category":"Getränke"},{"name":"Mezzo Mix","category":"Getränke"},{"name":"Red Bull","category":"Getränke"},{"name":"Red Bull Sugarfree","category":"Getränke"},{"name":"Red Bull Blue Edition","category":"Getränke"},{"name":"Red Bull Green Edition","category":"Getränke"},{"name":"Red Bull White Edition","category":"Getränke"},{"name":"Eistee Pfirsich","category":"Getränke"},{"name":"Eistee Zitrone","category":"Getränke"},{"name":"Orangensaft","category":"Getränke"},{"name":"Apfelsaft","category":"Getränke"},{"name":"Almdudler","category":"Getränke"},{"name":"Frucade","category":"Getränke"},{"name":"Eistee Pfirsich Zero","category":"Getränke"},{"name":"Eistee Zitrone Zero","category":"Getränke"},{"name":"Gröbi Orange-Maracuja","category":"Getränke"},{"name":"Gröbi Orange","category":"Getränke"},{"name":"Wasser","category":"Getränke"},{"name":"Mineralwasser","category":"Getränke"},{"name":"Vöslauer Ohne","category":"Getränke"},{"name":"Vöslauer Prickelnd","category":"Getränke"},{"name":"Tee","category":"Getränke"},{"name":"Schwarzer Tee","category":"Getränke"},{"name":"Früchtetee","category":"Getränke"},{"name":"Grüner Tee","category":"Getränke"},{"name":"Fencheltee","category":"Getränke"},{"name":"Kaffee","category":"Getränke"},{"name":"Kakao","category":"Getränke"}
      ]
    },
    {
      "category": "Gewürze & Würzmittel",
      "products": [
        { "name": "Salz", "category": "Gewürze & Würzmittel" },
        { "name": "Pfeffer", "category": "Gewürze & Würzmittel" },
        { "name": "Weißer Pfeffer", "category": "Gewürze & Würzmittel" },
        { "name": "Schwarzer Pfeffer", "category": "Gewürze & Würzmittel" },
        { "name": "Cayenpfeffer", "category": "Gewürze & Würzmittel" },
        { "name": "Szechuanpfeffer", "category": "Gewürze & Würzmittel" },
        { "name": "Safran", "category": "Gewürze & Würzmittel" },
        { "name": "Paprikapulver", "category": "Gewürze & Würzmittel" },
        { "name": "Oregano", "category": "Gewürze & Würzmittel" },
        { "name": "Curry", "category": "Gewürze & Würzmittel" },
        { "name": "Chili", "category": "Gewürze & Würzmittel" },
        { "name": "Schnittlauch", "category": "Gewürze & Würzmittel" },
        { "name": "Petersilie", "category": "Gewürze & Würzmittel" },
        { "name": "Ingwer", "category": "Gewürze & Würzmittel" },
        { "name": "Rosmarin", "category": "Gewürze & Würzmittel" },
        { "name": "Kümmel", "category": "Gewürze & Würzmittel" },
        { "name": "Koriander", "category": "Gewürze & Würzmittel" },
        { "name": "Kurkuma", "category": "Gewürze & Würzmittel" },
        { "name": "Thymian", "category": "Gewürze & Würzmittel" },
        { "name": "Apfelessig", "category": "Gewürze & Würzmittel" },
        { "name": "Tafelessig", "category": "Gewürze & Würzmittel" },
        { "name": "Essig", "category": "Gewürze & Würzmittel" },
        { "name": "Sojasoße", "category": "Gewürze & Würzmittel" },
        { "name": "Majoran", "category": "Gewürze & Würzmittel" },
        { "name": "Muskatnuss", "category": "Gewürze & Würzmittel" },
        { "name": "Salbei", "category": "Gewürze & Würzmittel" },
        { "name": "Vanilleschote", "category": "Gewürze & Würzmittel" },
        { "name": "Vanille", "category": "Gewürze & Würzmittel" },
        { "name": "Zimt", "category": "Gewürze & Würzmittel" },
        { "name": "MAGGI Würze", "category": "Gewürze & Würzmittel" },
        { "name": "Kren", "category": "Gewürze & Würzmittel" },
        { "name": "Basilikum", "category": "Gewürze & Würzmittel" },
        { "name": "Bärlauch", "category": "Gewürze & Würzmittel" },
        { "name": "Fenchel", "category": "Gewürze & Würzmittel" },
        { "name": "Gewürznelke", "category": "Gewürze & Würzmittel" },
        { "name": "Honig", "category": "Gewürze & Würzmittel" },
        { "name": "Knoblauch", "category": "Gewürze & Würzmittel" },
        { "name": "Kresse", "category": "Gewürze & Würzmittel" },
        { "name": "Lorbeerblatt", "category": "Gewürze & Würzmittel" },
        { "name": "Minze", "category": "Gewürze & Würzmittel" },
        { "name": "Trüffel", "category": "Gewürze & Würzmittel" },
        { "name": "Zucker", "category": "Gewürze & Würzmittel" },
        { "name": "Kardamom", "category": "Gewürze & Würzmittel" },
        { "name": "Schwarzer Kardamom", "category": "Gewürze & Würzmittel" },
        { "name": "Grüner Kardamom", "category": "Gewürze & Würzmittel" },
        { "name": "Sternanis", "category": "Gewürze & Würzmittel" },
        { "name": "Kapern", "category": "Gewürze & Würzmittel" }
      ]
    },
    {
      "category": "Haushalt",
      "products": [
        { "name": "Küchenrolle", "category": "Haushalt" },
        { "name": "Geschirrspülmittel", "category": "Haushalt" },
        { "name": "Waschmittel", "category": "Haushalt" },
        { "name": "Wettex", "category": "Haushalt" },
        { "name": "Schwämme", "category": "Haushalt" },
        { "name": "Servietten", "category": "Haushalt" },
        { "name": "Kaffeefilter", "category": "Haushalt" },
        { "name": "Entkalker", "category": "Haushalt" },
        { "name": "Müllsäcke", "category": "Haushalt" },
        { "name": "Fleckenentferner", "category": "Haushalt" },
        { "name": "Backpapier", "category": "Haushalt" },
        { "name": "Alufolie", "category": "Haushalt" },
        { "name": "Frischhaltefolie", "category": "Haushalt" },
        { "name": "Geschirrtücher", "category": "Haushalt" }
      ]
    },
    {
      "category": "Hygieneartikel",
      "products": [{"name":"Wattestäbchen","category":"Hygieneartikel"},{"name":"Windeln","category":"Hygieneartikel"},{"name":"Zahnbürste","category":"Hygieneartikel"},{"name":"Binden","category":"Hygieneartikel"},{"name":"Toilettenpapier","category":"Hygieneartikel"},{"name":"Feuchte Tücher","category":"Hygieneartikel"},{"name":"Zahnpasta","category":"Hygieneartikel"},{"name":"Seife","category":"Hygieneartikel"},{"name":"Deodorant","category":"Hygieneartikel"},{"name":"Taschentücher","category":"Hygieneartikel"},{"name":"Shampoo","category":"Hygieneartikel"},{"name":"Desinfektionsmittel","category":"Hygieneartikel"},{"name":"Pflaster","category":"Hygieneartikel"},{"name":"Zahnseide","category":"Hygieneartikel"},{"name":"Duschgel","category":"Hygieneartikel"},{"name":"Rasierer","category":"Hygieneartikel"},{"name":"Rasierschaum","category":"Hygieneartikel"},{"name":"After Shave","category":"Hygieneartikel"},{"name":"Pinzette","category":"Hygieneartikel"},{"name":"Nivea Creme","category":"Hygieneartikel"},{"name":"Mundspülung","category":"Hygieneartikel"},{"name":"Puder","category":"Hygieneartikel"},{"name":"Bodylotion","category":"Hygieneartikel"},{"name":"Wattepads","category":"Hygieneartikel"},{"name":"Vaseline","category":"Hygieneartikel"},{"name":"Labello","category":"Hygieneartikel"},{"name":"Zahnstocher","category":"Hygieneartikel"},{"name":"Klospray","category":"Hygieneartikel"},{"name":"Raumspray","category":"Hygieneartikel"}]
    },
    {
      "category": "Konserven",
      "products": [{"name":"Ananasstücke","category":"Konserven"},{"name":"Champignons","category":"Konserven"},{"name":"Mais","category":"Konserven"},{"name":"Kichererbsen","category":"Konserven"},{"name":"Erbsen","category":"Konserven"},{"name":"Linsen","category":"Konserven"},{"name":"Käferbohnen","category":"Konserven"},{"name":"Pizzasauce","category":"Konserven"},{"name":"Mandarin Orange","category":"Konserven"},{"name":"5-Frucht Cocktail","category":"Konserven"},{"name":"Tomaten","category":"Konserven"},{"name":"Pfirsiche","category":"Konserven"},{"name":"Rote Bohnen","category":"Konserven"},{"name":"Tomatensuppe","category":"Konserven"},{"name":"Thunfisch","category":"Konserven"},{"name":"Heringsfilet","category":"Konserven"},{"name":"Gefüllte Paprika","category":"Konserven"},{"name":"Chili Con Carne","category":"Konserven"},{"name":"Leberaufstrich","category":"Konserven"},{"name":"Pasteta Argeta","category":"Konserven"},{"name":"Fleischschmalz","category":"Konserven"},{"name":"Rindsgulasch","category":"Konserven"},{"name":"Leberknödelsuppe","category":"Konserven"},{"name":"Gulaschsuppe","category":"Konserven"},{"name":"Hühnersuppe","category":"Konserven"},{"name":"Linsensuppe","category":"Konserven"},{"name":"Reisfleisch","category":"Konserven"},{"name":"Hühnercurry","category":"Konserven"},{"name":"Linsen","category":"Konserven"},{"name":"Rindsuppe","category":"Konserven"},{"name":"Weiße Bohnen","category":"Konserven"}]
    },
    {
      "category": "Milchprodukte",
      "products":
      [{"name":"Milch","category":"Milchprodukte"},{"name":"Vanilletraum","category":"Milchprodukte"},{"name":"Milchschnitte","category":"Milchprodukte"},{"name":"Kingerpingui","category":"Milchprodukte"},{"name":"Butter","category":"Milchprodukte"},{"name":"Käse","category":"Milchprodukte"},{"name":"Joghurt","category":"Milchprodukte"},{"name":"Frischkäse","category":"Milchprodukte"},{"name":"Topfen","category":"Milchprodukte"},{"name":"Rahm","category":"Milchprodukte"},{"name":"Sahne","category":"Milchprodukte"},{"name":"Sauerrahm","category":"Milchprodukte"},{"name":"Gouda","category":"Milchprodukte"},{"name":"Cheddar","category":"Milchprodukte"},{"name":"Schmelzkäse","category":"Milchprodukte"},{"name":"Toastkäse","category":"Milchprodukte"},{"name":"Frischmilch","category":"Milchprodukte"},{"name":"Vollmilch","category":"Milchprodukte"},{"name":"Fruchtjoghurt","category":"Milchprodukte"},{"name":"Buttermilch","category":"Milchprodukte"},{"name":"Ayran","category":"Milchprodukte"},{"name":"Babybelle","category":"Milchprodukte"},{"name":"Cheesesticks","category":"Milchprodukte"},{"name":"Schlagobers","category":"Milchprodukte"},{"name":"Biomilch","category":"Milchprodukte"},{"name":"Milchreis","category":"Milchprodukte"},{"name":"Emmentaler","category":"Milchprodukte"},{"name":"Parmesan","category":"Milchprodukte"},{"name":"Mozzarella","category":"Milchprodukte"},{"name":"Schafskäse","category":"Milchprodukte"}]
    },
    {
      "category": "Obst & Gemüse",
      "products": [
        {"name":"Zwiebel","category":"Obst & Gemüse"},{"name":"Roter Zwiebel","category":"Obst & Gemüse"},{"name":"Apfel","category":"Obst & Gemüse"},{"name":"Orange","category":"Obst & Gemüse"},{"name":"Mango","category":"Obst & Gemüse"},{"name":"Maracuja","category":"Obst & Gemüse"},{"name":"Banane","category":"Obst & Gemüse"},{"name":"Pfirsich","category":"Obst & Gemüse"},{"name":"Dattel","category":"Obst & Gemüse"},{"name":"Mandarine","category":"Obst & Gemüse"},{"name":"Blutorange","category":"Obst & Gemüse"},{"name":"Paprika","category":"Obst & Gemüse"},{"name":"Birne","category":"Obst & Gemüse"},{"name":"Weintrauben","category":"Obst & Gemüse"},{"name":"Granatapfel","category":"Obst & Gemüse"},{"name":"Himbeeren","category":"Obst & Gemüse"},{"name":"Erdbeeren","category":"Obst & Gemüse"},{"name":"Brombeeren","category":"Obst & Gemüse"},{"name":"Heidelbeeren","category":"Obst & Gemüse"},{"name":"Nekterine","category":"Obst & Gemüse"},{"name":"Erbsen","category":"Obst & Gemüse"},{"name":"Karotte","category":"Obst & Gemüse"},{"name":"Zitrone","category":"Obst & Gemüse"},{"name":"Limette","category":"Obst & Gemüse"},{"name":"Frühlingszwiebel","category":"Obst & Gemüse"},{"name":"Erdäpfel","category":"Obst & Gemüse"},{"name":"Paradeiser","category":"Obst & Gemüse"},{"name":"Gurke","category":"Obst & Gemüse"},{"name":"Zucchini","category":"Obst & Gemüse"},{"name":"Karfiol","category":"Obst & Gemüse"},{"name":"Kiwi","category":"Obst & Gemüse"},{"name":"Eisbergsalat","category":"Obst & Gemüse"},{"name":"China Kohl","category":"Obst & Gemüse"},{"name":"Grüner Salat","category":"Obst & Gemüse"},{"name":"Vogerlsalat","category":"Obst & Gemüse"},{"name":"Roter Rüben Salat","category":"Obst & Gemüse"},{"name":"Rote Rüben","category":"Obst & Gemüse"},{"name":"Aubergine","category":"Obst & Gemüse"},{"name":"Kohl","category":"Obst & Gemüse"},{"name":"Rotkraut","category":"Obst & Gemüse"},{"name":"Avocado","category":"Obst & Gemüse"},{"name":"Litschi","category":"Obst & Gemüse"},{"name":"Artischocke","category":"Obst & Gemüse"}
      ]
    },
//    {
//      "category": "Soßen",
//      "products": [
//        { "name": "Käsesoße", "category": "Soßen" },
//        { "name": "Tabasco", "category": "Soßen" },
//        { "name": "Senf", "category": "Soßen" },
//        { "name": "Scharfer Senf", "category": "Soßen" },
//        { "name": "Milder Senf", "category": "Soßen" },
//        { "name": "Kremser Senf", "category": "Soßen" },
//        { "name": "Ketchup", "category": "Soßen" },
//        { "name": "BBQ Soße", "category": "Soßen" },
//        { "name": "Knoblauch Soße", "category": "Soßen" },
//        { "name": "Cocktail Soße", "category": "Soßen" },
//        { "name": "Mayonnaise 80%", "category": "Soßen" },
//        { "name": "Mayonnaise 25%", "category": "Soßen" },
//        { "name": "Mayonnaise 50%", "category": "Soßen" },
//        { "name": "Mayonnaise", "category": "Soßen" },
//        { "name": "Süß-Sauer Soße", "category": "Soßen" },
//        { "name": "Sauce Tartare", "category": "Soßen" },
//        { "name": "Sweet Chili Soße", "category": "Soßen" },
//        { "name": "Sour Cream Soße", "category": "Soßen" },
//        { "name": "Curry Soße", "category": "Soßen" },
//        { "name": "Curry Mango Soße", "category": "Soßen" },
//        { "name": "Pommes Frites Soße", "category": "Soßen" },
//        { "name": "Honig-Senf Soße", "category": "Soßen" },
//        { "name": "Karibik Soße", "category": "Soßen" },
//        { "name": "Kräuter Knoblauch Soße", "category": "Soßen" },
//        { "name": "Steak Soße", "category": "Soßen" },
//        { "name": "Burger Soße", "category": "Soßen" },
//        { "name": "Potato Wedges Soße", "category": "Soßen" }
//      ]
//    },
    {
      "category": "Spirituosen",
      "products": [
        {"name": "Bier", "category": "Spirituosen"},
        {"name": "Flasche Bier", "category": "Spirituosen"},
        {"name": "Kiste Bier", "category": "Spirituosen"},
        {"name": "Dose Bier", "category": "Spirituosen"},
        {"name": "Weizenbier", "category": "Spirituosen"},
        {"name": "Radler", "category": "Spirituosen"},
        {"name": "Cider", "category": "Spirituosen"},
        {"name": "Prosecco", "category": "Spirituosen"},
        {"name": "Jack Daniel's", "category": "Spirituosen"},
        {"name": "Eristoff Ice", "category": "Spirituosen"},
        {"name": "Eristoff Fire", "category": "Spirituosen"},
        {"name": "Eristoff Flash", "category": "Spirituosen"},
        {"name": "Wein", "category": "Spirituosen"},
        {"name": "Weißwein", "category": "Spirituosen"},
        {"name": "Rotwein", "category": "Spirituosen"},
        {"name": "Roséwein", "category": "Spirituosen"},
        {"name": "Süßwein", "category": "Spirituosen"},
        {"name": "Sekt", "category": "Spirituosen"},
        {"name": "Wodka", "category": "Spirituosen"},
        {"name": "Rum", "category": "Spirituosen"},
        {"name": "Gin", "category": "Spirituosen"},
        {"name": "Tequila", "category": "Spirituosen"},
        {"name": "Whiskey", "category": "Spirituosen"},
        {"name": "Bacardi", "category": "Spirituosen"},
        {"name": "Captain Morgan", "category": "Spirituosen"},
        {"name": "Champagner", "category": "Spirituosen"},
        {"name": "Eierlikör", "category": "Spirituosen"},
        {"name": "Met", "category": "Spirituosen"},
        {"name": "Martini", "category": "Spirituosen"},
        {"name": "Grüner Veltliner", "category": "Spirituosen"},
        {"name": "Chardonnay", "category": "Spirituosen"},
        {"name": "Welschriesling", "category": "Spirituosen"},
        {"name": "Stolichnaya Vodka", "category": "Spirituosen"},
        {"name": "Absolut Vodka", "category": "Spirituosen"},
        {"name": "Jim Beam", "category": "Spirituosen"},
        {"name": "Baileys", "category": "Spirituosen"},
        {"name": "Malibu Kokoslikör", "category": "Spirituosen"},
        {"name": "Aperol", "category": "Spirituosen"},
        {"name": "Jägermeister", "category": "Spirituosen"},
        {"name": "Marillen Likör", "category": "Spirituosen"}
      ]
    },
    {
      "category": "Süßigkeiten",
      "products":
      [{"name":"Schokosauce","category":"Süßigkeiten"},{"name":"Schokolade","category":"Süßigkeiten"},{"name":"Gummibären","category":"Süßigkeiten"},{"name":"Zuckerl","category":"Süßigkeiten"},{"name":"Kekse","category":"Süßigkeiten"},{"name":"Schokokekse","category":"Süßigkeiten"},{"name":"Lakritze","category":"Süßigkeiten"},{"name":"Esspapier","category":"Süßigkeiten"},{"name":"Schokoküsse","category":"Süßigkeiten"},{"name":"Überraschungsei","category":"Süßigkeiten"},{"name":"Schokoeier","category":"Süßigkeiten"},{"name":"Kaugummi","category":"Süßigkeiten"},{"name":"Karamellbonbons","category":"Süßigkeiten"},{"name":"Erdnussbutter","category":"Süßigkeiten"},{"name":"Knoppers","category":"Süßigkeiten"},{"name":"Chips","category":"Süßigkeiten"},{"name":"Paprikachips","category":"Süßigkeiten"},{"name":"Pringles","category":"Süßigkeiten"},{"name":"Schokohase","category":"Süßigkeiten"},{"name":"Kitkat","category":"Süßigkeiten"},{"name":"Oreo","category":"Süßigkeiten"},{"name":"Lachgummi","category":"Süßigkeiten"},{"name":"Schogetten","category":"Süßigkeiten"},{"name":"Nachos","category":"Süßigkeiten"},{"name":"Doritos","category":"Süßigkeiten"},{"name":"Donuts","category":"Süßigkeiten"},{"name":"Cupcakes","category":"Süßigkeiten"},{"name":"Schokokuchen","category":"Süßigkeiten"},{"name":"Sachertorte","category":"Süßigkeiten"}]
    },
    {
      "category": "Tiefkühlkost",
      "products": [
        {"name": "Twinni Eis", "category": "Tiefkühlkost"},
        {"name": "Jolly Eis", "category": "Tiefkühlkost"},
        {"name": "Magnum Classic", "category": "Tiefkühlkost"},
        {"name": "Magnum Pistazie", "category": "Tiefkühlkost"},
        {"name": "Magnum Mandel", "category": "Tiefkühlkost"},
        {"name": "Vanille Eis", "category": "Tiefkühlkost"},
        {"name": "Cornetto", "category": "Tiefkühlkost"},
        {"name": "Erdbeer Combino", "category": "Tiefkühlkost"},
        {"name": "Brickerl Eis", "category": "Tiefkühlkost"},
        {"name": "Tiefkühlpizza", "category": "Tiefkühlkost"},
        {"name": "Pommes Frites", "category": "Tiefkühlkost"},
        {"name": "Wedges", "category": "Tiefkühlkost"},
        {"name": "Kroketten", "category": "Tiefkühlkost"},
        {"name": "Röstinchen", "category": "Tiefkühlkost"},
        {"name": "Blattspinat", "category": "Tiefkühlkost"},
        {"name": "Germknödel", "category": "Tiefkühlkost"},
        {"name": "Erdbeerknödel", "category": "Tiefkühlkost"},
        {"name": "Mohr im Hemd", "category": "Tiefkühlkost"},
        {"name": "Semmelknödel", "category": "Tiefkühlkost"},
        {"name": "Leberknödel", "category": "Tiefkühlkost"},
        {"name": "Gemüse tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Erbsen tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Petersilie tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Kohlsprossen tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Fisolen tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Rotkraut tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Beeren-Mix", "category": "Tiefkühlkost"},
        {"name": "Piccolinis", "category": "Tiefkühlkost"},
        {"name": "Lasagne tiefgefroren", "category": "Tiefkühlkost"},
        {"name": "Eiswürfel", "category": "Tiefkühlkost"}
      ]
    },



  ];
}

final CategoryService categoryService = CategoryService();
