require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Property = require('../models/Property');
const Review = require('../models/Review');
const Message = require('../models/Message');

const seed = async () => {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  // Clear existing data
  await User.deleteMany({});
  await Property.deleteMany({});
  await Review.deleteMany({});
  await Message.deleteMany({});
  console.log('Cleared existing data');

  // Create users
  const owner1 = await User.create({
    name: 'Rajesh Kumar',
    email: 'rajesh@demo.com',
    phone: '9876543210',
    password: 'password123',
    role: 'owner',
    bio: 'Experienced property owner with 10+ years in real estate.',
    avatar: 'https://ui-avatars.com/api/?name=Rajesh+Kumar&background=E76F51&color=fff'
  });

  const owner2 = await User.create({
    name: 'Priya Sharma',
    email: 'priya@demo.com',
    phone: '9876543211',
    password: 'password123',
    role: 'owner',
    bio: 'Property owner in Pune and Mumbai.',
    avatar: 'https://ui-avatars.com/api/?name=Priya+Sharma&background=2A9D8F&color=fff'
  });

  const tenant1 = await User.create({
    name: 'Amit Patel',
    email: 'amit@demo.com',
    phone: '9876543212',
    password: 'password123',
    role: 'tenant',
    bio: 'Working professional looking for affordable housing.',
    avatar: 'https://ui-avatars.com/api/?name=Amit+Patel&background=F4A261&color=fff'
  });

  const tenant2 = await User.create({
    name: 'Sneha Iyer',
    email: 'sneha@demo.com',
    phone: '9876543213',
    password: 'password123',
    role: 'tenant',
    bio: 'IT professional, clean and responsible tenant.',
    avatar: 'https://ui-avatars.com/api/?name=Sneha+Iyer&background=264653&color=fff'
  });

  console.log('Users created');

  // Create properties
  const props = await Property.insertMany([
    {
      ownerId: owner1._id,
      title: '2BHK Modern Apartment in Baner',
      description: 'Beautiful fully furnished 2BHK apartment in the heart of Baner. Spacious rooms, modern amenities, 24/7 security, and close to IT hubs. Ideal for working professionals.',
      price: 22000,
      location: { address: '12, Silver Springs Society, Baner Road', city: 'Pune', state: 'Maharashtra', pincode: '411045' },
      images: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'
      ],
      propertyType: 'apartment',
      furnishing: 'furnished',
      bedrooms: 2,
      bathrooms: 2,
      area: 950,
      amenities: ['WiFi', 'AC', 'Parking', 'Gym', 'Security', 'Power Backup'],
      deposit: 44000,
      isAvailable: true
    },
    {
      ownerId: owner1._id,
      title: '1BHK Studio in Koregaon Park',
      description: 'Cozy 1BHK studio apartment near Koregaon Park. Walking distance to restaurants, cafes and malls. Perfect for single professionals.',
      price: 15000,
      location: { address: '45, Orchid Complex, North Main Road', city: 'Pune', state: 'Maharashtra', pincode: '411001' },
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800'
      ],
      propertyType: 'studio',
      furnishing: 'semi-furnished',
      bedrooms: 1,
      bathrooms: 1,
      area: 550,
      amenities: ['AC', 'Security', 'Water Supply', 'Lift'],
      deposit: 30000,
      isAvailable: true
    },
    {
      ownerId: owner2._id,
      title: '3BHK Villa in Wakad',
      description: 'Spacious 3BHK independent villa with garden, private parking, and all modern amenities. Quiet neighborhood, great for families.',
      price: 38000,
      location: { address: '7, Lotus Garden, Wakad', city: 'Pune', state: 'Maharashtra', pincode: '411057' },
      images: [
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
        'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800'
      ],
      propertyType: 'villa',
      furnishing: 'furnished',
      bedrooms: 3,
      bathrooms: 3,
      area: 1800,
      amenities: ['Garden', 'Parking', 'Security', 'AC', 'Generator', 'Club House'],
      deposit: 76000,
      isAvailable: true
    },
    {
      ownerId: owner2._id,
      title: '2BHK Apartment in Kothrud',
      description: 'Well maintained 2BHK apartment in prime location of Kothrud. Easy access to schools, hospitals and public transport.',
      price: 18000,
      location: { address: '23, Shivam Apartments, Paud Road', city: 'Pune', state: 'Maharashtra', pincode: '411038' },
      images: [
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800'
      ],
      propertyType: 'apartment',
      furnishing: 'unfurnished',
      bedrooms: 2,
      bathrooms: 2,
      area: 850,
      amenities: ['Parking', 'Security', 'Water Supply', 'Society Maintenance'],
      deposit: 36000,
      isAvailable: true
    },
    {
      ownerId: owner1._id,
      title: 'Commercial Space in Hinjewadi',
      description: 'Prime commercial office space in the IT hub of Hinjewadi. Ideal for startups and small businesses.',
      price: 55000,
      location: { address: 'Phase 1, Hinjewadi IT Park', city: 'Pune', state: 'Maharashtra', pincode: '411057' },
      images: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800'
      ],
      propertyType: 'commercial',
      furnishing: 'furnished',
      bedrooms: 0,
      bathrooms: 2,
      area: 1200,
      amenities: ['High-speed Internet', 'AC', 'Lift', 'Parking', 'Security', 'Conference Room'],
      deposit: 110000,
      isAvailable: true
    }
  ]);

  console.log('Properties created');

  // Create reviews
  const review1 = await Review.create({
    reviewerId: tenant1._id,
    reviewedUserId: owner1._id,
    propertyId: props[0]._id,
    ratings: { behavior: 5, communication: 5, cleanliness: 4, payment: 5, maintenance: 4 },
    comment: 'Excellent landlord. Very responsive and helpful. The property was exactly as described. Highly recommend!',
    reviewType: 'tenant-to-owner'
  });

  const review2 = await Review.create({
    reviewerId: tenant2._id,
    reviewedUserId: owner1._id,
    propertyId: props[1]._id,
    ratings: { behavior: 4, communication: 4, cleanliness: 5, payment: 4, maintenance: 5 },
    comment: 'Great owner. Property is well maintained. Minor issues were resolved quickly.',
    reviewType: 'tenant-to-owner'
  });

  const review3 = await Review.create({
    reviewerId: owner1._id,
    reviewedUserId: tenant1._id,
    propertyId: props[0]._id,
    ratings: { behavior: 5, communication: 5, cleanliness: 5, payment: 5, maintenance: 4 },
    comment: 'Amit is an excellent tenant. Always pays rent on time and keeps the house very clean.',
    reviewType: 'owner-to-tenant'
  });

  const review4 = await Review.create({
    reviewerId: tenant1._id,
    reviewedUserId: owner2._id,
    propertyId: props[2]._id,
    ratings: { behavior: 4, communication: 3, cleanliness: 4, payment: 4, maintenance: 3 },
    comment: 'Decent owner. Communication could be improved but property is good.',
    reviewType: 'tenant-to-owner'
  });

  // Recalculate scores
  await (await require('../models/User').findById(owner1._id)).recalculateTrustScore();
  await (await require('../models/User').findById(owner2._id)).recalculateTrustScore();
  await (await require('../models/User').findById(tenant1._id)).recalculateTrustScore();

  console.log('Reviews created and trust scores updated');

  // Create messages
  await Message.create({
    senderId: tenant1._id,
    receiverId: owner1._id,
    propertyId: props[0]._id,
    content: 'Hello! I am interested in your 2BHK apartment in Baner. Is it still available?',
    messageType: 'inquiry'
  });

  await Message.create({
    senderId: owner1._id,
    receiverId: tenant1._id,
    propertyId: props[0]._id,
    content: 'Yes, it is available! Would you like to schedule a visit this weekend?',
    messageType: 'message'
  });

  await Message.create({
    senderId: tenant2._id,
    receiverId: owner2._id,
    propertyId: props[2]._id,
    content: 'Hi, I saw your villa listing. Can you share more details about the location?',
    messageType: 'inquiry'
  });

  console.log('Messages created');
  console.log('\n✅ Seed completed!');
  console.log('\nDemo Accounts:');
  console.log('Owner: rajesh@demo.com / password123');
  console.log('Owner: priya@demo.com / password123');
  console.log('Tenant: amit@demo.com / password123');
  console.log('Tenant: sneha@demo.com / password123');

  mongoose.disconnect();
};

seed().catch(err => {
  console.error(err);
  mongoose.disconnect();
  process.exit(1);
});
