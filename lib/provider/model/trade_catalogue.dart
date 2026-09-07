import 'package:local_markerplace/provider/model/provider_service.dart';
import 'package:local_markerplace/provider/model/store_product.dart';

/// What a trade does and what it sells.
///
/// There are eighty-odd providers in the seed and only a handful could ever
/// be written by hand, so a profile is built from its trade instead: an
/// electrician offers electrical work and stocks electrical parts, and which
/// of them is decided per provider. Two electricians therefore read as two
/// businesses rather than one repeated, without anybody having to write
/// eighty catalogues.
class TradeCatalogue {
  const TradeCatalogue({
    required this.services,
    required this.products,
    required this.about,
    required this.reviews,
  });

  final List<ProviderService> services;
  final List<StoreProduct> products;

  /// Sentence for the About tab, with `{area}` standing in for the locality.
  final String about;

  /// Things people say about this trade, drawn on per provider.
  final List<String> reviews;

  /// The catalogue for [trade], falling back to general repairs for a trade
  /// nobody has written one for.
  static TradeCatalogue of(String trade) {
    // A provider can carry two trades ("AC Repair · RO Repair"); the first
    // is the one they lead with, so it is the one that shapes the page.
    final lead = trade.split('·').first.trim();
    return _byTrade[lead] ?? _general;
  }

  static const _electrician = TradeCatalogue(
    about:
        'Wiring, fittings and repairs across {area}. Same-day call-outs for '
        'anything that has stopped working.',
    services: [
      ProviderService(
        name: 'Switchboard & Socket Fix',
        fromPrice: 'from ₹249',
        detail: 'Loose points, tripping, new sockets',
      ),
      ProviderService(
        name: 'Fan Installation',
        fromPrice: 'from ₹299',
        detail: 'Ceiling or wall, regulator included',
      ),
      ProviderService(
        name: 'Light & Fixture Fitting',
        fromPrice: 'from ₹199',
        detail: 'Panels, strips and chandeliers',
      ),
      ProviderService(
        name: 'Inverter & Wiring Check',
        fromPrice: 'from ₹399',
        detail: 'Load test, battery and connections',
      ),
      ProviderService(
        name: 'MCB & Fuse Replacement',
        fromPrice: 'from ₹349',
        detail: 'Repeated tripping and burnt points',
      ),
      ProviderService(
        name: 'Full House Rewiring',
        fromPrice: 'from ₹4,999',
        detail: 'Quoted after a site visit',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Modular Switch (16A)',
        price: '₹180',
        stockLabel: 'In stock',
        detail: 'Fits standard modular plates. Sold singly.',
        fittingName: 'Switchboard & Socket Fix',
        fittingFrom: '₹249',
      ),
      StoreProduct(
        name: 'MCB 32A Single Pole',
        price: '₹340',
        stockLabel: 'In stock',
        detail: 'ISI marked, for lighting and socket circuits.',
        fittingName: 'MCB & Fuse Replacement',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Ceiling Fan Regulator',
        price: '₹260',
        stockLabel: 'In stock',
        detail: 'Step-type, works with most ceiling fans.',
        fittingName: 'Fan Installation',
        fittingFrom: '₹299',
      ),
      StoreProduct(
        name: 'LED Panel 18W',
        price: '₹420',
        stockLabel: 'In stock',
        detail: 'Recessed round panel, neutral white.',
        fittingName: 'Light & Fixture Fitting',
        fittingFrom: '₹199',
      ),
      StoreProduct(
        name: 'Copper Wire 90m (1.5 sq mm)',
        price: '₹1,450',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'FR grade, for lighting circuits.',
      ),
      StoreProduct(
        name: 'Extension Board 4-Socket',
        price: '₹520',
        stockLabel: 'In stock',
        detail: 'Two metre lead with individual switches.',
      ),
    ],
    reviews: [
      'Fixed the tripping in ten minutes and explained what caused it.',
      'Came on time, tidy work, charged what was quoted.',
      'Rewired the kitchen points properly. No complaints since.',
    ],
  );

