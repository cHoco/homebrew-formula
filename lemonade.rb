class Lemonade < Formula
  desc "Remote utility tool for copy, paste and open browser over TCP"
  homepage "https://github.com/pocke/lemonade"
  url "https://github.com/pocke/lemonade/archive/v1.1.1.tar.gz"
  sha256 "4409638516233317fd48b9ab42098a937024ec5b22fb70930b6d8331db8b4be6"
  head "https://github.com/pocke/lemonade.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    base_flag = "-X github.com/pocke/lemonade/lemon"
    ldflags = %W[
      #{base_flag}.Version=#{version}
    ]

    system "go", "build", "-ldflags", ldflags
    bin.install "lemonade"
  end
end
