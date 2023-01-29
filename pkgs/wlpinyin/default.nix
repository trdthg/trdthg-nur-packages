{ lib
, stdenv
, fetchFromGitHub

, pkg-config
, ninja
, meson
, cmake
, wayland
, wayland-utils
, wayland-scanner
, wayland-protocols
, librime
, libxkbcommon
, tree
, ...
} @ args:

stdenv.mkDerivation rec {
  # 指定包名和版本
  pname = "wlpinyin";
  version = "0.1.0";

  # 从 GitHub 下载源代码
  src = fetchFromGitHub ({
    owner = "xhebox";
    repo = "wlpinyin";
    # 对应的 commit 或者 tag，注意 fetchFromGitHub 不能跟随 branch！
    rev = "7f2df900f6af76c9069764570626e85ba7c50203";
    # 下载 git submodules，绝大部分软件包没有这个
    fetchSubmodules = false;
    # 这里的 SHA256 校验码不会算怎么办？先注释掉，然后构建这个软件包，Nix 会报错，并提示你正确的校验码
    sha256 = "sha256-jHnNYYMXBCgxXqy7HQzeWxleG3x0KcDv+RdM6eCBWcQ=";
  });

  # 并行编译，大幅加快打包速度，默认是启用的。对于极少数并行编译会失败的软件包，才需要禁用。
  enableParallelBuilding = true;
  # 如果基于 CMake 的软件包在打包时出现了奇怪的错误，可以尝试启用此选项
  # 此选项禁用了对 CMake 软件包的一些自动修正
  # dontFixCmake = true;

  # nativeBuildInputs 指定的是只有在构建时用到，运行时不会用到的软件包
  # 例如这里的用来生成 Makefile 的 meson, ninja
  nativeBuildInputs = [ meson ninja tree ];

  # buildInputs 指定的是运行时也会用到的软件包
  buildInputs = [
    pkg-config
    wayland
    wayland-utils
    wayland-scanner
    wayland-protocols
    librime
    libxkbcommon
  ];

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
    meson build

    echo "----- before ninja build -----"
    pwd
    ls
    echo "----- ninja build -----"
    ninja -C build

    echo "----- check build dir -----"
    ls build
    tree .
  '';

  # 手动指定安装命令，把 oqsprovider.so 复制到 $out/lib 文件夹下
  # 一般来说可执行文件放在 $out/bin，库文件放在 $out/lib，菜单图标等放在 $out/share
  # 但并非强制，你在 $out 下随便放都可以，只不过在其它地方调用会麻烦一些
  #   mkdir -p $out/lib
  #   install -m755 oqsprov/oqsprovider.so "$out/lib"

  installPhase = ''
    mkdir -p $out/bin
    cp -r build/wlpinyin $out/bin
  '';

  # stdenv.mkDerivation 自动帮你完成其余的步骤
}
