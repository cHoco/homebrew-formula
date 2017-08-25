class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io"

  stable do
    url "https://github.com/neovim/neovim/archive/v0.2.0.tar.gz"
    sha256 "72e263f9d23fe60403d53a52d4c95026b0be428c1b9c02b80ab55166ea3f62b5"

    depends_on "luajit" => :build
  end

  bottle do
    sha256 "b04f8a559f1f17aef15699afb83be2a85b626a81dec72e1b686bcdf916456c01" => :sierra
    sha256 "5774c42876eeccfae2b242acdbda91f84761b9bb680e663a707b6a15667ff4a9" => :el_capitan
    sha256 "8a8e12c9082f67366f6bfd4780f262b935d033e5ade1a6ddf9fd6eb9cb9e0eba" => :yosemite
  end

  head do
    url "https://github.com/neovim/neovim.git"

    depends_on "luajit"
  end

  depends_on "cmake" => :build
  depends_on "lua@5.1" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "jemalloc"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "libvterm"
  depends_on "msgpack"
  depends_on "unibilium"
  depends_on :python if MacOS.version <= :snow_leopard

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.1-1.src.rock", :using => :nounzip
    sha256 "149be31e0155c4694f77ea7264d9b398dd134eca0d00ff03358d91a6cfb2ea9d"
  end

  resource "mpack" do
    url "https://luarocks.org/manifests/tarruda/mpack-1.0.6-0.src.rock", :using => :nounzip
    sha256 "9068d9d3f407c72a7ea18bc270b0fa90aad60a2f3099fa23d5902dd71ea4cd5f"
  end

  # disable bold text highlight inside terminal buffers
  patch :DATA

  # don't redraw tabline when completion popup is open
  patch do
    url "https://gist.githubusercontent.com/choco/facbfbf7b4912a5eb512102bac6b4c64/raw/4d7f4707093831c32d13da2bcdd4c8d6e83836ac/fix_tabline_redraw.patch"
    sha256 "23f2416ca056b206fc17cc6ca027a1969217464d42e3b118f6c2310bf6321bd6"
  end

  # better lazy redraw approach, and try to stop cursor from jumping around
  patch do
    url "https://gist.github.com/choco/da496de8114291e99f0fbe5e1b78e7d5/raw"
    sha256 "d8c85ad520c23cd07f4d258916a2b58bdd4ea291aa5ffac38bf156d7079617b2"
  end

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end

    ENV.prepend_path "LUA_PATH", "#{buildpath}/deps-build/share/lua/5.1/?.lua"
    ENV.prepend_path "LUA_CPATH", "#{buildpath}/deps-build/lib/lua/5.1/?.so"

    cd "deps-build" do
      system "luarocks-5.1", "build", "build/src/lpeg/lpeg-1.0.1-1.src.rock", "--tree=."
      system "luarocks-5.1", "build", "build/src/mpack/mpack-1.0.6-0.src.rock", "--tree=."
      system "cmake", "../third-party", "-DUSE_BUNDLED=OFF", *std_cmake_args
      system "make"
    end

    cd "deps-build" do
      system "luarocks-5.1", "build", "build/src/lpeg/lpeg-1.0.1-1.src.rock", "--tree=."
      system "luarocks-5.1", "build", "build/src/mpack/mpack-1.0.6-0.src.rock", "--tree=."
      system "cmake", "../third-party", "-DUSE_BUNDLED=OFF", *std_cmake_args
      system "make"
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
                       "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end

__END__
diff --git a/src/nvim/terminal.c b/src/nvim/terminal.c
index 6f35cdc..5d3f38d 100644
--- a/src/nvim/terminal.c
+++ b/src/nvim/terminal.c
@@ -271,7 +271,7 @@ Terminal *terminal_open(TerminalOptions opts)
     return rv;
   }
 
-  vterm_state_set_bold_highbright(state, true);
+  vterm_state_set_bold_highbright(state, false);
 
   // Configure the color palette. Try to get the color from:
   //
