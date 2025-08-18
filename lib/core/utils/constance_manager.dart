class ConstanceManager {
  static String? sessionId;
  // static String? userTz;
  // static String? userLang;
  // static String? userName;
  // static String? userLogin;
  // static String? serverVersion;
  static int? userId;
  // static int? partnerId;
  static String? image;
  static DateTime? timeOut;
  static String? name;
  static String? workPhone;
  // static int? companyId;
  // static bool? isSystem;
  static const String amwal = "https://amwal.om/";
  static List<String> acTypes = const [
    'Split AC',
    'Window AC',
    'Central AC',
    'Cassette AC',
    'Duct AC',
    'VRF',
    'Protable AC',
    'Floor Stand AC',
    'Ceiling Mounted AC',
    'AHU Unit'
  ];
  static List<String> workStatusList = const [
    'Fault Report',
    'Work Completion Report',
    'Breakdown Service',
    'BER',
  ];
  static List<String> checkList = const [
    "Blower Motor - Measure Amperage & Voltage for proper operation",
    "Thermostat - test for proper operation, calibrate and level",
    "Clean existing air filter (as needed)",
    "Bearing - inspect for weak and lubricate",
    "Inspect Indoor Coil",
    "Condensate Vrain - Flush and treat with anti-algae",
    "Inspect Condenser Coil",
    "Refrigerant - Monitor Operating pressures",
    "Safety Devices - Inspect for proper operation",
    "Electrical Disconnect Box - Inspect for proper rating and safe installation",
    "Electrical Wiring - inspect and tighten connections",
    "Test/inspect contactors for burned/ pitted contacts",
    "Inspect electrical for exposed wiring",
    "Inspect and test capacitors",
    "Inspect fan Blade",
    "Clean Condenser Coil and Remove debris (Indoor)",
    "Clean Condenser Coil and Remove debris (Outdoor)",
    "Measure supply/return temperature differential",
    "Inspect duct work energy loss (if applicable)",
    "Compressor - monitor, measure amperage & volt draw and wiring connection",
    "Check condensate drain and pan and determine if any discrepancies",
  ];
  static List<String> faultCategories = const [
    "MEP",
    "Air Condition",
  ];
  static List<String> faultSubCategories1 = const [
    "Plumbing",
    "Carpentry",
    'Civil Work',
    'Electrical',
    "Mason",
    "Painting",
  ];
  static List<String> faultSubCategories2 = const [
    "Window AC",
    "Cassette AC",
    "Split AC",
    "Duct AC",
    "Chiller Unit",
    "VRF",
    "Portable AC",
    "Floor Stand AC",
    "Ceiling Mounted AC",
    "Central AC",
    "AHU Unit",
  ];
  static List<String> typeOfServiceList = const ["Wet", "Dry"];
  static List<String> amcCardQuestions = const [
    "Check and adjust thermostat",
    "Check the condenser coilto determine if it needs cleaning",
    "Check all the connections of electrical wiring and controls",
    "Check blower belt wear, tension it adjust (if applicable)",
    "Check voltage & amperage draw on all motors (with meter)",
    "Check compressor contactor",
    "Visual inspection of compressor and check amp draw",
    "Check start capacitor and potential relay",
    "Check pressure switch cut-out setting",
    "Replace air filter or clean the re-usable type filter",
    "Install gauges and check operating pressures",
    "Check refrigerant level and advice if adjustment is necessary",
    "Check Condensate drain and pan and determine if any discrepancies",
    "Check expansion valve and coil temperature",
    "Lubricates parts as needed",
    "Check evaporator coiland advise if dirty or ifit needs cleaning",
    "Check the shape that the total system isin and advise the client / Cnkiocver discrepancies:"
  ];
}