  static const _plumber = TradeCatalogue(
    about:
        'Taps, drains and fittings across {area}. Leaks attended the same '
        'day wherever possible.',
    services: [
      ProviderService(
        name: 'Tap & Mixer Repair',
        fromPrice: 'from ₹249',
        detail: 'Dripping taps, cartridge replaced',
      ),
      ProviderService(
        name: 'Blocked Drain Clearing',
        fromPrice: 'from ₹499',
        detail: 'Kitchen, bathroom or balcony line',
      ),
      ProviderService(
        name: 'Geyser Installation',
        fromPrice: 'from ₹699',
        detail: 'Wall mount with inlet and outlet',
      ),
      ProviderService(
        name: 'Flush Tank Repair',
        fromPrice: 'from ₹349',
        detail: 'Running cistern, worn washers',
      ),
      ProviderService(
        name: 'Leak Detection',
        fromPrice: 'from ₹599',
        detail: 'Damp walls and hidden pipe leaks',
      ),
      ProviderService(
        name: 'Bathroom Fittings Change',
        fromPrice: 'from ₹899',
        detail: 'Shower, health faucet and pipes',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Health Faucet with Hose',
        price: '₹640',
        stockLabel: 'In stock',
        detail: 'ABS body, one metre steel hose.',
        fittingName: 'Bathroom Fittings Change',
        fittingFrom: '₹899',
      ),
      StoreProduct(
        name: 'Tap Cartridge (35 mm)',
        price: '₹220',
        stockLabel: 'In stock',
        detail: 'Fits most single-lever mixers.',
        fittingName: 'Tap & Mixer Repair',
        fittingFrom: '₹249',
      ),
      StoreProduct(
        name: 'PVC Pipe 1 inch (3 m)',
        price: '₹310',
        stockLabel: 'In stock',
        detail: 'ISI marked, for drain and supply lines.',
      ),
      StoreProduct(
        name: 'Flush Tank Repair Kit',
        price: '₹480',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Float valve, washers and flush button.',
        fittingName: 'Flush Tank Repair',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Overhead Shower 6 inch',
        price: '₹890',
        stockLabel: 'In stock',
        detail: 'Stainless face with anti-clog nozzles.',
        fittingName: 'Bathroom Fittings Change',
        fittingFrom: '₹899',
      ),
      StoreProduct(
        name: 'Angle Valve (brass)',
        price: '₹350',
        stockLabel: 'In stock',
        detail: 'Quarter-turn, chrome finish.',
      ),
    ],
    reviews: [
      'Found the leak behind the wall without breaking half the bathroom.',
      'Cleared the kitchen drain and cleaned up after.',
      'Fair price for the geyser fitting, works fine.',
    ],
  );

  static const _acRepair = TradeCatalogue(
    about:
        'Split and window AC servicing across {area}. Gas, cooling and '
        'noise complaints handled.',
    services: [
      ProviderService(
        name: 'AC Servicing',
        fromPrice: 'from ₹499',
        detail: 'Split & window, gas top-up extra',
      ),
      ProviderService(
        name: 'AC Gas Refill',
        fromPrice: 'from ₹1,800',
        detail: 'R32 or R410a, pressure tested after',
      ),
      ProviderService(
        name: 'AC Installation',
        fromPrice: 'from ₹1,299',
        detail: 'Wall mount, copper up to 3 m included',
      ),
      ProviderService(
        name: 'AC Uninstallation',
        fromPrice: 'from ₹699',
        detail: 'Safe gas recovery before removal',
      ),
      ProviderService(
        name: 'Cooling Complaint Check',
        fromPrice: 'from ₹399',
        detail: 'Diagnosis, waived if repaired here',
      ),
    ],
    products: [
      StoreProduct(
        name: 'AC Air Filter (split)',
        price: '₹450',
        stockLabel: 'In stock',
        detail: 'Washable mesh, pair for a 1.5 ton indoor unit.',
        fittingName: 'AC Servicing',
        fittingFrom: '₹499',
      ),
      StoreProduct(
        name: 'Copper Pipe Set (3 m)',
        price: '₹2,400',
        stockLabel: 'In stock',
        detail: 'Insulated pair with flare nuts, for installation.',
        fittingName: 'AC Installation',
        fittingFrom: '₹1,299',
      ),
      StoreProduct(
        name: 'AC Stabiliser 4kVA',
        price: '₹2,100',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Wide input range for up to 1.5 ton.',
      ),
      StoreProduct(
        name: 'Outdoor Unit Cover',
        price: '₹690',
        stockLabel: 'In stock',
        detail: 'UV-treated, fits most 1–1.5 ton condensers.',
      ),
      StoreProduct(
        name: 'Drain Pipe 5 m',
        price: '₹280',
        stockLabel: 'In stock',
        detail: 'Flexible corrugated pipe with clamp.',
      ),
    ],
    reviews: [
      'AC cools like new after the service. Explained the gas reading.',
      'Turned up in the evening slot as promised.',
      'Installed both units neatly, no mess left behind.',
    ],
  );

