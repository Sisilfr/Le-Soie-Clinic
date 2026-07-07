import '../models/product.dart';

class ProductApiService {
  Future<List<Product>> fetchSkincareProducts() async {
    // Simulate API network call delay
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      Product(
        id: 101,
        title: 'Hydra-Glow Serum',
        description: 'Serum hidrasi mendalam dengan hyaluronic acid untuk wajah kenyal, segar, dan tampak bercahaya alami sepanjang hari.',
        price: 18.99,
        thumbnail: 'assets/images/Image (Hydra-Glow Serum).png',
        category: 'Serum',
        rating: 4.8,
      ),
      Product(
        id: 102,
        title: 'Niacinamide Pore Serum',
        description: 'Serum konsentrat Niacinamide untuk membantu menyamarkan pori-pori besar, meratakan warna kulit, dan mengontrol produksi minyak berlebih.',
        price: 16.50,
        thumbnail: 'assets/images/Image (Niacinamide Pore Serum).png',
        category: 'Serum',
        rating: 4.7,
      ),
      Product(
        id: 103,
        title: 'Calming Eye Cream',
        description: 'Krim mata lembut dengan formula menenangkan untuk mengurangi tampilan mata lelah, lingkaran hitam, dan kantung mata sembab.',
        price: 22.00,
        thumbnail: 'assets/images/Image (Calming Eye Cream).png',
        category: 'Eye Cream',
        rating: 4.9,
      ),
      Product(
        id: 104,
        title: 'Clarifying Toner',
        description: 'Toner eksfoliasi harian yang lembut untuk mengangkat sel kulit mati, membersihkan komedo, dan mencerahkan kulit kusam.',
        price: 14.99,
        thumbnail: 'assets/images/Image (Clarifying Toner).png',
        category: 'Toner',
        rating: 4.6,
      ),
      Product(
        id: 105,
        title: 'Gentle Foam Cleanser',
        description: 'Pembersih wajah dengan busa melimpah yang sangat lembut untuk membersihkan kotoran dan sisa debu tanpa menghilangkan kelembapan alami kulit.',
        price: 12.50,
        thumbnail: 'assets/images/Image (Gentle Foam Cleanser).png',
        category: 'Cleanser',
        rating: 4.5,
      ),
      Product(
        id: 106,
        title: 'Retinol Night Elixir',
        description: 'Elixir perawatan malam dengan kandungan Retinol aktif untuk mempercepat regenerasi sel kulit, mengurangi kerutan halus, dan memperbaiki tekstur kulit.',
        price: 24.99,
        thumbnail: 'assets/images/Image (Retinol Night Elixir).png',
        category: 'Elixir',
        rating: 4.8,
      ),
      Product(
        id: 107,
        title: 'Barrier Repair Cream',
        description: 'Krim pelembap intensif yang kaya akan ceramide untuk menutrisi, memperkuat, dan memulihkan pertahanan skin barrier yang rusak.',
        price: 19.50,
        thumbnail: 'assets/images/Image (Barrier Repair Cream).png',
        category: 'Moisturizer',
        rating: 4.7,
      ),
    ];
  }
}
