bool isCountryBanned(String country) {
  return bannedCountries.contains(country);
}

final List<String> bannedCountries = [
  'Syria',
  'Iran',
  'North Korea',
  'Burma',
  'Russia',
  'Sudan',
  'Cuba',
  'Ukraine',
];


// Iran:
// Credit card transactions are blocked due to sanctions. 
// North Korea:
// Due to sanctions, transactions are not permitted. 
// Syria:
// Credit card transactions are blocked. 
// Sudan:
// Sanctions restrict the use of credit card products. 
// Russia:
// Visa and MasterCard products are restricted in Russia. 
// Ukraine:
// Certain regions of Ukraine are affected by these sanctions, and in some cases, transactions can be blocked. 
// Cuba:
// Some card networks block transactions in Cuba. 
// Myanmar (Burma):
// Sanctions restrict the use of credit card products. 