  static const _roRepair = TradeCatalogue(
    about:
        'Water purifier service and repair across {area}. Filters and '
        'membranes carried on the van.',
    services: [
      ProviderService(
        name: 'RO Filter Change',
        fromPrice: 'from ₹349',
        detail: 'Sediment, carbon and membrane',
      ),
      ProviderService(
        name: 'RO Service & Repair',
        fromPrice: 'from ₹499',
        detail: 'Leak, low output or no water',
      ),
      ProviderService(
        name: 'RO Installation',
        fromPrice: 'from ₹799',
        detail: 'Wall mount with tap and drain',
      ),
      ProviderService(
        name: 'Water Purifier AMC',
        fromPrice: 'from ₹1,999',
        detail: 'Two visits a year, parts at cost',
      ),
      ProviderService(
        name: 'TDS & Water Test',
        fromPrice: 'from ₹199',
        detail: 'Before and after the purifier',
      ),
    ],
    products: [
      StoreProduct(
        name: 'RO Filter Set (3 stage)',
        price: '₹1,200',
        stockLabel: 'In stock',
        detail:
            'Sediment, pre-carbon and post-carbon. Fits most domestic RO '
            'units. Sold as a set of three.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'RO Membrane 80 GPD',
        price: '₹1,800',
        stockLabel: 'In stock',
        detail:
            'Replaces the membrane when output drops or the water starts '
            'tasting flat. Lasts two to three years.',
        fittingName: 'RO Service & Repair',
        fittingFrom: '₹499',
      ),
      StoreProduct(
        name: 'Sediment Filter 10"',
        price: '₹350',
        stockLabel: 'In stock',
        detail:
            'Spun polypropylene, 5 micron. The first stage — change it every '
            'six months in hard water.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Carbon Filter Block',
        price: '₹450',
        stockLabel: 'In stock',
        detail:
            'Takes out chlorine and smell before the water reaches the '
            'membrane.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'RO Pump 100 GPD',
        price: '₹1,650',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Booster pump for low inlet pressure.',
        fittingName: 'RO Service & Repair',
        fittingFrom: '₹499',
      ),
      StoreProduct(
        name: 'Storage Tank 8L',
        price: '₹980',
        stockLabel: 'In stock',
        detail: 'Food-grade tank with float assembly.',
      ),
    ],
    reviews: [
      'Changed all three filters and showed me the TDS before and after.',
      'Water tastes right again. Quick job.',
      'Honest — told me the membrane had another year in it.',
    ],
  );

  static const _carpenter = TradeCatalogue(
    about:
        'Furniture and fittings work across {area}. Repairs, hinges and '
        'made-to-measure jobs.',
    services: [
      ProviderService(
        name: 'Furniture Repair',
        fromPrice: 'from ₹399',
        detail: 'Hinges, drawers and loose joints',
      ),
      ProviderService(
        name: 'Door & Lock Fitting',
        fromPrice: 'from ₹349',
        detail: 'Alignment, handles and new locks',
      ),
      ProviderService(
        name: 'Modular Shelf Fitting',
        fromPrice: 'from ₹899',
        detail: 'Wall shelves and wardrobe fittings',
      ),
      ProviderService(
        name: 'Wardrobe Repair',
        fromPrice: 'from ₹699',
        detail: 'Sliding channels and shutters',
      ),
      ProviderService(
        name: 'Custom Woodwork',
        fromPrice: 'from ₹2,499',
        detail: 'Quoted after measurements',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Soft-Close Hinge (pair)',
        price: '₹320',
        stockLabel: 'In stock',
        detail: 'Hydraulic, for 16–18 mm shutters.',
        fittingName: 'Furniture Repair',
        fittingFrom: '₹399',
      ),
      StoreProduct(
        name: 'Door Lock with Handle',
        price: '₹1,150',
        stockLabel: 'In stock',
        detail: 'Mortise lock, brushed steel, three keys.',
        fittingName: 'Door & Lock Fitting',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Wardrobe Sliding Channel',
        price: '₹780',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Bottom-roller set for two-shutter wardrobes.',
        fittingName: 'Wardrobe Repair',
        fittingFrom: '₹699',
      ),
      StoreProduct(
        name: 'Telescopic Drawer Slide',
        price: '₹440',
        stockLabel: 'In stock',
        detail: '18 inch pair, ball bearing.',
      ),
      StoreProduct(
        name: 'Wall Shelf Bracket (pair)',
        price: '₹260',
        stockLabel: 'In stock',
        detail: 'Powder-coated, holds up to 20 kg.',
        fittingName: 'Modular Shelf Fitting',
        fittingFrom: '₹899',
      ),
    ],
    reviews: [
      'Sorted the wardrobe doors that had been sticking for months.',
      'Neat work and cleaned up the sawdust.',
      'Made the shelf exactly to the size I asked for.',
    ],
  );

