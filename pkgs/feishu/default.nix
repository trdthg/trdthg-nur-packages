{ stdenv
, autoPatchelfHook
, makeWrapper
, lib
, callPackage
, tree


, at-spi2-atk
, at-spi2-core
, frame
, cups
, gtk3
, pango
, cairo
, gdk-pixbuf
, mesa

, libdrm
, libxkbcommon
, glib
, gnutls
, libgcrypt
  # , gcrypt
, xorg
, dbus
, nspr
, nss
, alsa-lib
, pixman
  # , pkg-config
, ...
} @ args:

stdenv.mkDerivation rec {
  # 指定包名和版本
  pname = "feishu";
  version = "0.1.0";

  # 从 GitHub 下载源代码
  # src = ./feishu.deb;

  # 并行编译，大幅加快打包速度，默认是启用的。对于极少数并行编译会失败的软件包，才需要禁用。
  enableParallelBuilding = true;
  # 如果基于 CMake 的软件包在打包时出现了奇怪的错误，可以尝试启用此选项
  # 此选项禁用了对 CMake 软件包的一些自动修正
  dontFixCmake = true;

  # nativeBuildInputs 指定的是只有在构建时用到，运行时不会用到的软件包
  # 例如这里的用来生成 Makefile 的 meson, ninja
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    tree
  ];

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz

    # 删除一些可以用系统库替代的库文件，和没用的 exe 等文件
  '';

  libraries = [
    makeWrapper
    alsa-lib

    at-spi2-atk
    at-spi2-core
    gtk3
    pango
    cairo
    pixman
    gdk-pixbuf
    mesa

    dbus
    glib
    gnutls
    libgcrypt
    nspr
    nss
    libdrm
    cups

    libxkbcommon
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libXcomposite
  ];

  # buildInputs 指定的是运行时也会用到的软件包
  buildInputs = libraries;

  # 在配置步骤（Configure phase）之前运行的命令
  preConfigure = ''
    echo "start..."
    pwd
    ls
  '';

  # # 传给 CMake 的配置参数，控制 liboqs 的功能
  # cmakeFlags = [
  #   # "-C build"
  #   # "-DBUILD_SHARED_LIBS=ON"
  #   # "-DOQS_BUILD_ONLY_LIB=1"
  #   # "-DOQS_USE_OPENSSL=OFF"
  #   # "-DOQS_DIST_BUILD=ON"
  # ];

  buildPhase = ''
    echo "----- before meson build -----"
    cd ..
    pwd
    ls
    echo "----- meson build-----"

    echo "----- before ninja build -----"
    pwd
    ls bin
    ls build
    echo "----- ninja build -----"

    echo "----- check build dir -----"
  '';

  # 手动指定安装命令，把 oqsprovider.so 复制到 $out/lib 文件夹下
  # 一般来说可执行文件放在 $out/bin，库文件放在 $out/lib，菜单图标等放在 $out/share
  # 但并非强制，你在 $out 下随便放都可以，只不过在其它地方调用会麻烦一些
  #   mkdir -p $out/lib
  #   install -m755 oqsprov/oqsprovider.so "$out/lib"

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp -r build/opt/bytedance/feishu/* $out

    # cp -r build/opt/bytedance/feishu/feishu $out/bin
    # cp -r build/opt/bytedance/feishu/bytedance-feishu $out/bin

    makeWrapper $out/feishu $out/bytedance-feishu \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"
  '';

  # stdenv.mkDerivation 自动帮你完成其余的步骤
}
