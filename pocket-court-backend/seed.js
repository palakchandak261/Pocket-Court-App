require('dotenv').config();
const connectDB = require('./config/db');
const Category = require('./models/Category');
const Law = require('./models/Law');

const laws = [
  { category: "Traffic Rules", situation: "Jumping traffic signal", act: "Motor Vehicles Act 1988", section: "Section 177", fine: "₹1000–₹5000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Not wearing seatbelt", act: "Motor Vehicles Act 1988", section: "Section 194B", fine: "₹1000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Using mobile phone while driving", act: "Motor Vehicles Act 1988", section: "Section 184", fine: "₹5000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Drunk driving", act: "Motor Vehicles Act 1988", section: "Section 185", fine: "₹10000 + imprisonment", article: "Article 21" },
  { category: "Traffic Rules", situation: "Driving without licence", act: "Motor Vehicles Act 1988", section: "Section 181", fine: "₹5000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Overspeeding", act: "Motor Vehicles Act 1988", section: "Section 183", fine: "₹1000–₹2000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Not wearing helmet", act: "Motor Vehicles Act 1988", section: "Section 129", fine: "₹1000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Driving without insurance", act: "Motor Vehicles Act 1988", section: "Section 196", fine: "₹2000", article: "Article 21" },
  { category: "Traffic Rules", situation: "Overloading vehicle", act: "Motor Vehicles Act 1988", section: "Section 194", fine: "₹2000 per tonne", article: "Article 21" },
  { category: "Traffic Rules", situation: "Wrong side driving", act: "Motor Vehicles Act 1988", section: "Section 184", fine: "₹5000", article: "Article 21" },

  // Consumer Rights
  { category: "Consumer Rights", situation: "No bill provided after purchase", act: "Consumer Protection Act 2019", section: "Section 2(47)", fine: "Penalty + complaint", article: "Article 14" },
  { category: "Consumer Rights", situation: "Fake or misleading advertisement", act: "Consumer Protection Act 2019", section: "Section 21", fine: "Penalty up to ₹10 lakh", article: "Article 14" },
  { category: "Consumer Rights", situation: "Restaurant forcing service charge", act: "Consumer Protection Act 2019", section: "Unfair Trade Practice", fine: "Refund + complaint", article: "Article 14" },
  { category: "Consumer Rights", situation: "Selling expired food items", act: "Food Safety and Standards Act 2006", section: "Section 26", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Consumer Rights", situation: "Defective product sold", act: "Consumer Protection Act 2019", section: "Section 2(10)", fine: "Replacement or refund", article: "Article 14" },
  { category: "Consumer Rights", situation: "Overcharging above MRP", act: "Consumer Protection Act 2019", section: "Section 2(47)", fine: "Refund + penalty", article: "Article 14" },
  { category: "Consumer Rights", situation: "Denial of warranty service", act: "Consumer Protection Act 2019", section: "Section 2(11)", fine: "Compensation", article: "Article 14" },
  { category: "Consumer Rights", situation: "Online shopping fraud", act: "Consumer Protection Act 2019", section: "Section 94", fine: "Penalty + refund", article: "Article 14" },

  // Public Rights
  { category: "Public Rights", situation: "Littering in public places", act: "Municipal Solid Waste Rules", section: "Local Municipal Act", fine: "₹500–₹5000", article: "Article 48A" },
  { category: "Public Rights", situation: "Noise pollution after allowed time", act: "Environment Protection Act 1986", section: "Noise Pollution Rules", fine: "₹10000", article: "Article 21" },
  { category: "Public Rights", situation: "Blocking public road illegally", act: "Indian Penal Code", section: "Section 283", fine: "₹200–₹500", article: "Article 19" },
  { category: "Public Rights", situation: "Unauthorized protest blocking traffic", act: "Indian Penal Code", section: "Section 341", fine: "Fine or imprisonment", article: "Article 19" },
  { category: "Public Rights", situation: "Spitting in public", act: "Municipal Corporation Act", section: "Local Bylaws", fine: "₹200–₹1000", article: "Article 21" },
  { category: "Public Rights", situation: "Urinating in public", act: "Municipal Corporation Act", section: "Local Bylaws", fine: "₹500", article: "Article 21" },
  { category: "Public Rights", situation: "Encroachment on public land", act: "Indian Penal Code", section: "Section 441", fine: "Fine + eviction", article: "Article 19" },

  // Women Safety
  { category: "Women Safety", situation: "Gender discrimination", act: "Equal Remuneration Act", section: "Section 4", fine: "Penalty", article: "Article 14" },
  { category: "Women Safety", situation: "Unequal pay for same work", act: "Equal Remuneration Act", section: "Section 4", fine: "Compensation", article: "Article 14" },
  { category: "Women Safety", situation: "Unsafe workplace conditions", act: "Factories Act 1948", section: "Section 7A", fine: "Employer penalty", article: "Article 21" },
  { category: "Women Safety", situation: "Eve teasing in public", act: "Indian Penal Code", section: "Section 509", fine: "Fine + imprisonment", article: "Article 14" },
  { category: "Women Safety", situation: "Domestic violence", act: "Protection of Women from Domestic Violence Act 2005", section: "Section 3", fine: "Imprisonment + fine", article: "Article 21" },
  { category: "Women Safety", situation: "Sexual harassment at workplace", act: "POSH Act 2013", section: "Section 9", fine: "Penalty + dismissal", article: "Article 14" },
  { category: "Women Safety", situation: "Stalking", act: "Indian Penal Code", section: "Section 354D", fine: "Imprisonment up to 3 years", article: "Article 21" },
  { category: "Women Safety", situation: "Dowry harassment", act: "Dowry Prohibition Act 1961", section: "Section 4", fine: "₹15000 + imprisonment", article: "Article 14" },

  // Cyber Crime
  { category: "Cyber Crime", situation: "Identity theft", act: "Information Technology Act 2000", section: "Section 66C", fine: "₹1 lakh + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Cyber bullying", act: "Information Technology Act 2000", section: "Section 66A", fine: "Penalty", article: "Article 21" },
  { category: "Cyber Crime", situation: "Fake social media profiles", act: "Information Technology Act 2000", section: "Section 66D", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Phishing scams", act: "Information Technology Act 2000", section: "Section 66D", fine: "₹1 lakh + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Hacking into someone's account", act: "Information Technology Act 2000", section: "Section 66", fine: "₹5 lakh + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Sharing private images without consent", act: "Information Technology Act 2000", section: "Section 66E", fine: "₹2 lakh + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Online financial fraud", act: "Information Technology Act 2000", section: "Section 66C/66D", fine: "₹1 lakh + imprisonment", article: "Article 21" },
  { category: "Cyber Crime", situation: "Spreading fake news online", act: "Information Technology Act 2000", section: "Section 505 IPC", fine: "Imprisonment up to 3 years", article: "Article 19" },

  // Labour Rights
  { category: "Labour Rights", situation: "Forced labour", act: "Bonded Labour System Abolition Act", section: "Section 4", fine: "Penalty + imprisonment", article: "Article 23" },
  { category: "Labour Rights", situation: "Employer not paying minimum wage", act: "Minimum Wages Act 1948", section: "Section 12", fine: "Compensation + penalty", article: "Article 23" },
  { category: "Labour Rights", situation: "Unsafe factory conditions", act: "Factories Act 1948", section: "Section 7A", fine: "Employer penalty", article: "Article 21" },
  { category: "Labour Rights", situation: "Denial of worker leave", act: "Factories Act 1948", section: "Section 79", fine: "Penalty", article: "Article 21" },
  { category: "Labour Rights", situation: "Child labour", act: "Child Labour Prohibition Act 1986", section: "Section 3", fine: "₹20000–₹50000 + imprisonment", article: "Article 24" },
  { category: "Labour Rights", situation: "Wrongful termination", act: "Industrial Disputes Act 1947", section: "Section 25F", fine: "Compensation + reinstatement", article: "Article 21" },
  { category: "Labour Rights", situation: "No provident fund deduction", act: "Employees Provident Fund Act 1952", section: "Section 6", fine: "Penalty + arrears", article: "Article 21" },
  { category: "Labour Rights", situation: "Denial of maternity leave", act: "Maternity Benefit Act 1961", section: "Section 5", fine: "Penalty + compensation", article: "Article 21" },

  // Tenant Rights
  { category: "Tenant Rights", situation: "Illegal eviction by landlord", act: "Rent Control Act", section: "State Law", fine: "Legal complaint", article: "Article 21" },
  { category: "Tenant Rights", situation: "Housing discrimination", act: "Human Rights Act", section: "Anti discrimination rules", fine: "Complaint", article: "Article 14" },
  { category: "Tenant Rights", situation: "Restriction on residence rights", act: "Indian Constitution", section: "Article 19", fine: "Legal complaint", article: "Article 19" },
  { category: "Tenant Rights", situation: "Unsafe living conditions", act: "Municipal Housing Rules", section: "Safety Regulations", fine: "Penalty", article: "Article 21" },
  { category: "Tenant Rights", situation: "Denial of basic amenities", act: "Rent Control Act", section: "Tenant Protection Rules", fine: "Complaint", article: "Article 21" },
  { category: "Tenant Rights", situation: "Landlord entering without notice", act: "Rent Control Act", section: "Tenant Rights", fine: "Legal complaint", article: "Article 21" },
  { category: "Tenant Rights", situation: "Illegal rent hike", act: "Rent Control Act", section: "Section 6", fine: "Refund + penalty", article: "Article 14" },

  // Environmental Rights
  { category: "Environmental Rights", situation: "Illegal cutting of trees", act: "Forest Conservation Act 1980", section: "Section 2", fine: "Penalty + imprisonment", article: "Article 48A" },
  { category: "Environmental Rights", situation: "Air pollution by industry", act: "Air Pollution Act 1981", section: "Section 21", fine: "Penalty + imprisonment", article: "Article 48A" },
  { category: "Environmental Rights", situation: "Wildlife poaching", act: "Wildlife Protection Act 1972", section: "Section 9", fine: "₹25000 + imprisonment", article: "Article 48A" },
  { category: "Environmental Rights", situation: "Dumping waste in water bodies", act: "Water Prevention Act 1974", section: "Section 24", fine: "Penalty + imprisonment", article: "Article 48A" },
  { category: "Environmental Rights", situation: "Burning crop stubble", act: "Environment Protection Act 1986", section: "Section 5", fine: "₹2500–₹15000", article: "Article 48A" },
  { category: "Environmental Rights", situation: "Plastic pollution", act: "Plastic Waste Management Rules 2016", section: "Rule 4", fine: "₹500–₹25000", article: "Article 48A" },

  // Banking Rights
  { category: "Banking Rights", situation: "Bank denying account opening", act: "RBI Banking Guidelines", section: "Customer Rights Charter", fine: "Complaint to RBI", article: "Article 14" },
  { category: "Banking Rights", situation: "Unfair loan terms", act: "RBI Fair Practices Code", section: "Loan Guidelines", fine: "Complaint", article: "Article 14" },
  { category: "Banking Rights", situation: "ATM wrong deduction", act: "RBI ATM Rules", section: "Customer Protection", fine: "Refund within 7 days", article: "Article 14" },
  { category: "Banking Rights", situation: "Bank not resolving complaint", act: "Banking Ombudsman Scheme", section: "Clause 8", fine: "Escalate to Ombudsman", article: "Article 14" },
  { category: "Banking Rights", situation: "Unauthorized transaction", act: "RBI Circular on Fraud", section: "Customer Liability Rules", fine: "Full refund if reported in 3 days", article: "Article 14" },
  { category: "Banking Rights", situation: "Cheque bounce", act: "Negotiable Instruments Act 1881", section: "Section 138", fine: "2x cheque amount + imprisonment", article: "Article 14" },
  { category: "Banking Rights", situation: "Loan recovery harassment", act: "RBI Fair Practices Code", section: "Recovery Guidelines", fine: "Complaint to RBI/Ombudsman", article: "Article 21" },

  // Digital Payments & UPI Safety
  { category: "Digital Payments & UPI Safety", situation: "UPI payment sent to wrong person", act: "RBI Guidelines", section: "Customer Protection Rules", fine: "Refund subject to verification", article: "Article 14" },
  { category: "Digital Payments & UPI Safety", situation: "Fake payment screenshot shown", act: "Indian Penal Code", section: "Section 420", fine: "Fraud penalty + imprisonment", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "QR code scam", act: "Information Technology Act 2000", section: "Section 66D", fine: "Up to ₹1 lakh + imprisonment", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Unauthorized bank transaction", act: "RBI Guidelines", section: "Zero Liability Policy", fine: "Full refund", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "OTP shared and money deducted", act: "Information Technology Act 2000", section: "Section 66C", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Fraud call pretending to be bank", act: "Indian Penal Code", section: "Section 419", fine: "Fraud penalty", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Refund not received after online payment", act: "Consumer Protection Act 2019", section: "Section 2(11)", fine: "Compensation", article: "Article 14" },
  { category: "Digital Payments & UPI Safety", situation: "Payment deducted but not received", act: "RBI Guidelines", section: "Payment Settlement Rules", fine: "Refund within timeline", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Fake cashback or reward scam", act: "Information Technology Act 2000", section: "Section 66D", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "SIM swap fraud", act: "Information Technology Act 2000", section: "Section 66C", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Payment app hacked", act: "Information Technology Act 2000", section: "Section 43", fine: "Compensation", article: "Article 21" },
  { category: "Digital Payments & UPI Safety", situation: "Unknown auto debit from account", act: "RBI Guidelines", section: "Auto Debit Rules", fine: "Refund + penalty", article: "Article 21" },

  // Road Rage & Public Safety
  { category: "Road Rage & Public Safety", situation: "Road rage argument turning violent", act: "Indian Penal Code", section: "Section 351", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Verbal abuse by another driver", act: "Indian Penal Code", section: "Section 504", fine: "Fine + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Physical assault during traffic dispute", act: "Indian Penal Code", section: "Section 351", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Intentional vehicle blocking", act: "Motor Vehicles Act 1988", section: "Section 177", fine: "₹500", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Dangerous driving threatening others", act: "Motor Vehicles Act 1988", section: "Section 184", fine: "₹5000", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Damage to vehicle during fight", act: "Indian Penal Code", section: "Section 427", fine: "Compensation + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Hit and run case", act: "Motor Vehicles Act 1988", section: "Section 134", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Public threatening with weapon", act: "Indian Penal Code", section: "Section 506", fine: "Penalty + imprisonment", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Drunk person creating nuisance", act: "Indian Penal Code", section: "Section 510", fine: "Fine", article: "Article 21" },
  { category: "Road Rage & Public Safety", situation: "Group harassment in public", act: "Indian Penal Code", section: "Section 34", fine: "Penalty + imprisonment", article: "Article 21" },

  // Rental & Property Issues
  { category: "Rental & Property Issues", situation: "Security deposit not returned", act: "Indian Contract Act 1872", section: "Section 73", fine: "Compensation", article: "Article 14" },
  { category: "Rental & Property Issues", situation: "Rent increased without notice", act: "Rent Control Act", section: "State Rules", fine: "Complaint applicable", article: "Article 14" },
  { category: "Rental & Property Issues", situation: "Landlord entering without permission", act: "Indian Penal Code", section: "Section 441", fine: "Penalty", article: "Article 21" },
  { category: "Rental & Property Issues", situation: "Forced eviction without notice", act: "Rent Control Act", section: "Eviction Rules", fine: "Illegal eviction penalty", article: "Article 21" },
  { category: "Rental & Property Issues", situation: "No rental agreement provided", act: "Registration Act 1908", section: "Section 17", fine: "Penalty", article: "Article 14" },
  { category: "Rental & Property Issues", situation: "Refusal to return advance money", act: "Indian Contract Act 1872", section: "Section 73", fine: "Compensation", article: "Article 14" },
  { category: "Rental & Property Issues", situation: "Poor maintenance of rented property", act: "Rent Control Act", section: "Maintenance Rules", fine: "Complaint applicable", article: "Article 21" },
  { category: "Rental & Property Issues", situation: "Restriction on guests in rented house", act: "Fundamental Rights", section: "Personal Liberty", fine: "Challengeable", article: "Article 21" },
  { category: "Rental & Property Issues", situation: "Discrimination by landlord", act: "Indian Constitution", section: "Equality Law", fine: "Complaint applicable", article: "Article 14" },
  { category: "Rental & Property Issues", situation: "Cutting water or electricity intentionally", act: "Indian Penal Code", section: "Section 430", fine: "Penalty + imprisonment", article: "Article 21" },
];

// Build categories from laws data
const buildCategories = (laws) => {
  const map = {};
  laws.forEach(({ category, situation }) => {
    if (!map[category]) map[category] = [];
    if (!map[category].includes(situation)) map[category].push(situation);
  });
  return Object.entries(map).map(([category, situations]) => ({ category, situations }));
};

const seed = async () => {
  await connectDB();
  await Category.deleteMany({});
  await Law.deleteMany({});
  const categories = buildCategories(laws);
  await Category.insertMany(categories);
  await Law.insertMany(laws);
  console.log(`✅ Seeded ${categories.length} categories and ${laws.length} laws`);
  process.exit();
};

seed();