  static const _appliance = TradeCatalogue(
    about:
        'Home appliance repair across {area}. Washing machines, fridges, '
        'chimneys and microwaves.',
    services: [
      ProviderService(
        name: 'Washing Machine Repair',
        fromPrice: 'from ₹449',
        detail: 'Front and top load, drain and spin faults',
      ),
      ProviderService(
        name: 'Fridge Repair',
        fromPrice: 'from ₹599',
        detail: 'Cooling, compressor and gas',
      ),
      ProviderService(
        name: 'Chimney Deep Clean',
        fromPrice: 'from ₹899',
        detail: 'Filter, motor and duct',
      ),
      ProviderService(
        name: 'Microwave Repair',
        fromPrice: 'from ₹399',
        detail: 'Heating, turntable and panel faults',
      ),
      ProviderService(
        name: 'Appliance Installation',
        fromPrice: 'from ₹499',
        detail: 'Unboxing, levelling and first run',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Chimney Baffle Filter',
        price: '₹890',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail:
            'Stainless steel baffles for a 60 cm chimney. Dishwasher safe, '
            'sold as a pair.',
        fittingName: 'Chimney Deep Clean',
        fittingFrom: '₹899',
      ),
      StoreProduct(
        name: 'Washing Machine Inlet Hose',
        price: '₹340',
        stockLabel: 'In stock',
        detail: 'Two metre braided hose with connectors.',
        fittingName: 'Washing Machine Repair',
        fittingFrom: '₹449',
      ),
      StoreProduct(
        name: 'Fridge Door Gasket',
        price: '₹1,100',
        stockLabel: 'In stock',
        detail: 'Magnetic seal, cut to the common single-door size.',
        fittingName: 'Fridge Repair',
        fittingFrom: '₹599',
      ),
      StoreProduct(
        name: 'Chimney Motor (1200 m³/hr)',
        price: '₹3,400',
        stockLabel: 'In stock',
        detail:
            'Copper winding, one year warranty. Suits most wall-mounted '
            'chimneys up to 90 cm.',
        fittingName: 'Chimney Deep Clean',
        fittingFrom: '₹899',
      ),
      StoreProduct(
        name: 'Microwave Turntable Plate',
        price: '₹620',
        stockLabel: 'In stock',
        detail: '270 mm glass plate with roller ring.',
        fittingName: 'Microwave Repair',
        fittingFrom: '₹399',
      ),
    ],
    reviews: [
      'Washing machine drains properly now. Took half an hour.',
      'Chimney looks and sounds new after the clean.',
      'Diagnosed the fridge honestly instead of selling me a new one.',
    ],
  );

