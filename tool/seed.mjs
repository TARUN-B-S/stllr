// One-time seed for Steller Market.
//
// Creates two demo accounts (a buyer and the demo seller) and populates the
// Firestore sample data so a fresh evaluator sees a live marketplace.
//
// Setup:
//   1. In the Firebase console: Project settings -> Service accounts ->
//      Generate new private key, save the file as `serviceAccount.json` in
//      this `tool/` folder.
//   2. cd tool && npm install
//   3. node seed.mjs
//
// Demo logins created:
//   buyer@steller.app  / demo1234   (buyer)
//   seller@steller.app / demo1234   (seller, premium)

import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp, FieldValue } from 'firebase-admin/firestore';

initializeApp({ credential: applicationDefault() });

const auth = getAuth();
const db = getFirestore();

const BUYER_UID = 'demo-buyer';
const SELLER_UID = 'demo-seller';
const BUYER2_UID = 'demo-buyer-2';

const secondsAgo = (s) => Timestamp.fromMillis(Date.now() - s * 1000);

async function ensureUser({ uid, email, password, name, role, phone, subscribed = false, location = '', bio = '' }) {
  let user;
  try {
    user = await auth.getUser(uid);
    console.log(`auth user exists: ${email} (${uid})`);
  } catch {
    user = await auth.createUser({ uid, email, password, displayName: name });
    console.log(`created auth user: ${email} (${uid})`);
  }
  await db.collection('users').doc(uid).set(
    { name, email, role, phone, location, bio, subscribed },
    { merge: true }
  );
  return { uid, name, email, role, subscribed };
}

const buyer = await ensureUser({
  uid: BUYER_UID,
  email: 'buyer@steller.app',
  password: 'demo1234',
  name: 'Aarav Mehta',
  role: 'buyer',
  phone: '+91 98765 43210',
  location: 'Bengaluru, Karnataka',
  bio: 'Looking for bulk electronics and office supplies.',
});

const seller = await ensureUser({
  uid: SELLER_UID,
  email: 'seller@steller.app',
  password: 'demo1234',
  name: 'Meera (Jay & Co.)',
  role: 'seller',
  phone: '+91 98123 45678',
  subscribed: true,
  location: 'Mumbai, Maharashtra',
  bio: 'Sourcing partner for electronics, printing and office furniture.',
});

await ensureUser({
  uid: BUYER2_UID,
  email: 'diya@steller.app',
  password: 'demo1234',
  name: 'Diya Sharma',
  role: 'buyer',
  phone: '+91 99000 11111',
});

async function ensureRequest(id, data) {
  const ref = db.collection('requests').doc(id);
  const snap = await ref.get();
  if (snap.exists) {
    console.log(`request exists: ${id}`);
    return;
  }
  await ref.set({
    createdAt: FieldValue.serverTimestamp(),
    responseCount: 0,
    ...data,
  });
  console.log(`created request: ${id}`);
}

await ensureRequest('req-earbuds', {
  title: '20 units wireless earbuds',
  category: 'Electronics',
  description: 'Looking for TWS earbuds with ANC, bulk order for a college fest. Need delivery within 3 weeks.',
  budget: '₹18,000 – ₹24,000',
  buyerId: buyer.uid,
  buyerName: buyer.name,
});

await ensureRequest('req-cards', {
  title: 'Custom wedding invitation cards',
  category: 'Printing',
  description: '500 premium cards with foil work and matching envelopes. Design help appreciated.',
  budget: '₹30,000',
  buyerId: BUYER2_UID,
  buyerName: 'Diya Sharma',
});

await ensureRequest('req-chairs', {
  title: 'Ergonomic office chairs x12',
  category: 'Furniture',
  description: 'Startup office, adjustable lumbar and headrest, warranty required.',
  budget: '₹72,000',
  buyerId: buyer.uid,
  buyerName: buyer.name,
});

await ensureRequest('req-cake', {
  title: 'Birthday cake, chocolate truffle 2kg',
  category: 'Bakery',
  description: 'Eggless, sugar-free option preferred, delivery to Koramangala on Saturday.',
  budget: '₹1,500',
  buyerId: BUYER2_UID,
  buyerName: 'Diya Sharma',
});

async function ensureChat(id, data, messages) {
  const ref = db.collection('chats').doc(id);
  const snap = await ref.get();
  if (snap.exists) {
    console.log(`chat exists: ${id}`);
    return;
  }
  await ref.set({ ...data, updatedAt: FieldValue.serverTimestamp() });
  for (const m of messages) {
    await ref.collection('messages').add({ ...m, createdAt: FieldValue.serverTimestamp() });
  }
  console.log(`created chat: ${id}`);
}

await ensureChat(
  'req-earbuds__demo-seller',
  {
    requestId: 'req-earbuds',
    requestTitle: '20 units wireless earbuds',
    buyerId: buyer.uid,
    buyerName: buyer.name,
    sellerId: seller.uid,
    sellerName: seller.name,
    participants: [buyer.uid, seller.uid],
    lastMessage: 'Sending the quote now.',
  },
  [
    { text: 'Hi! I saw your request for earbuds.', senderId: seller.uid },
    { text: 'Yes! Do you have ANC models in stock?', senderId: buyer.uid },
    { text: 'Yes, brand new with a 1-year warranty. Can we schedule a call?', senderId: seller.uid },
    { text: 'Sending the quote now.', senderId: seller.uid },
  ]
);

await ensureChat(
  'req-chairs__demo-seller',
  {
    requestId: 'req-chairs',
    requestTitle: 'Ergonomic office chairs x12',
    buyerId: buyer.uid,
    buyerName: buyer.name,
    sellerId: seller.uid,
    sellerName: seller.name,
    participants: [buyer.uid, seller.uid],
    lastMessage: 'Great, can you share the catalogue?',
  },
  [
    { text: 'Hello! We supply ergonomic chairs with 3-year warranty.', senderId: seller.uid },
    { text: 'Great, can you share the catalogue?', senderId: buyer.uid },
  ]
);

console.log('\nDone. Demo logins:');
console.log('  buyer@steller.app / demo1234');
console.log('  seller@steller.app / demo1234');
process.exit(0);
