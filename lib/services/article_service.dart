import '../models/article.dart';

class ArticleService {
  Future<List<Article>> fetchArticles() async {
    // Simulate API network call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return dummy articles data
    return [
      Article(
        id: 1,
        title: 'Keajaiban Centella Asiatica untuk Kulit Sensitif',
        category: 'Kandungan Skincare',
        summary: 'Mengenal bahan alami penyembuh luka dan pereda kemerahan kulit yang legendaris.',
        content: 'Centella Asiatica, atau yang biasa dikenal sebagai daun pegagan, telah lama digunakan dalam pengobatan tradisional untuk menyembuhkan luka. Di dunia skincare modern, bahan aktif ini terkenal dengan nama "Cica". Kandungan saponin seperti asiaticoside, madecassoside, asiatic acid, dan madecassic acid di dalamnya terbukti ampuh meredakan inflamasi, memperkuat skin barrier, meningkatkan hidrasi, dan merangsang produksi kolagen.\n\nCica sangat direkomendasikan bagi pemilik kulit sensitif, berjerawat (acne-prone), serta kulit dengan kondisi skin barrier yang sedang rusak akibat eksfoliasi berlebih atau paparan sinar matahari.',
        imageUrl: 'assets/images/centella_asiatica.png',
      ),
      Article(
        id: 2,
        title: 'Tea Tree Oil: Solusi Ampuh Basmi Jerawat Membandel',
        category: 'Kandungan Skincare',
        summary: 'Cara kerja Tea Tree dalam mengatasi inflamasi dan mengontrol produksi sebum berlebih.',
        content: 'Tea Tree Oil berasal dari daun Melaleuca alternifolia, tanaman asli Australia. Bahan alami ini memiliki sifat antimikroba dan anti-inflamasi yang kuat. Penelitian menunjukkan bahwa Tea Tree dapat melawan bakteri Propionibacterium acnes penyebab jerawat dengan efektivitas yang hampir setara dengan benzoil peroksida, namun dengan efek samping kemerahan atau kulit mengelupas yang lebih minim.\n\nSelain mengatasi jerawat aktif, Tea Tree juga membantu mengontrol produksi sebum di wajah sehingga mencegah pori-pori tersumbat di kemudian hari. Disarankan untuk menggunakan tea tree oil dengan konsentrasi yang tepat atau mengencerkannya terlebih dahulu sebelum diaplikasikan langsung ke kulit sensitif.',
        imageUrl: 'assets/images/tea_tree.png',
      ),
      Article(
        id: 3,
        title: 'Manfaat Beras untuk Mencerahkan Wajah Sejak Dini',
        category: 'Kandungan Skincare',
        summary: 'Rahasia kecantikan tradisional Asia untuk kulit cerah merata dan bebas kusam.',
        content: 'Ekstrak beras (rice extract) telah digunakan sebagai rahasia kecantikan wanita Asia secara turun-temurun. Air cucian beras kaya akan vitamin B, vitamin E, serta mineral penting yang membantu mencerahkan kulit secara alami dan memudarkan noda hitam.\n\nKandungan asam ferulat dan allantoina dalam beras juga bertindak sebagai antioksidan serta agen anti-inflamasi yang menenangkan kulit terbakar matahari (sunburn). Skincare modern menggunakan ekstrak beras yang diformulasikan secara steril untuk memberikan efek hidrasi mendalam dan kecerahan kulit yang tahan lama.',
        imageUrl: 'assets/images/beras.png',
      ),
      Article(
        id: 4,
        title: 'Pentingnya Sunscreen: Lindungi Skin Barrier Setiap Hari',
        category: 'Kesehatan Kulit',
        summary: 'Alasan mengapa tabir surya adalah produk anti-aging paling krusial dalam rutinitas Anda.',
        content: 'Menggunakan pelembap dan serum terbaik akan sia-sia jika Anda melupakan tabir surya (sunscreen). Sinar ultraviolet (UV) dari matahari dapat menembus awan dan kaca jendela, merusak kolagen dan elastin kulit yang menyebabkan penuaan dini (photoaging), hiperpigmentasi, dan merusak pertahanan skin barrier.\n\nUntuk perlindungan harian, gunakan sunscreen dengan spektrum luas minimal SPF 30 dan PA+++. Aplikasikan sebanyak dua ruas jari di pagi hari, dan lakukan re-apply setiap 2-3 jam terutama jika Anda beraktivitas di luar ruangan.',
        imageUrl: 'assets/images/Image (Face scan).png',
      ),
      Article(
        id: 5,
        title: 'Mitos vs Fakta: Benarkah Kurang Tidur Bikin Kulit Kusam?',
        category: 'Kebiasaan Sehat',
        summary: 'Menjelaskan siklus regenerasi kulit di malam hari dan dampak kurang tidur bagi wajah.',
        content: 'Tidur malam yang cukup (7-8 jam) adalah bentuk perawatan kulit gratis yang paling efektif. Saat kita tertidur lelap, tubuh masuk ke fase regenerasi seluler di mana aliran darah ke kulit meningkat dan produksi kolagen baru terjadi.\n\nKurang tidur meningkatkan hormon kortisol (hormon stres) yang dapat merusak kualitas skin barrier, memicu jerawat, dan menghambat proses penyembuhan alami. Akibatnya, wajah tampak kusam, kering, dan lingkaran hitam di bawah mata menjadi lebih nyata di pagi hari.',
        imageUrl: 'assets/images/Home.png',
      ),
      Article(
        id: 6,
        title: 'Cara Tepat Mengetahui Jenis Kulit Wajah Anda',
        category: 'Kesehatan Kulit',
        summary: 'Panduan praktis membedakan kulit kering, berminyak, kombinasi, dan sensitif.',
        content: 'Mengetahui jenis kulit adalah langkah pertama sebelum membeli produk skincare. Anda dapat mengetahuinya dengan tes sederhana: cuci muka dengan facial cleanser lembut, tepuk-tepuk hingga kering, dan diamkan selama 30 menit tanpa memakai produk apa pun.\n\nJika setelah 30 menit wajah terasa kencang dan kasar, kulit Anda kering. Jika terlihat mengkilap di area T-zone dan pipi, kulit Anda berminyak. Jika minyak hanya di T-zone namun pipi terasa kering, Anda memiliki kulit kombinasi. Sedangkan kulit sensitif biasanya ditandai dengan rasa gatal, perih, atau kemerahan setelah dicuci.',
        imageUrl: 'assets/images/Login.png',
      ),
      Article(
        id: 7,
        title: 'Double Cleansing: Kunci Wajah Bersih Bebas Komedo',
        category: 'Kebiasaan Sehat',
        summary: 'Mengapa cuci muka sekali saja tidak cukup setelah seharian beraktivitas.',
        content: 'Double cleansing adalah metode membersihkan wajah dengan dua tahap. Tahap pertama menggunakan pembersih berbahan dasar minyak (micellar water, cleansing oil, atau cleansing balm) untuk mengangkat sisa sunscreen, makeup, dan sebum. Tahap kedua menggunakan pembersih berbahan dasar air (facial wash) untuk membersihkan sisa kotoran dan keringat hingga ke dalam pori-pori.\n\nMelakukan double cleansing setiap malam membantu mencegah penyumbatan pori-pori penyebab komedo dan jerawat, serta membuat penyerapan skincare berikutnya menjadi lebih optimal.',
        imageUrl: 'assets/images/Register.png',
      ),
      Article(
        id: 8,
        title: 'Hidrasi Kulit dari Dalam dengan Konsumsi Air Putih',
        category: 'Kebiasaan Sehat',
        summary: 'Hubungan asupan cairan harian dengan kekenyalan dan elastisitas kulit wajah.',
        content: 'Skincare topikal hanya bekerja pada lapisan luar kulit. Untuk mendapatkan kulit yang kenyal dan sehat dari dalam, tubuh memerlukan hidrasi yang cukup. Minum air putih minimal 2 liter per hari membantu membuang racun (detoksifikasi) dari dalam tubuh, melancarkan sirkulasi nutrisi ke sel-sel kulit, dan mempertahankan elastisitas jaringan kulit.\n\nJika tubuh dehidrasi, kulit akan tampak lebih layu, garis halus lebih terlihat, dan produksi minyak alami wajah bisa meningkat secara drastis sebagai reaksi pertahanan kulit.',
        imageUrl: 'assets/images/Image (Face scan).png',
      ),
    ];
  }
}
