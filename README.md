# Rofi için Nişanyan Sözlük: Çağdaş Türkçenin Etimolojisi

Bu proje, [Rofi](https://github.com/davatorium/rofi) uygulama başlatıcısını kullanarak Sevan Nişanyan'ın Etimolojik Sözlüğü'nde hızlı ve çevrimdışı arama yapmanızı sağlayan bir betik içerir.
[rofi-tdk.sh'tan](https://github.com/metwse/rofi-tdk.sh/tree/main) açıkça ilham alınarak tasarlanmıştır. O sayfayı da ziyaret etmeniz önerilir.

Tüm veritabanı yerel olarak saklandığı için anında arama yapar. 
Bir kelime aratıp anlamına baktıktan sonra geri döndüğünüzde,kelimenin kök hali tekrar Esc'e basana kadar ekranınızda kalır
Anlam ekranındaki satırlara tıklayarak Google'da arama yapabilir veya kelimenin web sitesindeki orijinal sayfasına ulaşabilirsiniz.

## Kurulum

#### 1. Depoyu İndirin
Bu repodan `KURULUM.sh` ve `nisanyansozluk.tar.gz` dosyalarını aynı klasöre indirin.

#### 2. Bağımlılıkları Kurun
Kurulumun çalışması için sisteminizde `rofi` ve `jq` paketlerinin kurulu olması gerekir.

* **Arch Linux için:**
    ```bash
    sudo pacman -S rofi jq
    ```

* **Debian / Ubuntu için:**
    ```bash
    sudo apt install rofi jq
    ```

#### 3. Kurulumu Çalıştırın
İndirdiğiniz klasörün içinde terminali açın ve aşağıdaki komutları sırayla çalıştırın.

1.  **Veri Dosyasını Arşivden Çıkarın:**
    ```bash
    tar -xzf nisanyansozluk.json.tar.gz
    ```
    Bu komut, `nisanyansozluk.json` dosyasını oluşturacaktır.

2.  **Kurulum Betiğini Çalıştırın:**
    Betik, kurulum sırasında veritabanını ve diğer dosyaları oluşturup gerekli yerlere taşımak için sizden yönetici şifrenizi (`sudo`) isteyecektir.
    ```bash
    chmod +x KURULUM.sh
    ./KURULUM.sh
    ```
    Kurulum tamamlandığında, betik size sonraki adımları söyleyecektir.

#### 4. Uygulama Kısayolunu Yükleyin
Kurulum betiği, sizin için bir uygulama kısayolu da oluşturur. Bu kısayolu sisteminize tanıtmak için betiğin sonunda size önerilen şu komutları çalıştırın:
```bash
mv ~/scripts/rofi-nisanyan.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications/
 ```

#### 5. Daha hızlı erişim için, ~/scripts/rofi-nisanyan.sh komutunu kullandığınız pencere yöneticisinin ayarlarından  klavye kısayoluna atayabilirsiniz.
# i3wm/Sway için örnek:
bindsym $mod+n exec --no-startup-id ~/scripts/rofi-nisanyan.sh

# Hyprland için örnek:
bind = $mainMod, N, exec, ~/scripts/rofi-nisanyan.sh

#### Projeyi sisteminizden tamamen kaldırmak için aşağıdaki komutları terminalde çalıştırmanız yeterlidir:

# Sistem geneline kurulan veritabanını sil
sudo rm -f /usr/local/share/nisanyan-db.tar.gz

# Rofi betiğini ve kurulum dosyalarını içeren klasörü sil
rm -rf ~/scripts

# Uygulama kısayolunu sil
rm -f ~/.local/share/applications/rofi-nisanyan.desktop

# Rofi'nin çalışma zamanı önbelleğini sil
rm -rf /dev/shm/rofi-nisanyan-cache

# Uygulama menüsü veritabanını güncelle
update-desktop-database ~/.local/share/applications/

echo "Nişanyan Sözlük betiği sistemden kaldırıldı."

[Veritabanı için teşekkürler](https://www.kaggle.com/datasets/agmmnn/nisanyansozluk-updated)
