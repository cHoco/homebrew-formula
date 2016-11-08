require "language/go"

class Lemonade < Formula
  desc "Remote utility tool for copy, paste and open browser over TCP"
  homepage "https://github.com/pocke/lemonade"
  url "https://github.com/pocke/lemonade/archive/v1.1.1.tar.gz"
  sha256 "4409638516233317fd48b9ab42098a937024ec5b22fb70930b6d8331db8b4be6"
  head "https://github.com/pocke/lemonade.git"

  depends_on "go" => :build

  go_resource "github.com/mitchellh/go-homedir" do
    url "https://github.com/mitchellh/go-homedir.git",
        :revision => "756f7b183b7ab78acdbbee5c7f392838ed459dda"
  end

  go_resource "github.com/atotto/clipboard" do
    url "https://github.com/atotto/clipboard.git",
      :revision => "bb272b845f1112e10117e3e45ce39f690c0001ad"
  end

  go_resource "github.com/monochromegane/conflag" do
    url "https://github.com/monochromegane/conflag.git",
      :revision => "6d68c9aa4183844ddc1655481798fe4d90d483e9"
  end

  go_resource "github.com/pocke/go-iprange" do
    url "https://github.com/pocke/go-iprange.git",
      :revision => "08fbe355c365aec69944099014aec26b357eb4f6"
  end

  go_resource "github.com/skratchdot/open-golang/open" do
    url "https://github.com/skratchdot/open-golang.git",
      :revision => "75fb7ed4208cf72d323d7d02fd1a5964a7a9073c"
  end

  go_resource "github.com/BurntSushi/toml" do
    url "https://github.com/BurntSushi/toml.git",
      :revision => "99064174e013895bbd9b025c31100bd1d9b590ca"
  end

  def install
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"
    ENV["GOPATH"] = buildpath

    base_flag = "-X github.com/pocke/lemonade/lemon"
    ldflags = %W[
      #{base_flag}.Version=v#{version}
    ]

    (buildpath/"src/github.com/pocke/lemonade").install buildpath.children
    Language::Go.stage_deps resources, buildpath/"src"
    cd "src/github.com/pocke/lemonade" do
      system "go", "build", "-ldflags", ldflags
      bin.install "lemonade"
    end

    system "go", "build", "-ldflags", ldflags
    bin.install "lemonade"
  end
end
