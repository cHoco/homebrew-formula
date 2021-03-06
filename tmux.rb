class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz"
  sha256 "55313e132f0f42de7e020bf6323a1939ee02ab79c48634aa07475db41573852b"
  revision 3

  bottle do
    cellar :any
    sha256 "249d37ae806e98d1827d1104174c9d446977c89ed5c3c761d8cff583cc8de43d" => :sierra
    sha256 "4b4bb6330ac0992d329dba3c95fd9f25a222a672e712f95ddd0c6c66ce3ba1bb" => :el_capitan
    sha256 "1eee1ba5746cf99aef9ffc30437651422af0b49082e8fd77f10fdc145ce60a81" => :yosemite
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    patch do
      url "https://gist.github.com/choco/1f9adeb42e6463ad8b2b7e7ff0ddc27b/raw"
      sha256 "d553a3a8fefafe2d5b639530a2e46cf62b860a80f04a772c6ea38fc6b77366c1"
    end

    patch do
      url "https://gist.github.com/choco/78b9af90b8992a8bda212e0aa28601f6/raw"
      sha256 "431e83744d627f9f45522696718fc71f29e1d0e9c9ce296de594e7db52f41221"
    end
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "utf8proc" => :optional

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  def install
    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-Dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    args << "--enable-utf8proc" if build.with?("utf8proc")

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats; <<-EOS.undent
    Example configuration has been installed to:
      #{opt_pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
