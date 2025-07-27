# Rofi için Nişanyan Sözlük: Çağdaş Türkçenin Etimolojisi

Bu proje, [Rofi](https://github.com/davatorium/rofi) uygulama başlatıcısını kullanarak Sevan Nişanyan'ın Etimolojik Sözlüğü'nde hızlı ve çevrimdışı arama yapmanızı sağlar.\
[rofi-tdk.sh'tan](https://github.com/metwse/rofi-tdk.sh/tree/main) açıkça ilham alınarak tasarlanmıştır. O projeye de göz atmanız önerilir.

Tüm veritabanı yerel olarak saklandığı için anında arama yapar.\
Bir kelime aratıp anlamına baktıktan sonra geri döndüğünüzde, kelimenin kök hali tekrar Esc'e basana kadar ekranınızda kalır.\
Anlam ekranındaki satırlara tıklayarak Google'da arama yapabilir veya kelimenin web sitesindeki orijinal sayfasına ulaşabilirsiniz.

## Kurulum

Sisteminizde `rofi` ve `jq` paketlerinin kurulu olması gerekmektedir.

#### Adım 1: Dosyaları İndirin

Bu repodan `nisanyan-db.tar.gz` ve `rofi-nisanyan.sh` dosyalarını indirin ve ikisini de **Home klasörünüzde oluşturacağınız** **aynı klasörün içine** koyun. Örneğin: `~/rofi-nisanyan/`

#### Adım 2: Betiği Çalıştırılabilir Yapın

Terminali açın ve dosyaları koyduğunuz klasörün içindeyken aşağıdaki komutu çalıştırın:

```bash
chmod +x rofi-nisanyan.sh
 ```
Artık betiği doğrudan terminalden tam yolunu yazarak çalıştırabilirsiniz.

```bash
~/rofi-nisanyan/rofi-nisanyan.sh
 ```

## Daha hızlı erişim için, pencere yöneticinizin ayarlarından klavye kısayolu atayabilirsiniz.
##### i3wm/Sway için örnek:
```bash
bindsym $mod+n exec ~/rofi-nisanyan/rofi-nisanyan.sh\
 ```
##### Hyprland için örnek:
```bash
bind = $mainMod, N, exec, ~/rofi-nisanyan/rofi-nisanyan.sh
 ```

#### Projeyi kaldırmak için `~/rofi-nisanyan/` klasörünü silmeniz yeterlidir.

[Veritabanı için teşekkürler](https://www.kaggle.com/datasets/agmmnn/nisanyansozluk-updated)