  static const _cleaning = TradeCatalogue(
    about:
        'Home and kitchen cleaning across {area}. Trained crews with their '
        'own machines and supplies.',
    services: [
      ProviderService(
        name: 'Full Home Deep Clean',
        fromPrice: 'from ₹2,499',
        detail: 'Two to three cleaners, 2BHK',
      ),
      ProviderService(
        name: 'Kitchen Deep Clean',
        fromPrice: 'from ₹1,199',
        detail: 'Cabinets, tiles and chimney face',
      ),
      ProviderService(
        name: 'Bathroom Deep Clean',
        fromPrice: 'from ₹599',
        detail: 'Descaling, grout and fittings',
      ),
      ProviderService(
        name: 'Sofa & Carpet Shampoo',
        fromPrice: 'from ₹899',
        detail: 'Wet vacuum, per three-seater',
      ),
      ProviderService(
        name: 'Move-in Clean',
        fromPrice: 'from ₹3,499',
        detail: 'Empty flat, top to bottom',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Bathroom Descaler 1L',
        price: '₹320',
        stockLabel: 'In stock',
        detail: 'Acid-free, safe on tiles and chrome.',
      ),
      StoreProduct(
        name: 'Kitchen Degreaser 1L',
        price: '₹380',
        stockLabel: 'In stock',
        detail: 'Cuts baked-on grease on chimneys and hobs.',
      ),
      StoreProduct(
        name: 'Microfibre Cloth (pack of 6)',
        price: '₹290',
        stockLabel: 'In stock',
        detail: 'Lint-free, colour-coded for each room.',
      ),
      StoreProduct(
        name: 'Floor Cleaner 5L',
        price: '₹640',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Concentrate, dilutes to fifty litres.',
      ),
      StoreProduct(
        name: 'Glass Cleaner with Wiper',
        price: '₹410',
        stockLabel: 'In stock',
        detail: 'Spray bottle with a squeegee head.',
      ),
    ],
    reviews: [
      'Kitchen looks like the day we moved in.',
      'Crew of three, finished in four hours, very thorough.',
      'Brought all their own machines and supplies.',
    ],
  );

  static const _pestControl = TradeCatalogue(
    about:
        'Licensed pest treatment across {area}. Odourless chemicals, safe '
        'for children and pets once dry.',
    services: [
      ProviderService(
        name: 'Cockroach Treatment',
        fromPrice: 'from ₹999',
        detail: 'Gel and spray, 45-day warranty',
      ),
      ProviderService(
        name: 'Termite Treatment',
        fromPrice: 'from ₹2,999',
        detail: 'Drill-and-fill, one year warranty',
      ),
      ProviderService(
        name: 'Bed Bug Treatment',
        fromPrice: 'from ₹1,799',
        detail: 'Two visits a fortnight apart',
      ),
      ProviderService(
        name: 'Mosquito Fogging',
        fromPrice: 'from ₹899',
        detail: 'Balconies and standing water',
      ),
      ProviderService(
        name: 'Rodent Control',
        fromPrice: 'from ₹1,299',
        detail: 'Baiting and entry sealing',
      ),
    ],
    products: [
      StoreProduct(
        name: 'Cockroach Gel Syringe',
        price: '₹380',
        stockLabel: 'In stock',
        detail: '30 g, covers a kitchen for a season.',
        fittingName: 'Cockroach Treatment',
        fittingFrom: '₹999',
      ),
      StoreProduct(
        name: 'Mosquito Mesh (per sq ft)',
        price: '₹95',
        stockLabel: 'In stock',
        detail: 'Fibreglass mesh for windows and balconies.',
      ),
      StoreProduct(
        name: 'Rodent Bait Station',
        price: '₹520',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail: 'Lockable, keeps bait away from children.',
        fittingName: 'Rodent Control',
        fittingFrom: '₹1,299',
      ),
      StoreProduct(
        name: 'Termite Spray 500ml',
        price: '₹640',
        stockLabel: 'In stock',
        detail: 'For touch-ups between treatments.',
      ),
    ],
    reviews: [
      'No roaches since the treatment. Came back for the free follow-up.',
      'Explained what they were spraying and how long to stay out.',
      'Sorted the termites in the wardrobe frame.',
    ],
  );

  static const _general = TradeCatalogue(
    about: 'General household repairs across {area}.',
    services: [
      ProviderService(
        name: 'Call-out & Diagnosis',
        fromPrice: 'from ₹299',
        detail: 'Waived if the job is done same visit',
      ),
      ProviderService(
        name: 'Small Repairs',
        fromPrice: 'from ₹399',
        detail: 'Odd jobs around the house',
      ),
    ],
    products: [],
    reviews: ['Quick and reasonable.', 'Turned up when they said they would.'],
  );

  static const Map<String, TradeCatalogue> _byTrade = {
    'Electrician': _electrician,
    'Plumber': _plumber,
    'AC Repair': _acRepair,
    'RO Repair': _roRepair,
    'Carpenter': _carpenter,
    'Appliance': _appliance,
    'Cleaning': _cleaning,
    'Pest control': _pestControl,
  };
}
